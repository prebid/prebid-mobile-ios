//
//  OXMAdViewButtonDecorator.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OXMInterstitialDisplayProperties.h"
#import "OXMVoidBlock.h"

@interface OXMAdViewButtonDecorator : NSObject

@property (nonatomic, strong, nonnull) UIButton *button;
@property (nonatomic, assign) OXMPosition buttonPosition;
@property (nonatomic, assign) CGRect customButtonPosition;

@property (nonatomic, copy, nullable) OXMVoidBlock buttonTouchUpInsideBlock;

- (void)setImage:(nonnull UIImage *)image;
- (void)addButtonToView:(nonnull UIView *)view displayView:(nonnull UIView *)displayView;
- (void)removeButtonFromSuperview;
- (void)bringButtonToFront;
- (void)sendSubviewToBack;

- (NSInteger)getButtonConstraintConstant;
- (CGSize)getButtonSize;
- (void)updateButtonConstraints;

- (void)buttonTappedAction;

@end
