//
//  OXMDeepLinkPlusHelper+Testing.m
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXMDeepLinkPlusHelper+Testing.h"

static id<OXMUIApplicationProtocol> _application;
static id<OXMServerConnectionProtocol> _connection;

@implementation OXMDeepLinkPlusHelper (Testing)

+ (id<OXMUIApplicationProtocol>)application {
    return _application;
}

+ (void)setApplication:(id<OXMUIApplicationProtocol>)application {
    _application = application;
}

+ (id<OXMServerConnectionProtocol>)connection {
    return _connection;
}

+ (void)setConnection:(id<OXMServerConnectionProtocol>)connection {
    _connection = connection;
}

@end
