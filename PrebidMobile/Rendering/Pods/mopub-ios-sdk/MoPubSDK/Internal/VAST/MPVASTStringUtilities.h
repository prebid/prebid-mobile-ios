//
//  MPVASTStringUtilities.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPVASTStringUtilities : NSObject

#pragma mark - VAST Percentages

/**
 Queries if the string is a valid, non-negative percentage in the format `[0-100]%`.
 @param string Candidate duration string to query.
 @return `YES` if the string is non-negative and valid; otherwise `NO`.
 */
+ (BOOL)stringRepresentsNonNegativePercentage:(NSString * _Nullable)string;

/**
 Converts a string conforming to the format `[0-100]%` into an integer value. For example, 73% becomes 73.
 @note Decimal values will be truncated. For example 23.99 will become 23.
 @param string Candidate duration string to convert.
 @return The converted percentage if successful; otherwise 0.
 */
+ (NSInteger)percentageFromString:(NSString * _Nullable)string;

#pragma mark - VAST Duration

/**
 Queries if the string is a valid, non-negative duration in the format `HH:MM:SS.mmm` or a floating point number.
 @param string Candidate duration string to query.
 @return `YES` if the string is non-negative and valid; otherwise `NO`.
 */
+ (BOOL)stringRepresentsNonNegativeDuration:(NSString * _Nullable)string;

/**
 Converts a VAST duration string conforming to the format `HH:MM:SS.mmm` or a floating point number into a `NSTimeInterval` value.
 @param string Time interval string to convert.
 @return Numeric time interval representation of the string. If there was a parsing failure, this will return 0.
 */
+ (NSTimeInterval)timeIntervalFromDurationString:(NSString * _Nullable)string;

/**
 Converts a time interval into a VAST duration string conforming to the format `HH:MM:SS.mmm`.
 @param timeInterval Time interval to convert.
 @returns A VAST duration string in `HH:MM:SS.mmm`, or `00:00:00.000` if the time interval is negative.
 */
+ (NSString *)durationStringFromTimeInterval:(NSTimeInterval)timeInterval;

#pragma mark - Unavailable

// There is no initializer for this utility class.
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
