//
//  UIView+OxmExtensions.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+OXMViewExposure.h"

@interface UIView (OxmExtensions)

- (void)OXMAddFillSuperviewConstraints
    NS_SWIFT_NAME(OXMAddFillSuperviewConstraints());

- (void)OXMAddConstraintsFromCGRect:(CGRect)rect
    NS_SWIFT_NAME(OXMAddConstraintsFromCGRect(_:));

- (void)OXMAddCropAndCenterConstraintsWithInitialWidth:(CGFloat)initialWidth initialHeight:(CGFloat)initialHeight
    NS_SWIFT_NAME(OXMAddCropAndCenterConstraints(initialWidth:initialHeight:));

- (void)OXMAddBottomRightConstraintsWithMarginSize:(CGSize)marginSize;

- (void)OXMAddBottomRightConstraintsWithViewSize:(CGSize)viewSize marginSize:(CGSize)marginSize
    NS_SWIFT_NAME(OXMAddBottomRightConstraints(viewSize:marginSize:));

- (void)OXMAddBottomLeftConstraintsWithViewSize:(CGSize)viewSize marginSize:(CGSize)marginSize
    NS_SWIFT_NAME(OXMAddBottomLeftConstraints(viewSize:marginSize:));

- (void)OXMAddTopRightConstraintsWithViewSize:(CGSize)viewSize marginSize:(CGSize)marginSize
    NS_SWIFT_NAME(OXMAddTopRightConstraints(viewSize:marginSize:));

- (void)OXMAddTopLeftConstraintsWithViewSize:(CGSize)viewSize marginSize:(CGSize)marginSize
NS_SWIFT_NAME(OXMAddTopLeftConstraints(viewSize:marginSize:));

- (void)OXMLogViewHierarchy;

- (BOOL)oxaIsVisible;

- (BOOL)oxmIsVisibleInView:(UIView *)inView;

- (BOOL)oxmIsVisibleInViewLegacy:(UIView *)inView;

@end
