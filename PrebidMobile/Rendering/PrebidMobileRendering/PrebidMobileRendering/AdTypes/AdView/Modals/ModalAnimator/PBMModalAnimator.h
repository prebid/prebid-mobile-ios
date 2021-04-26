//
//  PBMModalAnimator.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PBMTouchForwardingView.h"

NS_ASSUME_NONNULL_BEGIN
@interface PBMModalAnimator : NSObject <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrameOfPresentedView:(CGRect)frameOfPresentedView NS_DESIGNATED_INITIALIZER;

@end
NS_ASSUME_NONNULL_END
