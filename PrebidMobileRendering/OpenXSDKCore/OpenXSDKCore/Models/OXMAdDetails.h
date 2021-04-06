//
//  OXMAdDetails.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Provides info about received ad.
 */
NS_ASSUME_NONNULL_BEGIN
@interface OXMAdDetails : NSObject

/**
 Raw data returned for the ad request. 
 */
@property (nonatomic, copy, nullable) NSString *rawResponse;

/**
 Unique identifier of the ad, that can be used for managing and reporting ad quality issues.
 */
@property (nonatomic, copy, nullable) NSString *transactionId;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithRawResponse:(NSString *)rawResponse
                              transactionId:(NSString *)transactionId NS_DESIGNATED_INITIALIZER;

@end
NS_ASSUME_NONNULL_END
