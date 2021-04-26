//
//  PBMCloseButtonDecorator.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMCloseButtonDecorator.h"
#import "PBMMRAIDConstants.h"

@implementation PBMCloseButtonDecorator

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isMRAID = NO;
        self.button.accessibilityIdentifier = @"PBM Close";
    }
    return self;
}

- (NSInteger)getButtonConstraintConstant {
    return self.isMRAID ? 0 : 25;
}

- (CGSize)getButtonSize {
    return self.isMRAID ? CGSizeMake(PBMMRAIDCloseButtonSize.WIDTH, PBMMRAIDCloseButtonSize.HEIGHT) : CGSizeMake(36, 36);
}

@end
