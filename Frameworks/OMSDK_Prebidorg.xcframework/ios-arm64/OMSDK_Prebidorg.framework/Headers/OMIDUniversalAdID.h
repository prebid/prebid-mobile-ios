//
//  OMIDUniversalAdID.h
//  AppVerificationLibrary
//
//  Created by Teodor Cristea on 31.03.2025.
//  Copyright © 2025 IAB Techlab. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Details about the UniversalAdID for the purpose of tracking ad creatives which will be supplied to the ad session.
 */
@interface OMIDPrebidorgUniversalAdID : NSObject

@property(nonatomic, readonly, nonnull) NSString *value;
@property(nonatomic, readonly, nonnull) NSString *idRegistry;

/**
 *  Initializes new UniversalAdID instance providing both value and idRegistry.
 *  The UniversalAdID's purpose is to identify an ad creative across different platforms throughout the lifecycle of an advertising campaign.
 *
 *  Both value and idRegistry are mandatory.
 *
 * @param value It is used to identify the unique creative identifier.
 * @param idRegistry It is used to identify the URL for the registry website where the unique creative ID is cataloged.
 * @return A new UniversalAdID instance, or nil if any of the parameters are either null or blank
 */
- (nullable instancetype)initWithValue:(nonnull NSString *)value
                            idRegistry:(nonnull NSString *)idRegistry
                                 error:(NSError *_Nullable *_Nullable)error;

+ (instancetype)new NS_UNAVAILABLE;
- (null_unspecified instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
