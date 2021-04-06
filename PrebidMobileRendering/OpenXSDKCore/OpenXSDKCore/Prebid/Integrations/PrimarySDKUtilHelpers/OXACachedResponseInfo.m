//
//  OXACachedResponseInfo.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXACachedResponseInfo.h"

@implementation OXACachedResponseInfo

- (instancetype)initWithResponseInfo:(OXADemandResponseInfo *)responseInfo
                     expirationTimer:(id<OXATimerInterface>)expirationTimer
{
    if (!(self = [super init])) {
        return nil;
    }
    _responseInfo = responseInfo;
    _expirationTimer = expirationTimer;
    return self;
}

@end
