//
//  OXAPrebidParameterBuilder.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXMParameterBuilderProtocol.h"

@class OXAAdUnitConfig;
@class OXASDKConfiguration;
@class OXATargeting;
@class OXMUserAgentService;

NS_ASSUME_NONNULL_BEGIN

@interface OXAPrebidParameterBuilder : NSObject <OXMParameterBuilder>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAdConfiguration:(OXAAdUnitConfig *)adConfiguration
                       sdkConfiguration:(OXASDKConfiguration *)sdkConfiguration
                              targeting:(OXATargeting *)targeting
                       userAgentService:(OXMUserAgentService *)userAgentService NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
