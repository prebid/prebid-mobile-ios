//
//  PBMSKAdNetworksParameterBuilder.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PBMBundleProtocol.h"
#import "PBMParameterBuilderProtocol.h"

@class PrebidRenderingTargeting;

NS_ASSUME_NONNULL_BEGIN

@interface PBMSKAdNetworksParameterBuilder : NSObject <PBMParameterBuilder>

- (nonnull instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithBundle:(id<PBMBundleProtocol>)bundle targeting:(PrebidRenderingTargeting *)targeting NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
