//
//  PBMBannerEventInteractionDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 ------------------------------------------------------------------------------------
 PBMBannerEventInteractionDelegate Protocol
 ------------------------------------------------------------------------------------
 */

/*!
 The banner custom event delegate. It is used to inform the ad server SDK events back to the PBM SDK.
 */
@protocol PBMBannerEventInteractionDelegate

/*!
 @abstract Call this when the ad server SDK is about to present a modal
 */
- (void)willPresentModal;

/*!
 @abstract Call this when the ad server SDK dissmisses a modal
 */
- (void)didDismissModal;

/*!
 @abstract Call this when the ad server SDK informs about app leave event as a result of user interaction.
 */
- (void)willLeaveApp;

/*!
 @abstract Returns a view controller instance to be used by ad server SDK for showing modals
 @result a UIViewController instance for showing modals
 */
@property (nonatomic, readonly) UIViewController *viewControllerForPresentingModal;

@end

NS_ASSUME_NONNULL_END
