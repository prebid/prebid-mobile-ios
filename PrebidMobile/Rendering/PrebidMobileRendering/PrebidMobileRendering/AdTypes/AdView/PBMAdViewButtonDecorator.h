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
