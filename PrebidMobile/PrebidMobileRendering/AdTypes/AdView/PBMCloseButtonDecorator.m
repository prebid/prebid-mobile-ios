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

#import "PBMCloseButtonDecorator.h"
#import "PBMMRAIDConstants.h"
#import "PBMConstants.h"

@implementation PBMCloseButtonDecorator

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isMRAID = NO;
        self.button.accessibilityIdentifier = @"PBM Close";
        self.closeButtonArea = PBMConstants.CLOSE_BUTTON_AREA_DEFAULT;
    }
    return self;
}

- (NSInteger)getButtonConstraintConstant {
    CGFloat btnConstraintConstant = (UIScreen.mainScreen.bounds.size.width * self.closeButtonArea.doubleValue) / 2;
    if (btnConstraintConstant > 30 || btnConstraintConstant < 5) {
        btnConstraintConstant = 15;
    }
    return self.isMRAID ? 0 : btnConstraintConstant;
}

- (CGSize)getButtonSize {
    CGFloat btnSizeValue = UIScreen.mainScreen.bounds.size.width * self.closeButtonArea.doubleValue;
    return CGSizeMake(btnSizeValue, btnSizeValue);
}

@end
