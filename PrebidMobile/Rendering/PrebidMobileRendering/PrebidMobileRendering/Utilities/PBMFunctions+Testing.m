//
//  PBMFunctions+Testing.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMFunctions+Testing.h"

static id<PBMUIApplicationProtocol> _application;

@implementation PBMFunctions (Testing)

+ (id<PBMUIApplicationProtocol>)application {
    return _application;
}

+ (void)setApplication:(id<PBMUIApplicationProtocol>)application {
    _application = application;
}

@end
