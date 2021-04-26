//
//  PBMVastAbstractAd.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMVastAbstractAd.h"

@implementation PBMVastAbstractAd

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sequence = 0;
        self.impressionURIs = [NSMutableArray array];
        self.errorURIs = [NSMutableArray array];
        self.creatives = [NSMutableArray array];
    }
    return self;
}

@end
