//
//  OXMModalAnimator.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OXMTouchForwardingView.h"

NS_ASSUME_NONNULL_BEGIN
@interface OXMModalAnimator : NSObject <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrameOfPresentedView:(CGRect)frameOfPresentedView NS_DESIGNATED_INITIALIZER;

@end
NS_ASSUME_NONNULL_END
