//
//  OXMFunctions+Testing.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMFunctions+Testing.h"

static id<OXMUIApplicationProtocol> _application;

@implementation OXMFunctions (Testing)

+ (id<OXMUIApplicationProtocol>)application {
    return _application;
}

+ (void)setApplication:(id<OXMUIApplicationProtocol>)application {
    _application = application;
}

@end
