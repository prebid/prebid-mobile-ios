//
//  PBMInterstitialEventHandler.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "PBMPrimaryAdRequesterProtocol.h"

@class BidResponse;

NS_ASSUME_NONNULL_BEGIN

@protocol PBMInterstitialAd <PBMPrimaryAdRequesterProtocol>

@required

/*!
 @abstract Return whether an interstitial is ready for display
 */
@property (nonatomic, readonly) BOOL isReady;

/*!
 @abstract PBM SDK calls this method to show the interstitial ad from the ad server SDK
 @param controller view controller to be used for presenting the interstitial ad
*/
- (void)showFromViewController:(nullable UIViewController *)controller;

@optional

/*!
  @abstract Called by PBM SDK to notify primary ad server.
 */
- (void)trackImpression;

@end

NS_ASSUME_NONNULL_END
