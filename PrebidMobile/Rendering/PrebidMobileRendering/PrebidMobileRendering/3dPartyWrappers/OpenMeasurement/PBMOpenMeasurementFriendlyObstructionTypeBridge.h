//
//  PBMOpenMeasurementFriendlyObstructionTypeBridge.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMOpenMeasurementFriendlyObstructionPurpose.h"

@import OMSDK_Prebidorg;

NS_ASSUME_NONNULL_BEGIN

@interface PBMOpenMeasurementFriendlyObstructionTypeBridge : NSObject

+ (OMIDFriendlyObstructionType)obstructionTypeOfObstructionPurpose:(PBMOpenMeasurementFriendlyObstructionPurpose)friendlyObstructionPurpose;
+ (NSString *)describeFriendlyObstructionPurpose:(PBMOpenMeasurementFriendlyObstructionPurpose)friendlyObstructionPurpose;

@end

NS_ASSUME_NONNULL_END
