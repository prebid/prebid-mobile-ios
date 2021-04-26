//
//  PBMBannerEventLoadingDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 ------------------------------------------------------------------------------------
 PBMBannerEventLoadingDelegate Protocol
 ------------------------------------------------------------------------------------
 */

/*!
 The banner custom event delegate. It is used to inform the ad server SDK events back to the PBM SDK.
 */
@protocol PBMBannerEventLoadingDelegate

/*!
 @abstract Call this when the ad server SDK signals about partner bid win
 */
- (void)prebidDidWin;

/*!
 @abstract Call this when the ad server SDK renders its own ad
 @param view rendered ad view from the ad server SDK
 */
- (void)adServerDidWin:(UIView *)view adSize:(CGSize)adSize;

/*!
 @abstract Call this when the ad server SDK fails to load the ad
 @param error detailed error object describing the cause of ad failure
*/
- (void)failedWithError:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
