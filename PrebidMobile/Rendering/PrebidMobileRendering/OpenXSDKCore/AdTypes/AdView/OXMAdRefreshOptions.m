//
//  OXMAdRefreshOptions.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMAdRefreshOptions.h"

@implementation OXMAdRefreshOptions

- (instancetype)initWithType:(OXMAdRefreshType)type
                       delay:(NSInteger)delay {
    self = [super init];
    if (self) {
        self.type = type;
        self.delay = delay;
    }
    
    return self;
}


@end
