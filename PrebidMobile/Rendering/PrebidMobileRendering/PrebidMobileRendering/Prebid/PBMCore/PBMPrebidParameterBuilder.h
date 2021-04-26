//
//  PBMPrebidParameterBuilder.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMParameterBuilderProtocol.h"

@class PBMAdUnitConfig;
@class PBMSDKConfiguration;
@class PBMTargeting;
@class PBMUserAgentService;

NS_ASSUME_NONNULL_BEGIN

@interface PBMPrebidParameterBuilder : NSObject <PBMParameterBuilder>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAdConfiguration:(PBMAdUnitConfig *)adConfiguration
                       sdkConfiguration:(PBMSDKConfiguration *)sdkConfiguration
                              targeting:(PBMTargeting *)targeting
                       userAgentService:(PBMUserAgentService *)userAgentService NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
