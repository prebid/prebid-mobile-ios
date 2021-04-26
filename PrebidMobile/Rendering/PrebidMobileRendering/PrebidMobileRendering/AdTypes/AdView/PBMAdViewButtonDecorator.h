//
//  PBMAdViewButtonDecorator.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBMInterstitialDisplayProperties.h"
#import "PBMVoidBlock.h"

@interface PBMAdViewButtonDecorator : NSObject

@property (nonatomic, strong, nonnull) UIButton *button;
@property (nonatomic, assign) PBMPosition buttonPosition;
@property (nonatomic, assign) CGRect customButtonPosition;

@property (nonatomic, copy, nullable) PBMVoidBlock buttonTouchUpInsideBlock;

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
