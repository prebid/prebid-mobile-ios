//
//  OXAMoPubAdapterConfiguration.m
//  OXAMoPubTestAppObjC
//
//  Copyright © 2019 OpenX, Inc. All rights reserved.
//
#import <MoPub/MoPub.h>
#import "OXAMoPubAdapterConfiguration.h"
#import <OpenXApolloSDK/OXASDKConfiguration.h>
#import <OpenXApolloSDK/OXALogLevel.h>

static NSString * const OXA_MOPUB_ADAPTER_VERSION = @"0";

@implementation OXAMoPubAdapterConfiguration

#pragma mark - MPAdapterConfiguration

- (NSString *)adapterVersion {
    return [NSString stringWithFormat:@"%@.%@", OXASDKConfiguration.sdkVersion, OXA_MOPUB_ADAPTER_VERSION];
}

- (NSString *)biddingToken {
    return nil;
}

- (NSString *)moPubNetworkName {
    return @"OpenX";
}

- (NSString *)networkSdkVersion {
    return OXASDKConfiguration.sdkVersion;
}

-(void)initializeNetworkWithConfiguration:(NSDictionary<NSString *,id> *)configuration complete:(void (^)(NSError * _Nullable))complete {
    
    [OXASDKConfiguration initializeSDK];
    
    OXASDKConfiguration.singleton.logLevel = OXALogLevelInfo;
    OXASDKConfiguration.singleton.locationUpdatesEnabled = YES;
    
    // OpenX's ads include Open Measurement scripts that sometime require additional time for loading.
    OXASDKConfiguration.singleton.creativeFactoryTimeout = 15;
    
    MPLogInfo(@"OpenX Apollo SDK initialized succesfully.");
    
    if (complete != nil) {
        complete(nil);
    }
}

@end
