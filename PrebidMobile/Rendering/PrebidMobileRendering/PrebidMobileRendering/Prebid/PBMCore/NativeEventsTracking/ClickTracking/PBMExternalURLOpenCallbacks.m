//
//  PBMExternalURLOpenCallbacks.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMExternalURLOpenCallbacks.h"

@implementation PBMExternalURLOpenCallbacks

- (instancetype)initWithUrlOpenedCallback:(PBMURLOpenResultHandlerBlock)urlOpenedCallback
                  onClickthroughExitBlock:(nullable PBMVoidBlock)onClickthroughExitBlock
{
    if (!(self = [super init])) {
        return nil;
    }
    _urlOpenedCallback = [urlOpenedCallback copy];
    _onClickthroughExitBlock = [onClickthroughExitBlock copy];
    return self;
}

@end
