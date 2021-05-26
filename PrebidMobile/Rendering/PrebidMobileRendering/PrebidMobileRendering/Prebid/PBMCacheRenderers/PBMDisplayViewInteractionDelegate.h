//
//  PBMDisplayViewInteractionDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PBMDisplayView;

NS_ASSUME_NONNULL_BEGIN

@protocol PBMDisplayViewInteractionDelegate <NSObject>

@required

- (void)trackImpressionForDisplayView:(PBMDisplayView *)displayView;

- (nullable UIViewController *)viewControllerForModalPresentationFrom:(PBMDisplayView *)displayView;

- (void)didLeaveAppFromDisplayView:(PBMDisplayView *)displayView;

/// Called when the user clicks on an ad and a clickthrough is about to occur
- (void)displayViewWillPresentModal:(PBMDisplayView *)displayView;

/// Called when the user closes a clickthrough
- (void)displayViewDidDismissModal:(PBMDisplayView *)displayView;

@end

NS_ASSUME_NONNULL_END
