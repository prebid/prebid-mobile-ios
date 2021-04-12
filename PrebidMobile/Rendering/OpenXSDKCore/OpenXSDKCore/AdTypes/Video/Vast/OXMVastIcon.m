//
//  OXMVastIcon.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMVastIcon.h"

@implementation OXMVastIcon

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.clickTrackingURIs = [NSMutableArray array];
    }
    return self;
}

@end
