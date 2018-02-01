
/*   Copyright 2017 Prebid.org, Inc.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "PBLogging.h"
#import "PBServerFetcher.h"

@interface PBServerFetcher ()

@property (nonatomic, strong) NSMutableArray *requestTIDs;

@end

@implementation PBServerFetcher

+ (instancetype)sharedInstance {
    static dispatch_once_t _dispatchHandle = 0;
    static PBServerFetcher *_sharedInstance = nil;
    
    dispatch_once(&_dispatchHandle, ^{
        if (_sharedInstance == nil)
            _sharedInstance = [[PBServerFetcher alloc] init];
        
    });
    return _sharedInstance;
}

- (void)makeBidRequest:(NSURLRequest *)request withCompletionHandler:(void (^)(NSDictionary *, NSError *))completionHandler {
    PBLogDebug(@"Bid request to Prebid Server: %@ params: %@", request.URL.absoluteString, [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding]);
    NSDictionary *params = [NSJSONSerialization JSONObjectWithData:[request HTTPBody]
                                                           options:kNilOptions
                                                             error:nil];
    // Map request tids to ad unit codes to check to make sure response lines up
    if (self.requestTIDs == nil) {
        self.requestTIDs = [[NSMutableArray alloc] init];
    }
    @synchronized(self.requestTIDs) {
        if(params[@"tid"] != nil){
            [self.requestTIDs addObject:params[@"tid"]];
        }
    }

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (response != nil && data.length > 0) {
                                   PBLogDebug(@"Bid response from Prebid Server: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                   //NSDictionary *adUnitToBids = [self processData:data];
                                   NSDictionary *openRTBAdUnitBidMap = [self processOpenRTBData:data];
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       completionHandler(openRTBAdUnitBidMap, nil);
                                   });
                               } else {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       completionHandler(nil, error);
                                   });
                               }
                           }];
}

- (NSDictionary *)processOpenRTBData:(NSData *)data {
    NSError *error;
    id object = [NSJSONSerialization JSONObjectWithData:data
                                                options:kNilOptions
                                                  error:&error];
    if (error) {
        PBLogError(@"Error parsing ad server response");
        return [[NSMutableDictionary alloc] init];
    }
    if (!object) {
        return [[NSMutableDictionary alloc] init];
    }
    NSMutableDictionary *adUnitToBidsMap = [[NSMutableDictionary alloc] init];
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *response = (NSDictionary *)object;
        if ([[response objectForKey:@"seatbid"] isKindOfClass:[NSArray class]]) {
            NSArray *seatbids = (NSArray *)[response objectForKey:@"seatbid"];
            for (id seatbid in seatbids) {
                if ([seatbid isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *seatbidDict = (NSDictionary *)seatbid;
                    if ([[seatbidDict objectForKey:@"bid"] isKindOfClass:[NSArray class]]) {
                        NSArray *bids = (NSArray *)[seatbidDict objectForKey:@"bid"];
                        for (id bid in bids) {
                            if ([bid isKindOfClass:[NSDictionary class]]) {
                                NSDictionary *bidDict = (NSDictionary *)bid;
                                NSMutableArray *adUnitBids = [[NSMutableArray alloc] init];
                                if ([adUnitToBidsMap objectForKey:bidDict[@"impid"]] != nil) {
                                    adUnitBids = [adUnitToBidsMap objectForKey:bidDict[@"impid"]];
                                }
                                [adUnitBids addObject:bidDict];
                                [adUnitToBidsMap setObject:adUnitBids forKey:bidDict[@"impid"]];
                            }
                        }
                    }
                }
            }
        }
    }
    return adUnitToBidsMap;
}

// now need to handle OpenRTB response
- (NSDictionary *)processData:(NSData *)data {
    NSDictionary *bidMap = [[NSDictionary alloc] init];
    NSError *error;
    id object = [NSJSONSerialization JSONObjectWithData:data
                                                options:kNilOptions
                                                  error:&error];
    if (error) {
        PBLogError(@"Error parsing ad server response");
        return [[NSMutableDictionary alloc] init];
    }
    if (!object) {
        return [[NSMutableDictionary alloc] init];
    }
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *response = (NSDictionary *)object;
        if ([[response objectForKey:@"status"] isKindOfClass:[NSString class]]) {
            NSString *status = (NSString *)[response objectForKey:@"status"];
            if ([status isEqualToString:@"OK"]) {
                // check to make sure the request tid matches the response tid
                NSString *responseTID = (NSString *)[response objectForKey:@"tid"];
                NSMutableArray *requestTIDsToDelete = [NSMutableArray array];
                @synchronized (self.requestTIDs) {
                    if ([self.requestTIDs containsObject:responseTID]) {
                        [requestTIDsToDelete addObject:responseTID];
                        bidMap = [self mapBidsToAdUnits:response];
                    } else {
                        PBLogError(@"Response tid did not match request tid %@", response);
                    }
                    [self.requestTIDs removeObjectsInArray:requestTIDsToDelete];
                }
            }
            else {
                PBLogError(@"Received bad status response from the ad server %@", response);
            }
        }
    } else {
        PBLogError(@"Unexpected response structure received from ad server %@", object);
    }
    return bidMap;
}

- (NSDictionary *)mapBidsToAdUnits:(NSDictionary *)responseDict {
    NSDictionary *response = (NSDictionary *)responseDict;
    
    NSMutableDictionary *adUnitToBidsMap = [[NSMutableDictionary alloc] init];
    if ([[response objectForKey:@"bids"] isKindOfClass:[NSArray class]]) {
        NSArray *bids = (NSArray *)[response objectForKey:@"bids"];
        [bids enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *bid = (NSDictionary *)obj;
                NSMutableArray *bidsArray = [adUnitToBidsMap objectForKey:bid[@"code"]];
                if (bidsArray) {
                    [bidsArray addObject:bid];
                    [adUnitToBidsMap setObject:bidsArray forKey:bid[@"code"]];
                } else {
                    NSMutableArray *newBidsArray = [[NSMutableArray alloc] initWithArray:@[bid]];
                    [adUnitToBidsMap setObject:newBidsArray forKey:bid[@"code"]];
                }
            }
        }];
        return adUnitToBidsMap;
    }
    
    return [[NSMutableDictionary alloc] init];
}

@end
