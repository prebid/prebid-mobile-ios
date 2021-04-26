//
//  PBMCachedResponseInfo.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMCachedResponseInfo.h"

@implementation PBMCachedResponseInfo

- (instancetype)initWithResponseInfo:(PBMDemandResponseInfo *)responseInfo
                     expirationTimer:(id<PBMTimerInterface>)expirationTimer
{
    if (!(self = [super init])) {
        return nil;
    }
    _responseInfo = responseInfo;
    _expirationTimer = expirationTimer;
    return self;
}

@end
