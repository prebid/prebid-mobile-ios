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

#import "PBCacheLoader.h"
#import "PBFacebookInterstitialAdLoader.h"
#import "PrebidCustomEventInterstitialDFP.h"
#import "PrebidMobileDemandSDKLoaderSettings.h"

@interface PrebidCustomEventInterstitialDFP ()

@property (strong, nonatomic) NSString *cacheId;
@property (strong, nonatomic) NSString *bidder;
@property (strong, nonatomic) PBBaseInterstitialAdLoader *adLoader;
@property (strong, nonatomic) PBCacheLoader *cacheLoader;

@end

@implementation PrebidCustomEventInterstitialDFP

@synthesize delegate;
@synthesize viewControllerForPresentingModalView;

- (void)requestInterstitialAdWithParameter:(NSString *)serverParameter
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
        self.adLoader = [[PBFacebookInterstitialAdLoader alloc] initWithDelegate:self];
        [self.adLoader loadInterstitialAd:responseDict];
    } else {
        NSLog(@"Not a valid bidder for DFP Custom Event Demand SDK Loader");
    }
}

-(void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.adLoader showAdFromRootViewController:rootViewController];
}

#pragma mark - PBCustomEventInterstitialDelegate

- (void)didLoadAd:(id)interstitialAd {
    [self.delegate customEventInterstitialDidReceiveAd:interstitialAd];
    [self.delegate customEventInterstitialWillPresent:interstitialAd];
}

- (void)ad:(id)interstitialAd didFailWithError:(NSError *)error {
	[self.delegate customEventInterstitial:self didFailAd:error];
}

- (void)willCloseInterstitial:(id)interstitialAd {
    [self.delegate customEventInterstitialWillDismiss:self];
}

- (void)didCloseInterstitial:(id)interstitialAd {
    [self.delegate customEventInterstitialDidDismiss:self];
}

- (void)didClickAd:(id)interstitialAd {
    [self.delegate customEventInterstitialWasClicked:self];
    [self.delegate customEventInterstitialWillLeaveApplication:self];
}


@end
