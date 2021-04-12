//
//  OXMCloseButtonDecorator.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMCloseButtonDecorator.h"
#import "OXMMRAIDConstants.h"

@implementation OXMCloseButtonDecorator

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isMRAID = NO;
        self.button.accessibilityIdentifier = @"OXM Close";
    }
    return self;
}

- (NSInteger)getButtonConstraintConstant {
    return self.isMRAID ? 0 : 25;
}

- (CGSize)getButtonSize {
    return self.isMRAID ? CGSizeMake(OXMMRAIDCloseButtonSize.WIDTH, OXMMRAIDCloseButtonSize.HEIGHT) : CGSizeMake(36, 36);
}

@end
