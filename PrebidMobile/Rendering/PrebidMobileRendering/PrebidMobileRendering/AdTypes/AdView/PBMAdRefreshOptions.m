//
//  PBMAdRefreshOptions.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMAdRefreshOptions.h"

@implementation PBMAdRefreshOptions

- (instancetype)initWithType:(PBMAdRefreshType)type
                       delay:(NSInteger)delay {
    self = [super init];
    if (self) {
        self.type = type;
        self.delay = delay;
    }
    
    return self;
}


@end
