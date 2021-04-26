//
//  PBMUserConsentParameterBuilder.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMParameterBuilderProtocol.h"

@class PBMUserConsentDataManager;

/**
 @c PBMUserConsentParameterBuilder is responsible for enriching its provided
 @c PBMORTBBidRequest object with consent values to an ad request.
 */
@interface PBMUserConsentParameterBuilder : NSObject <PBMParameterBuilder>

/**
 Convenience initializer that uses the @c PBMUserConsentDataManager singleton.
 */
- (nonnull instancetype)init;

/**
 Initializer exposed primarily for dependency injection.
 */
- (nonnull instancetype)initWithUserConsentManager:(nullable PBMUserConsentDataManager *)userConsentManager NS_DESIGNATED_INITIALIZER;

@end
