//
//  OXASKAdNetworksParameterBuilder.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OXATargeting.h"
#import "OXMBundleProtocol.h"
#import "OXMParameterBuilderProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXASKAdNetworksParameterBuilder : NSObject <OXMParameterBuilder>

- (nonnull instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithBundle:(id<OXMBundleProtocol>)bundle targeting:(OXATargeting *)targeting NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
