//
//  PBMAppInfoParameterBuilder.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PBMBundleProtocol.h"
#import "PBMParameterBuilderProtocol.h"

@class PrebidRenderingConfig;
@class PrebidRenderingTargeting;

NS_ASSUME_NONNULL_BEGIN
@interface PBMAppInfoParameterBuilder : NSObject <PBMParameterBuilder>

//Keys into Bundle info Dict
@property (class, readonly) NSString *bundleNameKey;
@property (class, readonly) NSString *bundleDisplayNameKey;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithBundle:(id<PBMBundleProtocol>)bundle
                     targeting:(PrebidRenderingTargeting *)targeting NS_DESIGNATED_INITIALIZER;

@end
NS_ASSUME_NONNULL_END
