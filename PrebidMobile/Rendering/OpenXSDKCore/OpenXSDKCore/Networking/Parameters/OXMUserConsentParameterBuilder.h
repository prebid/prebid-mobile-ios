//
//  OXMUserConsentParameterBuilder.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXMParameterBuilderProtocol.h"

@class OXMUserConsentDataManager;

/**
 @c OXMUserConsentParameterBuilder is responsible for enriching its provided
 @c OXMORTBBidRequest object with consent values to an ad request.
 */
@interface OXMUserConsentParameterBuilder : NSObject <OXMParameterBuilder>

/**
 Convenience initializer that uses the @c OXMUserConsentDataManager singleton.
 */
- (nonnull instancetype)init;

/**
 Initializer exposed primarily for dependency injection.
 */
- (nonnull instancetype)initWithUserConsentManager:(nullable OXMUserConsentDataManager *)userConsentManager NS_DESIGNATED_INITIALIZER;

@end
