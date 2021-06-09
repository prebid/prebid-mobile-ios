/*   Copyright 2018-2021 Prebid.org, Inc.

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

#import <Foundation/Foundation.h>

@class UIView;
@class UIViewController;

@class PBMAbstractCreative;
@class PBMAdDetails;
@class PBMAdViewManager;
@class PBMInterstitialDisplayProperties;

// This protocol defines the communication from the PBMAdViewManager to the PBMAdView
NS_ASSUME_NONNULL_BEGIN
@protocol PBMAdViewManagerDelegate <NSObject>

@required
- (nullable UIViewController *)viewControllerForModalPresentation;

- (void)adLoaded:(PBMAdDetails *)pbmAdDetails;
- (void)failedToLoad:(NSError *)error;

- (void)adDidComplete;
- (void)adDidDisplay;

- (void)adWasClicked;
- (void)adViewWasClicked;

- (void)adDidExpand;
- (void)adDidCollapse;

- (void)adDidLeaveApp;

- (void)adClickthroughDidClose;

- (void)adDidClose;

@optional
//Only used by BannerView & PBMVideoAdView
// The actual top layer view that displays the ad
- (UIView *)displayView;

//Only used by PBMVideoAdView, PBMDisplayView, PBMInterstitialController
//Note: all of them seem to simply return a new object.
//TODO: Verify whether the instantiation of an object should be inside the delegate.
- (PBMInterstitialDisplayProperties *)interstitialDisplayProperties;

- (void)videoAdDidFinish;
- (void)videoAdWasMuted;
- (void)videoAdWasUnmuted;

@end
NS_ASSUME_NONNULL_END

