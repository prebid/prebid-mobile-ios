//
//  OXABidRequesterFactory.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXABidRequesterFactory.h"

#import "OXABidRequester.h"
#import "OXASDKConfiguration.h"
#import "OXATargeting.h"
#import "OXMServerConnection.h"

@implementation OXABidRequesterFactory

+ (OXABidRequesterFactoryBlock)requesterFactoryWithSingletons {
    return [self requesterFactoryWithConnection:[OXMServerConnection singleton]
                               sdkConfiguration:[OXASDKConfiguration singleton]
                                      targeting:[OXATargeting shared]];
}

+ (OXABidRequesterFactoryBlock)requesterFactoryWithConnection:(id<OXMServerConnectionProtocol>)connection
                                             sdkConfiguration:(OXASDKConfiguration *)sdkConfiguration
                                                    targeting:(OXATargeting *)targeting
{
    return ^id<OXABidRequesterProtocol> (OXAAdUnitConfig * adUnitConfig) {
        return [[OXABidRequester alloc] initWithConnection:connection
                                          sdkConfiguration:sdkConfiguration
                                                 targeting:targeting
                                       adUnitConfiguration:adUnitConfig];
    };
}

@end
