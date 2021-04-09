//
//  MPFullscreenAdViewController.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPAdViewConstant.h"
#import "MPCountdownTimerDelegate.h"
#import "MPGlobal.h"
#import "MPFullscreenAdViewControllerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The purpose of this @c MPFullscreenAdViewController protocol is to define the common interface
 between interstitial view controllers without forcing them to subclass @c MPFullscreenAdViewController.
 
 @c MPFullscreenAdViewController uses @c MPAdContainerView for @c self.view instead of the
 plain @c UIView. All the video playing logics are contained in @c MPVideoPlayerView, and this view
 controller is designed to be a thin container of the video player view. If this view controller
 should have extra functionalities, consider do it in @c MPVideoPlayerView first since the video
 player view is reused as the subview of some other view controller.
 */
@protocol MPFullscreenAdViewController <NSObject>
@end

@interface MPFullscreenAdViewController : UIViewController <MPFullscreenAdViewController>

@property (nonatomic, assign) NSTimeInterval rewardCountdownDuration; // store locally in case of the view does not exist yet
@property (nonatomic, weak) id<MPFullscreenAdViewControllerAppearanceDelegate> appearanceDelegate;
@property (nonatomic, weak) id<MPCountdownTimerDelegate> countdownTimerDelegate;

- (instancetype)initWithAdContentType:(MPAdContentType)adContentType;

- (void)presentFromViewController:(UIViewController *)viewController complete:(void(^)(NSError * _Nullable))complete;

- (void)dismiss;

- (void)showCloseButton;

@end

#pragma mark -

@interface MPFullscreenAdViewController (MPCountdownTimerDelegate) <MPCountdownTimerDelegate>
@end

NS_ASSUME_NONNULL_END
