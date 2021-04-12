//
//  OXADisplayViewInteractionDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class OXADisplayView;

NS_ASSUME_NONNULL_BEGIN

@protocol OXADisplayViewInteractionDelegate <NSObject>

@required

- (void)trackImpressionForDisplayView:(OXADisplayView *)displayView;

- (UIViewController *)viewControllerForModalPresentationFrom:(OXADisplayView *)displayView;

- (void)didLeaveAppFromDisplayView:(OXADisplayView *)displayView;

@optional

/// Called when the user clicks on an ad and a clickthrough is about to occur
- (void)displayViewWillPresentModal:(OXADisplayView *)displayView;

/// Called when the user closes a clickthrough
- (void)displayViewDidDismissModal:(OXADisplayView *)displayView;

@end

NS_ASSUME_NONNULL_END
