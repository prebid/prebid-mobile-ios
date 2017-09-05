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

#import "PrebidMobileDemandSDKAdapterForDFP.h"
#import "PBFacebookBannerAdLoader.h"
#import "PBCacheLoader.h"

static NSString *const customEventErrorDomain = @"org.prebid.PrebidMobileMediationAdapter";
static NSString *const kPrebidCacheEndpoint = @"https://prebid.adnxs.com/pbc/v1/get?uuid=";

@interface PrebidMobileDemandSDKAdapterForDFP()

@property (strong, nonatomic) NSString *cacheId;
@property (strong, nonatomic) NSString *bidder;
@property (strong, nonatomic) PBBaseBannerAdLoader *adLoader;
@property (strong, nonatomic) PBCacheLoader *cacheLoader;

@end

@implementation PrebidMobileDemandSDKAdapterForDFP

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
        }
    }
    [self requestAdmAndLoadAd];
}

- (void)requestAdmAndLoadAd {
    self.cacheLoader = [[PBCacheLoader alloc] initWithCacheId:self.cacheId];
    void (^block)(NSDictionary *) = ^void(NSDictionary *response) {
        [self loadAd:response];
    };
    [self.cacheLoader requestAdmWithCompletionBlock:block];
}

- (void)loadAd:(NSDictionary *)responseDict {
    if ([self.bidder isEqualToString:@"audienceNetwork"]) {
        self.adLoader = [[PBFacebookBannerAdLoader alloc] initWithDelegate:self];
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
