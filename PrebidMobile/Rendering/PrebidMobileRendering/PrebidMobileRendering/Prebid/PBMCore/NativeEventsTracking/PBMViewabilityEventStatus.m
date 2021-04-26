//
//  PBMViewabilityEventStatus.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMViewabilityEventStatus.h"

@implementation PBMViewabilityEventStatus

- (instancetype)initWithViewabilityEvent:(PBMViewabilityEvent *)viewabilityEvent {
    if (!(self = [super init])) {
        return nil;
    }
    _viewabilityEvent = viewabilityEvent;
    return self;
}

@end
