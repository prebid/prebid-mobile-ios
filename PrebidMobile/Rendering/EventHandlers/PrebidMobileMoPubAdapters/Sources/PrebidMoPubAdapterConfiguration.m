//
//  PBMMoPubAdapterConfiguration.m
//  PBMMoPubTestAppObjC
//
//  Copyright © 2019 OpenX, Inc. All rights reserved.
//
#import <MoPub.h>

#import <PrebidMobileRendering/PBMSDKConfiguration.h>
#import <PrebidMobileRendering/PBMLogLevel.h>

#import "PrebidMoPubAdapterConfiguration.h"

static NSString * const PREBID_MOPUB_ADAPTER_VERSION = @"0";

@implementation PrebidMoPubAdapterConfiguration

#pragma mark - MPAdapterConfiguration

- (NSString *)adapterVersion {
    return [NSString stringWithFormat:@"%@.%@", PBMSDKConfiguration.sdkVersion, PREBID_MOPUB_ADAPTER_VERSION];
}

- (NSString *)biddingToken {
    return nil;
}

- (NSString *)moPubNetworkName {
    return @"OpenX";
}

- (NSString *)networkSdkVersion {
    return PBMSDKConfiguration.sdkVersion;
}

-(void)initializeNetworkWithConfiguration:(NSDictionary<NSString *,id> *)configuration complete:(void (^)(NSError * _Nullable))complete {
    
    [PBMSDKConfiguration initializeSDK];
    
    PBMSDKConfiguration.singleton.logLevel = PBMLogLevelInfo;
    PBMSDKConfiguration.singleton.locationUpdatesEnabled = YES;
    
    // OpenX's ads include Open Measurement scripts that sometime require additional time for loading.
    PBMSDKConfiguration.singleton.creativeFactoryTimeout = 15;
    
    MPLogInfo(@"Prebid Mobile Rendering SDK initialized succesfully.");
    
    if (complete != nil) {
        complete(nil);
    }
}

@end
