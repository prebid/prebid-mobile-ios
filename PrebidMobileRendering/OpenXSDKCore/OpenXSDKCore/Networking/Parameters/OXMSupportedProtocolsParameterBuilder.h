//
//  OXMSupportedProtocolsParameterBuilder.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OXMParameterBuilderProtocol.h"

@class OXASDKConfiguration;

// Supported versions:
// MRAID: 3,5
// OpenMeasurement: 7

@interface OXMSupportedProtocolsParameterBuilder : NSObject <OXMParameterBuilder>

@property (class, readonly, nonnull) NSString *supportedVersionsParamKey;

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithSDKConfiguration:(nonnull OXASDKConfiguration *)sdkConfiguration NS_DESIGNATED_INITIALIZER;

@end
