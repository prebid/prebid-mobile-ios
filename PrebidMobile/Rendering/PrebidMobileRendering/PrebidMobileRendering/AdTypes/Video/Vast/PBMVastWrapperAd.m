//
//  PBMVastWrapperAd.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMVastWrapperAd.h"

@implementation PBMVastWrapperAd

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.depth = 0;
        self.followAdditionalWrappers = YES;
        self.allowMultipleAds = NO;
        self.fallbackOnNoAd = NO;
    }
    return self;
}

@end
