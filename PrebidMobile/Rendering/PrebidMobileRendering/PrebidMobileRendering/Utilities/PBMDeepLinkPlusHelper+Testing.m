//
//  PBMDeepLinkPlusHelper+Testing.m
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMDeepLinkPlusHelper+Testing.h"

static id<PBMUIApplicationProtocol> _application;
static id<PBMServerConnectionProtocol> _connection;

@implementation PBMDeepLinkPlusHelper (Testing)

+ (id<PBMUIApplicationProtocol>)application {
    return _application;
}

+ (void)setApplication:(id<PBMUIApplicationProtocol>)application {
    _application = application;
}

+ (id<PBMServerConnectionProtocol>)connection {
    return _connection;
}

+ (void)setConnection:(id<PBMServerConnectionProtocol>)connection {
    _connection = connection;
}

@end
