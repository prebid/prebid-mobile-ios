//
//  MPVASTAdVerifications.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVASTAdVerifications.h"

@implementation MPVASTAdVerifications

+ (NSDictionary *)modelMap {
    return @{
        @"verifications":      @[@"Verification", MPParseArrayOf(MPParseClass([MPVASTVerification class]))]
    };
}


@end
