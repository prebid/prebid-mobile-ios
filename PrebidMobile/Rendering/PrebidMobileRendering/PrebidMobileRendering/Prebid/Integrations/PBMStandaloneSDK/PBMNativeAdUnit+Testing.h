//
//  PBMNativeAdUnit+Testing.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAdUnit.h"
#import "PBMBaseAdUnit+Protected.h"

@class PBMSDKConfiguration;
@class PBMTargeting;
@protocol PBMServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeAdUnit ()

- (instancetype)initWithConfigID:(NSString *)configID
           nativeAdConfiguration:(PBMNativeAdConfiguration *)nativeAdConfiguration
                serverConnection:(id<PBMServerConnectionProtocol>)serverConnection
                sdkConfiguration:(PBMSDKConfiguration *)sdkConfiguration
                       targeting:(PBMTargeting *)targeting; // convenience(*)

- (instancetype)initWithConfigID:(NSString *)configID
           nativeAdConfiguration:(PBMNativeAdConfiguration *)nativeAdConfiguration
             bidRequesterFactory:(PBMBidRequesterFactoryBlock)bidRequesterFactory
                winNotifierBlock:(PBMWinNotifierBlock)winNotifierBlock; // designated

@end

NS_ASSUME_NONNULL_END
