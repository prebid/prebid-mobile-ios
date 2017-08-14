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

#import "MPBannerAdManager.h"
#import "MPBannerCustomEventAdapter.h"
#import "PBCommonMediationAdapter.h"
#import "PrebidMobileMoPubMediationAdapter.h"

static NSString *const kPrebidCacheEndpoint = @"https://prebid.adnxs.com/pbc/v1/get?uuid=";

@implementation PrebidMobileMoPubMediationAdapter

@synthesize viewControllerForPresentingModalView;

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info {
    MPBannerCustomEventAdapter *adapterdelegate = (MPBannerCustomEventAdapter *)self.delegate;
    NSString *keywords = [(MPAdView *)[(MPBannerAdManager *)[adapterdelegate delegate] delegate] keywords];
    
    NSString *cacheId;
    NSString *bidder;
    NSArray *splitValue = [keywords componentsSeparatedByString:@","];
    for (NSString *value in splitValue) {
        if ([value containsString:@"hb_cache_id"]) {
            NSArray *secondSplitValue = [value componentsSeparatedByString:@":"];
            cacheId = secondSplitValue[1];
        }
        if ([keywords containsString:@"hb_bidder"]) {
            NSArray *secondSplitValue = [value componentsSeparatedByString:@":"];
            bidder = secondSplitValue[1];
        }
    }
    //PBCommonMediationAdapter *commonMediationAdapter = [[PBCommonMediationAdapter alloc] initWithCacheId:cacheId andBidder:bidder];
    //[commonMediationAdapter requestAdmAndLoadAd];
}

#pragma mark - PBDFPMediationDelegate methods

- (void)didLoadAd:(UIView *)adView {
    [self.delegate bannerCustomEvent:self didLoadAd:adView];
}

- (void)ad:(UIView *)adView didFailWithError:(NSError *)error {
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}

@end
