//
//  OXAExternalURLOpenCallbacks.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAExternalURLOpenCallbacks.h"

@implementation OXAExternalURLOpenCallbacks

- (instancetype)initWithUrlOpenedCallback:(OXAURLOpenResultHandlerBlock)urlOpenedCallback
                  onClickthroughExitBlock:(nullable OXMVoidBlock)onClickthroughExitBlock
{
    if (!(self = [super init])) {
        return nil;
    }
    _urlOpenedCallback = [urlOpenedCallback copy];
    _onClickthroughExitBlock = [onClickthroughExitBlock copy];
    return self;
}

@end
