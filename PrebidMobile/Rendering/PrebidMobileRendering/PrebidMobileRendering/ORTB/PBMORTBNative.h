//
//  PBMORTBNative.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBAbstract.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMORTBNative : PBMORTBAbstract

/// [Required]
/// Request payload complying with the Native Ad Specification.
@property (nonatomic, copy) NSString *request;

/// [Recommended]
/// Version of the Dynamic Native Ads API to which `request` complies; highly recommended for efficient parsing.
@property (nonatomic, copy, nullable) NSString *ver;

/// [Integer Array]
/// List of supported API frameworks for this impression. Refer to List 5.6. If an API is not explicitly listed, it is assumed not to be supported.
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *api;

/// [Integer Array]
/// Blocked creative attributes. Refer to List 5.3.
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *battr;

// Note: ext is not supported.
// Placeholder for exchange-specific extensions to OpenRTB.

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
