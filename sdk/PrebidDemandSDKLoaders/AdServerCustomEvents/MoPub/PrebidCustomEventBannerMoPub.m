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
#import "PBCacheLoader.h"
#import "PBFacebookBannerAdLoader.h"
#import "PrebidCustomEventBannerMoPub.h"
#import "PrebidMobileDemandSDKLoaderSettings.h"

@interface PrebidCustomEventBannerMoPub()

@property (strong, nonatomic) NSString *cacheId;
@property (strong, nonatomic) NSString *bidder;
@property (strong, nonatomic) PBBaseBannerAdLoader *adLoader;
@property (strong, nonatomic) PBCacheLoader *cacheLoader;

@end

@implementation PrebidCustomEventBannerMoPub

@synthesize viewControllerForPresentingModalView;

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info {
	MPBannerCustomEventAdapter *adapterDelegate = (MPBannerCustomEventAdapter *)self.delegate;
    NSString *keywords = [(MPAdView *)[(MPBannerAdManager *)[adapterDelegate delegate] delegate] keywords];

    NSArray *splitValue = [keywords componentsSeparatedByString:@","];
    for (NSString *value in splitValue) {
        if ([value containsString:@"hb_cache_id"]) {
            NSArray *secondSplitValue = [value componentsSeparatedByString:@":"];
            self.cacheId = secondSplitValue[1];
        }
        if ([keywords containsString:@"hb_bidder"]) {
            NSArray *secondSplitValue = [value componentsSeparatedByString:@":"];
            self.bidder = secondSplitValue[1];
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

#pragma mark - PBBannerMediationAdapterDelegate methods

- (void)didLoadAd:(UIView *)adView {
	[self.delegate bannerCustomEvent:self didLoadAd:adView];
}

- (void)ad:(UIView *)adView didFailWithError:(NSError *)error {
	[self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)didClickAd:(UIView *)adView {
}

- (void)trackImpression {

}

@end
