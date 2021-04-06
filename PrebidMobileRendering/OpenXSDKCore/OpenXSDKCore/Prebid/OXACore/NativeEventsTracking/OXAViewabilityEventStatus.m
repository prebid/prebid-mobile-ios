//
//  OXAViewabilityEventStatus.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAViewabilityEventStatus.h"

@implementation OXAViewabilityEventStatus

- (instancetype)initWithViewabilityEvent:(OXAViewabilityEvent *)viewabilityEvent {
    if (!(self = [super init])) {
        return nil;
    }
    _viewabilityEvent = viewabilityEvent;
    return self;
}

@end
