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

#import "PBCommonMediationAdapter.h"

static NSString *const kPrebidCacheEndpoint = @"https://prebid.adnxs.com/pbc/v1/get?uuid=";

@interface PBCommonMediationAdapter ()

@property (strong, nonatomic) NSString *cacheId;
@property (strong, nonatomic) NSString *bidder;

@end

@implementation PBCommonMediationAdapter

- (instancetype)initWithCacheId:(NSString *)cacheId andBidder:(NSString *)bidder {
    self = [super init];
    if (self) {
        self.cacheId = cacheId;
        self.bidder = bidder;
    }
    return self;
}

- (void)requestAdmAndLoadAd {
    NSString *cacheURL = [kPrebidCacheEndpoint stringByAppendingString:self.cacheId];
    
    NSMutableURLRequest *cacheRequest = [[NSMutableURLRequest alloc] init];
    [cacheRequest setHTTPMethod:@"GET"];
    [cacheRequest setURL:[NSURL URLWithString:cacheURL]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:cacheRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            NSError *parseError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            [self loadAd:responseDictionary];
            NSLog(@"The response is - %@",responseDictionary);
        } else {
            NSLog(@"ERROR");
        }
    }];
    [dataTask resume];
    
    [self loadAd:@{}];
}

- (void)loadAd:(NSDictionary *)responseDict {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([self.bidder isEqualToString:@"audienceNetwork"] && NSClassFromString(@"PBFacebookAdLoader")) {
        Class fbAdLoaderClass = NSClassFromString(@"PBFacebookAdLoader");
        id fbAdLoader = [[fbAdLoaderClass alloc] init];
        SEL setDelegate = NSSelectorFromString(@"setPbDelegate:");
        [fbAdLoader performSelector:setDelegate withObject:self];
        SEL fbLoadAd = NSSelectorFromString(@"fbLoadAd:");
        [fbAdLoader performSelector:fbLoadAd withObject:responseDict];
    }
#pragma clang diagnostic pop
}

@end
