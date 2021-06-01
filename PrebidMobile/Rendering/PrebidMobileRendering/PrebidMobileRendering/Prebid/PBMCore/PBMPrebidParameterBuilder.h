//
//  PBMPrebidParameterBuilder.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMParameterBuilderProtocol.h"

@class AdUnitConfig;
@class PrebidRenderingConfig;
@class PrebidRenderingTargeting;
@class PBMUserAgentService;

NS_ASSUME_NONNULL_BEGIN

@interface PBMPrebidParameterBuilder : NSObject <PBMParameterBuilder>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAdConfiguration:(AdUnitConfig *)adConfiguration
                       sdkConfiguration:(PrebidRenderingConfig *)sdkConfiguration
                              targeting:(PrebidRenderingTargeting *)targeting
                       userAgentService:(PBMUserAgentService *)userAgentService NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
