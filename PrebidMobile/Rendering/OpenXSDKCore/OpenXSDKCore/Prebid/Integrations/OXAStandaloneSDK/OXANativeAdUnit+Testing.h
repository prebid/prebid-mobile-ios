//
//  OXANativeAdUnit+Testing.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAdUnit.h"
#import "OXABaseAdUnit+Protected.h"

@class OXASDKConfiguration;
@class OXATargeting;
@protocol OXMServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface OXANativeAdUnit ()

- (instancetype)initWithConfigID:(NSString *)configID
           nativeAdConfiguration:(OXANativeAdConfiguration *)nativeAdConfiguration
                serverConnection:(id<OXMServerConnectionProtocol>)serverConnection
                sdkConfiguration:(OXASDKConfiguration *)sdkConfiguration
                       targeting:(OXATargeting *)targeting; // convenience(*)

- (instancetype)initWithConfigID:(NSString *)configID
           nativeAdConfiguration:(OXANativeAdConfiguration *)nativeAdConfiguration
             bidRequesterFactory:(OXABidRequesterFactoryBlock)bidRequesterFactory
                winNotifierBlock:(OXAWinNotifierBlock)winNotifierBlock; // designated

@end

NS_ASSUME_NONNULL_END
