/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "PBMAdViewButtonDecorator.h"
#import "PBMFunctions+Private.h"
#import "PBMMacros.h"

#import "PrebidMobileSwiftHeaders.h"
#import <PrebidMobile/PrebidMobile-Swift.h>

#pragma mark - Private Interface

@interface PBMAdViewButtonDecorator()

@property (nonatomic, weak) UIView *displayView;
@property (nonatomic, strong) UIImage *buttonImage;
@property (nonatomic, strong) NSArray *activeConstraints;

@end

#pragma mark - Implementation

@implementation PBMAdViewButtonDecorator

- (instancetype)init {
    self = [super init];
    if (self) {
        self.button = [[UIButton alloc] init];
        self.customButtonPosition = CGRectZero;
        self.buttonPosition = PositionTopRight;
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    self.buttonImage = image;
    [self.button setImage:self.buttonImage forState:UIControlStateNormal];
    self.button.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    self.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
}

- (void)addButtonToView:(UIView *)view displayView:(UIView *)displayView {
    self.displayView = displayView;
    
    if (!view || !self.displayView) {
        PBMLogError(@"Attempted to display a nil view");
        return;
    }
    
    self.button.translatesAutoresizingMaskIntoConstraints = NO;
    [self.button addTarget:self action:@selector(buttonTappedAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.button];
    [self updateButtonConstraints];
}

- (void)removeButtonFromSuperview {
    [self.button removeFromSuperview];
}

- (void)bringButtonToFront {
    [self.button.superview bringSubviewToFront:self.button];
}

- (void)sendSubviewToBack {
    [self.button.superview sendSubviewToBack:self.button];
}

- (void)updateButtonConstraints {
    [self.button.superview removeConstraints:self.activeConstraints];
    self.activeConstraints = [self createButtonConstraints];
    [self.button.superview addConstraints:self.activeConstraints];
}

#pragma mark - Internal Methods

- (NSArray *)createButtonConstraints {
    
    NSArray *constraints;
    
    NSInteger constant = [self getButtonConstraintConstant];
    CGSize size = [self getButtonSize];
    
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:size.width];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:size.height];
    
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.displayView attribute:NSLayoutAttributeTop multiplier:1.0 constant:constant];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.displayView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-constant];
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.displayView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.displayView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-constant];
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.displayView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:constant];
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.displayView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    
    switch (self.buttonPosition) {
        case PositionTopLeft:
            constraints = [NSArray arrayWithObjects:width, height, top, left, nil];
            break;
            
        case PositionTopRight:
            constraints = [NSArray arrayWithObjects:width, height, top, right, nil];
            break;
            
        case PositionTopCenter:
            constraints = [NSArray arrayWithObjects:width, height, top, centerX, nil];
            break;
            
        case PositionCenter:
            constraints = [NSArray arrayWithObjects:width, height, centerY, centerX, nil];
            break;
            
        case PositionBottomLeft:
            constraints = [NSArray arrayWithObjects:width, height, bottom, left, nil];
            break;
            
        case PositionBottomRight:
            constraints = [NSArray arrayWithObjects:width, height, bottom, right, nil];
            break;
            
        case PositionBottomCenter:
            constraints = [NSArray arrayWithObjects:width, height, bottom, centerX, nil];
            break;
            
        case PositionCustom: {
            
            NSLayoutConstraint *customWidth     = [NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.customButtonPosition.size.width];
            NSLayoutConstraint *customHeight    = [NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.customButtonPosition.size.height];
            NSLayoutConstraint *customTop       = [NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.displayView attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.customButtonPosition.origin.y];
            NSLayoutConstraint *customLeft      = [NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.displayView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.customButtonPosition.origin.x];
            
            constraints = [NSArray arrayWithObjects:customWidth, customHeight, customTop, customLeft, nil];
        } break;
            
        default: break;
    }
    
    return constraints;
}

- (NSInteger)getButtonConstraintConstant {
    // Override button padding
    return 10;
}

- (CGSize)getButtonSize {
    // Override button size, if needed
    return self.buttonImage ? self.buttonImage.size : CGSizeMake(10, 10);
}

- (void)buttonTappedAction {
    // Override button action, if needed
    if (self.buttonTouchUpInsideBlock) {
        self.buttonTouchUpInsideBlock();
    }
}

@end
