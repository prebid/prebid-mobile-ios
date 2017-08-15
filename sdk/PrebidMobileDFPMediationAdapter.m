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

static NSString *const customEventErrorDomain = @"org.prebid.PrebidMobileMediationAdapter";

@implementation PrebidMobileDFPMediationAdapter

@synthesize delegate;
@synthesize viewControllerForPresentingModalView;

- (void)requestBannerAd:(GADAdSize)adSize
              parameter:(NSString *)serverParameter
                  label:(NSString *)serverLabel
                request:(GADCustomEventRequest *)request {
//    NSArray *keywords = request.userKeywords;
//    for (NSString *keyword in keywords) {
//        if ([keyword containsString:@"hb_cache_id"]) {
//            NSArray *splitValue = [keyword componentsSeparatedByString:@":"];
//            self.cacheId = splitValue[1];
//        }
//        if ([keyword containsString:@"hb_bidder"]) {
//            NSArray *splitValue = [keyword componentsSeparatedByString:@":"];
//            self.bidder = splitValue[1];
//        }
//    }
//    [self requestAdmAndLoadAd];
    
    [FBAdSettings setLogLevel:FBAdLogLevelVerbose];
    NSString *bidPayload = @"{\"type\":\"ID\",\"bid_id\":\"4401013946958491377\",\"placement_id\":\"1995257847363113_1997038003851764\",\"sdk_version\":\"4.25.0-appnexus.bidding\",\"device_id\":\"87ECBA49-908A-428F-9DE7-4B9CED4F486C\",\"template\":7,\"payload\":\"null\"}";
    
    FBAdView *adView = [[FBAdView alloc] initWithPlacementID:@"1995257847363113_1997038003851764"
                                                      adSize:kFBAdSizeHeight250Rectangle
                                          rootViewController:(UIViewController *)[NSObject new]];
    adView.frame = CGRectMake(0, 0, adView.bounds.size.width, adView.bounds.size.height);
    adView.delegate = self;
    NSLog(@"delegate = %@", adView.delegate);
    [adView disableAutoRefresh];
    CGRect fbAdFrame = adView.frame;
    fbAdFrame.size = CGSizeMake(300, 250);
    adView.frame = fbAdFrame;
    [adView loadAdWithBidPayload:bidPayload];
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIView *topView = window.rootViewController.view;
    [topView addSubview:adView];
}

//#pragma mark - PBDFPMediationDelegate methods
//
//- (void)didLoadAd:(UIView *)adView {
//    //[adView setFrame:CGRectMake(0, 10, 300, 250)];
//    [self.delegate customEventBanner:self didReceiveAd:adView];
//}
//
//- (void)ad:(UIView *)adView didFailWithError:(NSError *)error {
//    [self.delegate customEventBanner:self didFailAd:error];
//}
//
//- (void)didClickAd:(UIView *)adView {
//    [self.delegate customEventBannerWasClicked:self];
//}

#pragma mark FBAdViewDelegate methods

- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)error {
    NSLog(@"Facebook mediated ad failed to load with error: %@", error);
    //[self.delegate ad:adView didFailWithError:error];
}

- (void)adViewDidLoad:(FBAdView *)adView {
    NSLog(@"Ad was loaded and ready to be displayed22");
    NSLog(@"Facebook mediated ad did load.");
    [self.delegate customEventBanner:self didReceiveAd:adView];
}

- (void)adViewWillLogImpression:(FBAdView *)adView {
    NSLog(@"Facebook mediated ad will log impression.");
    //[self.delegate trackImpression];
}

- (void)adViewDidClick:(FBAdView *)adView {
    NSLog(@"Facebook mediated ad did click.");
    //[self.delegate didClickAd:adView];
}

- (void)adViewDidFinishHandlingClick:(FBAdView *)adView {
    NSLog(@"Facebook mediated ad did finish handling click.");
    //[self.delegate didFinishHandlingClick:adView];
}

- (UIViewController *)viewControllerForPresentingModalView {
    return [self.delegate viewControllerForPresentingModalView];
}

//#pragma mark - Custom Event for Interstitials
//
//- (void)requestInterstitialAdWithParameter:(NSString *)serverParameter
//                                     label:(NSString *)serverLabel
//                                   request:(GADCustomEventRequest *)request {
////    self.interstitial = [[SampleInterstitial alloc] init];
////    self.interstitial.delegate = self;
////    self.interstitial.adUnit = serverParameter;
////    SampleAdRequest *adRequest = [[SampleAdRequest alloc] init];
////    adRequest.testMode = request.isTesting;
////    adRequest.keywords = request.userKeywords;
////    [self.interstitial fetchAd:adRequest];
//}

/// Constant for Sample Ad Network custom event error domain.
//static NSString *const customEventErrorDomain = @"com.google.CustomEvent";
//
//// Sent when an interstitial ad has loaded.
//- (void)interstitialDidLoad:(SampleInterstitial *)interstitial {
//    [self.delegate customEventInterstitialDidReceiveAd:self];
//}
//
//// Sent when an interstitial ad has failed to load.
//- (void)interstitial:(SampleInterstitial *)interstitial
//didFailToLoadAdWithErrorCode:(SampleErrorCode)errorCode {
//    NSError *error = [NSError errorWithDomain:customEventErrorDomain
//                                         code:errorCode
//                                     userInfo:nil];
//    [self.delegate customEventInterstitial:self didFailAd:error];
//}
//
//// Sent when an interstitial is about to be shown.
//- (void)interstitialWillPresentScreen:(SampleInterstitial *)interstitial {
//    [self.delegate customEventInterstitialWillPresent:self];
//}
//
//// Sent when an interstitial is about to be dismissed.
//- (void)interstitialWillDismissScreen:(SampleInterstitial *)interstitial {
//    [self.delegate customEventInterstitialWillDismiss:self];
//}
//
//// Sent when an interstitial has been dismissed.
//- (void)interstitialDidDismissScreen:(SampleInterstitial *)interstitial {
//    [self.delegate customEventInterstitialDidDismiss:self];
//}
//
//// Sent when an interstitial is clicked and an external application is launched.
//- (void)interstitialWillLeaveApplication:(SampleInterstitial *)interstitial {
//    [self.delegate customEventInterstitialWasClicked:self];
//    [self.delegate customEventInterstitialWillLeaveApplication:self];
//}


@end
