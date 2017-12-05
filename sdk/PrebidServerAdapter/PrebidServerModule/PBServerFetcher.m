
/*   Copyright 2017 APPNEXUS INC
 
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
//    if (self.requestTIDs == nil) {
//        self.requestTIDs = [[NSMutableArray alloc] init];
//    }
//    @synchronized(self.requestTIDs) {
//        [self.requestTIDs addObject:params[@"tid"]];
//    }

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (response != nil && data.length > 0) {
                                   PBLogDebug(@"Bid response from Prebid Server: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                   NSDictionary *adUnitToBids = [self processData:data];
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
    NSDictionary *bidMap = [[NSDictionary alloc] init];
    bidMap = @{
        @"id":@"some-request-id",
        @"seatbid":@[
                   @{
                       @"bid":@[
                              @{
                                  @"id":@"4107461962527263292",
                                  @"impid":@"my-imp-id",
                                  @"price":@(5),
                                  @"adm":@"<script type=\"application/javascript\" src=\"http://nym1-ib.adnxs.com/ab?e=wqT_3QLUBaDUAgAAAwDWAAUBCM-ygdEFENvoqbrnoOP8eRicivXS0qH_pjcqLQkAAAECCBRAEQEHEAAAFEAZCQkI4D8hCQkIFEApCQmwJEAwn66zBTi-B0DyBkgCUIa17CZYhaVOYABovMJneMqlBIABAYoBA1VTRJIBAQbwUpgBrAKgAfoBqAEBsAEAuAECwAEFyAEC0AEA2AEA4AEB8AEAigI7dWYoJ2EnLCAyMTcwNzQ4LCAxNTEyMDY5NDU1KTt1ZigncicsIDgxNDY4MDM4Nh4A8IGSAvkBIUpETW5pUWl1LUtRSkVJYTE3Q1lZQUNDRnBVNHdBRGdBUUFCSThnWlFuNjZ6QlZnQVlQX19fXzhQYUFCd0FYZ0JnQUVCaUFFQmtBRUJtQUVCb0FFQnFBRURzQUVBdVFIenJXcWtBQUFrUU1FQjg2MXFwQUFBSkVESkFRQUFBAQMUUEFfMlFFAQpwQUFBRHdQLUFCQVBVQkFBQWdRWmdDQUtBQ0FMVUMBHghBTDAJCPBMTUFDQWNnQ0FkQUNBZGdDQWVBQ0FPZ0NBUGdDQUlBREFaQURBSmdEQWFnRHJ2aWtDYm9EQ1U1WlRUSTZNelV3TlEuLpoCLSFBUW5Rb0E2_ADwimhhVk9JQUFvQURvSlRsbE5Nam96TlRBMdgC6AfgAvzmPYADAYgDAZAD_78YmAMUoAMBqgMAwAOsAsgDANgDAOADAOgDAPgDAIAEAJIECS9vcGVucnRiMpgEAKgEALIEDAgAEAAYACAAMAA4ALgEAMAEAMgEANIECU5ZTTI6MzUwNdoEAggB4AQA8ARBIiCIBQGYBQCgBf8RAVwBqgUPc29tZS1yZXF1ZXN0LWlkwAUAyQVJZRTwP9IFCQkJDEQAANgFAeAFAfAFAfoFBAgAEAA.ss=a3b6c936d049fea367bf7a2a87a7da0adc8b690astest=1p=${AUCTION_PRICE}\"></script>",
                                  @"adid":@"81468038",
                                  @"adomain":@[
                                             @"appnexus.com"
                                             ],
                                  @"iurl":@"http://nym1-ib.adnxs.com/cr?id=81468038",
                                  @"cid":@"882",
                                  @"crid":@"81468038",
                                  @"dealid":@"401407",
                                  @"w":@(300),
                                  @"h":@(250),
                                  @"ext":@{
                                      @"prebid":@{
                                          @"responsetimemillis":@(0),
                                          @"targeting":@{
                                              @"hb_bidder":@"appnexus",
                                              @"hb_bidder_appnexus":@"appnexus",
                                              @"hb_creative_loadtype":@"html",
                                              @"hb_deal":@"401407",
                                              @"hb_deal_appnexus":@"401407",
                                              @"hb_pb":@"5.00",
                                              @"hb_pb_appnexus":@"5.00",
                                              @"hb_size":@"300x250",
                                              @"hb_size_appnexus":@"300x250"
                                          },
                                          @"type":@"banner"
                                      },
                                      @"bidder":@{
                                          @"appnexus":@{
                                              @"brand_id":@(1),
                                              @"auction_id":@"8789211206700921947",
                                              @"bidder_id":@(2),
                                              @"ranking_price":@"0.000000"
                                          }
                                      }
                                  }
                              },
                              @{
                                  @"id":@"6754596782874271437",
                                  @"impid":@"my-imp-id",
                                  @"price":@(0.5),
                                  @"adm":@"<script type=\"application/javascript\" src=\"http://nym1-ib.adnxs.com/ab?e=wqT_3QLUBaDUAgAAAwDWAAUBCM-ygdEFENvoqbrnoOP8eRicivXS0qH_pjcqLQkAAAECCBRAEQEHEAAAFEAZCQkI4D8hCQkIFEApCQmwJEAwn66zBTi-B0DyBkgCUIa17CZYhaVOYABovMJneMqlBIABAYoBA1VTRJIBAQbwUpgBrAKgAfoBqAEBsAEAuAECwAEFyAEC0AEA2AEA4AEB8AEAigI7dWYoJ2EnLCAyMTcwNzQ4LCAxNTEyMDY5NDU1KTt1ZigncicsIDgxNDY4MDM4Nh4A8IGSAvkBIUpETW5pUWl1LUtRSkVJYTE3Q1lZQUNDRnBVNHdBRGdBUUFCSThnWlFuNjZ6QlZnQVlQX19fXzhQYUFCd0FYZ0JnQUVCaUFFQmtBRUJtQUVCb0FFQnFBRURzQUVBdVFIenJXcWtBQUFrUU1FQjg2MXFwQUFBSkVESkFRQUFBAQMUUEFfMlFFAQpwQUFBRHdQLUFCQVBVQkFBQWdRWmdDQUtBQ0FMVUMBHghBTDAJCPBMTUFDQWNnQ0FkQUNBZGdDQWVBQ0FPZ0NBUGdDQUlBREFaQURBSmdEQWFnRHJ2aWtDYm9EQ1U1WlRUSTZNelV3TlEuLpoCLSFBUW5Rb0E2_ADwimhhVk9JQUFvQURvSlRsbE5Nam96TlRBMdgC6AfgAvzmPYADAYgDAZAD_78YmAMUoAMBqgMAwAOsAsgDANgDAOADAOgDAPgDAIAEAJIECS9vcGVucnRiMpgEAKgEALIEDAgAEAAYACAAMAA4ALgEAMAEAMgEANIECU5ZTTI6MzUwNdoEAggB4AQA8ARBIiCIBQGYBQCgBf8RAVwBqgUPc29tZS1yZXF1ZXN0LWlkwAUAyQVJZRTwP9IFCQkJDEQAANgFAeAFAfAFAfoFBAgAEAA.ss=a3b6c936d049fea367bf7a2a87a7da0adc8b690astest=1p=${AUCTION_PRICE}\"></script>",
                                  @"adid":@"68209699",
                                  @"adomain":@[
                                             @"dabee.com.br"
                                             ],
                                  @"iurl":@"http://nym1-ib.adnxs.com/cr?id=68209699",
                                  @"cid":@"882",
                                  @"crid":@"68209699",
                                  @"cat":@[
                                         @"IAB22",
                                         @"IAB22-4"
                                         ],
                                  @"dealid":@"test-prebid-deal-code",
                                  @"w":@(300),
                                  @"h":@(250),
                                  @"ext":@{
                                      @"prebid":@{
                                          @"responsetimemillis":@(0),
                                          @"targeting":@{
                                              @"hb_bidder_appnexus":@"appnexus",
                                              @"hb_deal_appnexus":@"test-prebid-deal-code",
                                              @"hb_pb_appnexus":@"0.50",
                                              @"hb_size_appnexus":@"300x250"
                                          },
                                          @"type":@"banner"
                                      },
                                      @"bidder":@{
                                          @"appnexus":@{
                                              @"brand_id":@(44321),
                                              @"auction_id":@(8789211206700921947),
                                              @"bidder_id":@(2),
                                              @"ranking_price":@"0.000000"
                                          }
                                      }
                                  }
                              }
                              ],
                       @"seat":@"appnexus"
                   }
                   ],
        @"ext":@{
            @"debug":@{
                @"httpcalls":@{
                    @"appnexus":@[
                                @{
                                    @"uri":@"http://ib.adnxs.com/openrtb2",
                                    @"requestbody":@"{\"id\":\"some-request-id\",\"imp\":[{\"id\":\"my-imp-id\",\"banner\":{\"format\":[{\"w\":300,\"h\":250},{\"w\":300,\"h\":600}]},\"ext\":{\"appnexus\":{\"placement_id\":11327263}}}],\"test\":1,\"tmax\":500}",
                                    @"responsebody":@"{\"id\":\"some-request-id\",\"seatbid\":[{\"bid\":[{\"id\":\"4107461962527263292\",\"impid\":\"my-imp-id\",\"price\": 5.000000,\"adid\":\"81468038\",\"adm\":\" type=\\\"application/javascript\\\" src=\\\"http://nym1-ib.adnxs.com/ab?e=wqT_3QLUBaDUAgAAAwDWAAUBCM-ygdEFENvoqbrnoOP8eRicivXS0qH_pjcqLQkAAAECCBRAEQEHEAAAFEAZCQkI4D8hCQkIFEApCQmwJEAwn66zBTi-B0DyBkgCUIa17CZYhaVOYABovMJneMqlBIABAYoBA1VTRJIBAQbwUpgBrAKgAfoBq,\"seat\":\"882\"}],\"bidid\":\"8163341907479988349\",\"cur\":\"USD\"}",
                                    @"status":@(200)
                                }
                                ]
                }
            },
            @"responsetimemillis":@{
                @"appnexus":@(81)
            }
        }
    };
//    NSError *error;
//    id object = [NSJSONSerialization JSONObjectWithData:data
//                                                options:kNilOptions
//                                                  error:&error];
//    if (error) {
//        PBLogError(@"Error parsing ad server response");
//        return [[NSMutableDictionary alloc] init];
//    }
//    if (!object) {
//        return [[NSMutableDictionary alloc] init];
//    }
    NSMutableDictionary *adUnitToBidsMap = [[NSMutableDictionary alloc] init];
    if ([bidMap isKindOfClass:[NSDictionary class]]) {
        NSDictionary *response = (NSDictionary *)bidMap;
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
//                NSString *responseTID = (NSString *)[response objectForKey:@"tid"];
//                NSMutableArray *requestTIDsToDelete = [NSMutableArray array];
//                @synchronized (self.requestTIDs) {
//                    if ([self.requestTIDs containsObject:responseTID]) {
//                        [requestTIDsToDelete addObject:responseTID];
//                        bidMap = [self mapBidsToAdUnits:response];
//                    } else {
//                        PBLogError(@"Response tid did not match request tid %@", response);
//                    }
//                    [self.requestTIDs removeObjectsInArray:requestTIDsToDelete];
//                }
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
