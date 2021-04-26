//
//  PBMViewabilityEvent.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMViewabilityEvent.h"

@implementation PBMViewabilityEvent

- (instancetype)initWithExposureSatisfactionCheck:(PBMExposureSatisfactionCheck)exposureSatisfactionCheck
                        durationSatisfactionCheck:(PBMDurationSatisfactionCheck)durationSatisfactionCheck
                                  onEventDetected:(PBMVoidBlock)onEventDetected
{
    if (!(self = [super init])) {
        return nil;
    }
    _exposureSatisfactionCheck = [exposureSatisfactionCheck copy];
    _durationSatisfactionCheck = [durationSatisfactionCheck copy];
    _onEventDetected = [onEventDetected copy];
    return self;
}

@end
