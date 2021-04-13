//
//  OXMBasicParameterBuilder.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OXATargeting.h"
#import "OXMAdConfiguration.h"
#import "OXMParameterBuilderProtocol.h"
#import "OXASDKConfiguration.h"

NS_ASSUME_NONNULL_BEGIN
@interface OXMBasicParameterBuilder : NSObject <OXMParameterBuilder>

@property (class, readonly) NSString *platformKey;
@property (class, readonly) NSString *platformValue;
@property (class, readonly) NSString *allowRedirectsKey;
@property (class, readonly) NSString *allowRedirectsVal;
@property (class, readonly) NSString *sdkVersionKey;
@property (class, readonly) NSString *urlKey;
@property (class, readonly) NSString *rewardedVideoKey;
@property (class, readonly) NSString *rewardedVideoValue;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAdConfiguration:(OXMAdConfiguration *)adConfiguration
                       sdkConfiguration:(OXASDKConfiguration *)sdkConfiguration
                             sdkVersion:(NSString *)sdkVersion
                              targeting:(OXATargeting *)targeting NS_DESIGNATED_INITIALIZER;

@end
NS_ASSUME_NONNULL_END
