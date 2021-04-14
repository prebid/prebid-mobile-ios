//
//  OXMOpenMeasurementFriendlyObstructionTypeBridge.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXMOpenMeasurementFriendlyObstructionPurpose.h"

@import OMSDK_Openx;

NS_ASSUME_NONNULL_BEGIN

@interface OXMOpenMeasurementFriendlyObstructionTypeBridge : NSObject

+ (OMIDFriendlyObstructionType)obstructionTypeOfObstructionPurpose:(OXMOpenMeasurementFriendlyObstructionPurpose)friendlyObstructionPurpose;
+ (NSString *)describeFriendlyObstructionPurpose:(OXMOpenMeasurementFriendlyObstructionPurpose)friendlyObstructionPurpose;

@end

NS_ASSUME_NONNULL_END
