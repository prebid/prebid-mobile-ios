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

#import "PrebidMobileDFPMediationAdapter.h"
#import "PBFacebookAdLoader.h"

static NSString *const customEventErrorDomain = @"org.prebid.PrebidMobileMediationAdapter";
static NSString *const kPrebidCacheEndpoint = @"https://prebid.adnxs.com/pbc/v1/get?uuid=";

@interface PrebidMobileDFPMediationAdapter()

@property (strong, nonatomic) NSString *cacheId;
@property (strong, nonatomic) NSString *bidder;
@property (strong, nonatomic) PBCommonAdLoader *adLoader;

@end

@implementation PrebidMobileDFPMediationAdapter

@synthesize delegate;

- (void)requestBannerAd:(GADAdSize)adSize
              parameter:(NSString *)serverParameter
                  label:(NSString *)serverLabel
                request:(GADCustomEventRequest *)request {
    NSArray *keywords = request.userKeywords;
    for (NSString *keyword in keywords) {
        if ([keyword containsString:@"hb_cache_id"]) {
            NSArray *splitValue = [keyword componentsSeparatedByString:@":"];
            self.cacheId = splitValue[1];
        }
        if ([keyword containsString:@"hb_bidder"]) {
            NSArray *splitValue = [keyword componentsSeparatedByString:@":"];
            self.bidder = splitValue[1];
            // TODO nicole remove override
            self.bidder = @"audienceNetwork";
        }
    }
    [self requestAdmAndLoadAd];
}

- (void)requestAdmAndLoadAd {
    // TODO nicole add back in
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
            //TODO nicole switch out real code
            //[self loadAd:responseDictionary];
            NSLog(@"The response is - %@",responseDictionary);
        } else {
            NSLog(@"Error retrieving data from the cache");
        }
    }];
    [dataTask resume];
    // TODO nicole remove below code
    [self loadAd:@{}];
}

- (void)loadAd:(NSDictionary *)responseDict {
    if ([self.bidder isEqualToString:@"audienceNetwork"]) {
        self.adLoader = [[PBFacebookAdLoader alloc] initWithDelegate:self];
        [self.adLoader loadAd:responseDict];
    } else {
        NSLog(@"Not a valid bidder for DFP Mediation Adapter");
    }
}

#pragma mark - PBDFPMediationDelegate methods
- (void)didLoadAd:(UIView *)adView {
    [self.delegate customEventBanner:self didReceiveAd:adView];
}

- (void)ad:(UIView *)adView didFailWithError:(NSError *)error {
    [self.delegate customEventBanner:self didFailAd:error];
}

- (void)didClickAd:(UIView *)adView {
    [self.delegate customEventBannerWasClicked:self];
}

- (void)trackImpression {
    
}

@end
