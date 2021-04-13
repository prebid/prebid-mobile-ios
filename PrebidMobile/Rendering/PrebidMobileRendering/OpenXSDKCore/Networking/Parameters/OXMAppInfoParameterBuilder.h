//
//  OXMAppInfoParameterBuilder.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OXATargeting.h"
#import "OXMBundleProtocol.h"
#import "OXMParameterBuilderProtocol.h"

@class OXASDKConfiguration;

NS_ASSUME_NONNULL_BEGIN
@interface OXMAppInfoParameterBuilder : NSObject <OXMParameterBuilder>

//Keys into Bundle info Dict
@property (class, readonly) NSString *bundleNameKey;
@property (class, readonly) NSString *bundleDisplayNameKey;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithBundle:(id<OXMBundleProtocol>)bundle
                     targeting:(OXATargeting *)targeting NS_DESIGNATED_INITIALIZER;

@end
NS_ASSUME_NONNULL_END
