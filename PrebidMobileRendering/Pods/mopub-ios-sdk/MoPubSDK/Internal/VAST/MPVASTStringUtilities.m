//
//  MPVASTStringUtilities.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVASTStringUtilities.h"

// Expected format is a decimal number from 0-100 followed by the % sign.
static NSString * const kPercentageRegexString = @"^(\\d?\\d(\\.\\d*)?|100(?:\\.0*)?)%$";
static dispatch_once_t percentageRegexOnceToken;
static NSRegularExpression *percentageRegex;

// Expected format is either HH:mm:ss.mmm or simply a floating-point number.
static NSString * const kDurationRegexString = @"^(\\d{2}):([0-5]\\d):([0-5]\\d(?:\\.\\d{1,3})?)|(^[0-9]*\\.?[0-9]+$)";
static dispatch_once_t durationRegexOnceToken;
static NSRegularExpression *durationRegex;

@implementation MPVASTStringUtilities

#pragma mark - VAST Percentages

+ (BOOL)stringRepresentsNonNegativePercentage:(NSString * _Nullable)string {
    dispatch_once(&percentageRegexOnceToken, ^{
        percentageRegex = [NSRegularExpression regularExpressionWithPattern:kPercentageRegexString options:0 error:nil];
    });

    // No string, fast fail
    if (string.length == 0) {
        return NO;
    }

    NSArray *matches = [percentageRegex matchesInString:string options:0 range:NSMakeRange(0, [string length])];

    if (matches.count == 0) {
        return NO;
    }

    NSTextCheckingResult *match = matches[0];
    return (match.range.location != NSNotFound);
}



+ (NSInteger)percentageFromString:(NSString * _Nullable)string {
    dispatch_once(&percentageRegexOnceToken, ^{
        percentageRegex = [NSRegularExpression regularExpressionWithPattern:kPercentageRegexString options:0 error:nil];
    });

    if (string.length == 0) {
        return 0;
    }

    NSArray *matches = [percentageRegex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    if (matches.count > 0) {
        NSTextCheckingResult *match = matches[0];
        if (match.range.location == NSNotFound) {
            return 0;
        }

        return [[string substringWithRange:[match rangeAtIndex:1]] integerValue];
    } else {
        return 0;
    }
}

#pragma mark - VAST Duration

+ (BOOL)stringRepresentsNonNegativeDuration:(NSString * _Nullable)string {
    dispatch_once(&durationRegexOnceToken, ^{
        durationRegex = [NSRegularExpression regularExpressionWithPattern:kDurationRegexString options:0 error:nil];
    });

    // No string, fast fail
    if (string.length == 0) {
        return NO;
    }

    NSArray *matches = [durationRegex matchesInString:string options:0 range:NSMakeRange(0, [string length])];

    if (matches.count == 0) {
        return NO;
    }

    NSTextCheckingResult *match = matches[0];
    return (match.range.location != NSNotFound);
}

+ (NSTimeInterval)timeIntervalFromDurationString:(NSString * _Nullable)string {
    dispatch_once(&durationRegexOnceToken, ^{
        durationRegex = [NSRegularExpression regularExpressionWithPattern:kDurationRegexString options:0 error:nil];
    });

    if (string.length == 0) {
        return 0;
    }

    NSArray *matches = [durationRegex matchesInString:string options:0 range:NSMakeRange(0, [string length])];

    if (matches.count == 0) {
        return 0;
    }

    NSTextCheckingResult *match = matches[0];
    if (match.range.location == NSNotFound) {
        return 0;
    }

    // This is the case where the string is simply a floating-point number.
    if ([match rangeAtIndex:4].location != NSNotFound) {
        return [[string substringWithRange:[match rangeAtIndex:4]] doubleValue];
    }

    // Fail if hours, minutes, or seconds are missing.
    if ([match rangeAtIndex:1].location == NSNotFound ||
        [match rangeAtIndex:2].location == NSNotFound ||
        [match rangeAtIndex:3].location == NSNotFound) {
        return 0;
    }

    NSInteger hours = 0;
    NSInteger minutes = 0;
    double seconds = 0;

    hours = [[string substringWithRange:[match rangeAtIndex:1]] integerValue];
    minutes = [[string substringWithRange:[match rangeAtIndex:2]] integerValue];
    seconds = [[string substringWithRange:[match rangeAtIndex:3]] doubleValue];

    return hours * 60 * 60 + minutes * 60 + seconds;
}

+ (NSString *)durationStringFromTimeInterval:(NSTimeInterval)timeInterval {
    if (timeInterval < 0) {
        return @"00:00:00.000";
    }

    NSInteger flooredTimeInterval = (NSInteger)timeInterval;
    NSInteger hours = flooredTimeInterval / 3600;
    NSInteger minutes = (flooredTimeInterval / 60) % 60;
    NSTimeInterval seconds = fmod(timeInterval, 60);
    return [NSString stringWithFormat:@"%02ld:%02ld:%06.3f", (long)hours, (long)minutes, seconds];
}

@end
