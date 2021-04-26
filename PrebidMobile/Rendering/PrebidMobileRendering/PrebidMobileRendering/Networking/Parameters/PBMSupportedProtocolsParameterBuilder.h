//
//  PBMSupportedProtocolsParameterBuilder.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PBMParameterBuilderProtocol.h"

@class PBMSDKConfiguration;

// Supported versions:
// MRAID: 3,5
// OpenMeasurement: 7

@interface PBMSupportedProtocolsParameterBuilder : NSObject <PBMParameterBuilder>

@property (class, readonly, nonnull) NSString *supportedVersionsParamKey;

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithSDKConfiguration:(nonnull PBMSDKConfiguration *)sdkConfiguration NS_DESIGNATED_INITIALIZER;

@end
