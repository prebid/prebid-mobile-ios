//
//  PBMInterstitialEventLoadingDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 The interstitial custom event delegate. It is used to inform ad server events back to the OpenWrap SDK
 */
@protocol PBMInterstitialEventLoadingDelegate <NSObject>

/*!
 @abstract Call this when the ad server SDK signals about partner bid win
 */
- (void)prebidDidWin;

/*!
 @abstract Call this when the ad server SDK renders its own ad
 */
- (void)adServerDidWin;

/*!
 @abstract Call this when the ad server SDK fails to load the ad
 @param error detailed error object describing the cause of ad failure
 */
- (void)failedWithError:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
