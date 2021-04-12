//
//  OXAViewabilityEvent.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAViewabilityEvent.h"

@implementation OXAViewabilityEvent

- (instancetype)initWithExposureSatisfactionCheck:(OXAExposureSatisfactionCheck)exposureSatisfactionCheck
                        durationSatisfactionCheck:(OXADurationSatisfactionCheck)durationSatisfactionCheck
                                  onEventDetected:(OXMVoidBlock)onEventDetected
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
