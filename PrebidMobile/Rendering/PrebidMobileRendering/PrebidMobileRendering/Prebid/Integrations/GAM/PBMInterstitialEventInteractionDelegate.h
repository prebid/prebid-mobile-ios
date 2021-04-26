//
//  PBMInterstitialEventInteractionDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 The interstitial custom event delegate. It is used to inform ad server events back to the OpenWrap SDK
 */
@protocol PBMInterstitialEventInteractionDelegate <NSObject>

//    /*!
//     @abstract Call this to fetch any additional custom data for handling ad server calls or rendering.
//     */
//    - (NSDictionary* _Nullable)customData;


/*!
 @abstract Call this when the ad server SDK is about to present a modal
 */
- (void)willPresentAd;

/*!
 @abstract Call this when the ad server SDK dissmisses a modal
 */
- (void)didDismissAd;


/*!
 @abstract Call this when the ad server SDK informs about app leave event as a result of user interaction.
 */
- (void)willLeaveApp;

/*!
 @abstract Call this when the ad server SDK informs about click event as a result of user interaction.
 */
- (void)didClickAd;

@end

NS_ASSUME_NONNULL_END
