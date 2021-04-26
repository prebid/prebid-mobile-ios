//
//  UIView+OxmExtensions.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+PBMViewExposure.h"

@interface UIView (PBMExtensions)

- (void)PBMAddFillSuperviewConstraints
    NS_SWIFT_NAME(PBMAddFillSuperviewConstraints());

- (void)PBMAddConstraintsFromCGRect:(CGRect)rect
    NS_SWIFT_NAME(PBMAddConstraintsFromCGRect(_:));

- (void)PBMAddCropAndCenterConstraintsWithInitialWidth:(CGFloat)initialWidth initialHeight:(CGFloat)initialHeight
    NS_SWIFT_NAME(PBMAddCropAndCenterConstraints(initialWidth:initialHeight:));

- (void)PBMAddBottomRightConstraintsWithMarginSize:(CGSize)marginSize;

- (void)PBMAddBottomRightConstraintsWithViewSize:(CGSize)viewSize marginSize:(CGSize)marginSize
    NS_SWIFT_NAME(PBMAddBottomRightConstraints(viewSize:marginSize:));

- (void)PBMAddBottomLeftConstraintsWithViewSize:(CGSize)viewSize marginSize:(CGSize)marginSize
    NS_SWIFT_NAME(PBMAddBottomLeftConstraints(viewSize:marginSize:));

- (void)PBMAddTopRightConstraintsWithViewSize:(CGSize)viewSize marginSize:(CGSize)marginSize
    NS_SWIFT_NAME(PBMAddTopRightConstraints(viewSize:marginSize:));

- (void)PBMAddTopLeftConstraintsWithViewSize:(CGSize)viewSize marginSize:(CGSize)marginSize
NS_SWIFT_NAME(PBMAddTopLeftConstraints(viewSize:marginSize:));

- (void)PBMLogViewHierarchy;

- (BOOL)pbmIsVisible;

- (BOOL)pbmIsVisibleInView:(UIView *)inView;

- (BOOL)pbmIsVisibleInViewLegacy:(UIView *)inView;

@end
