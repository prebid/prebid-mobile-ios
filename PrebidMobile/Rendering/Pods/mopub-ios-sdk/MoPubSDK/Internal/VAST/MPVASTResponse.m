//
//  MPVASTResponse.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVASTResponse.h"

@implementation MPVASTResponse

#pragma mark - MPVASTModel

+ (NSDictionary<NSString *, id> *)modelMap {
    return @{@"ads":        @[@"VAST.Ad", MPParseArrayOf(MPParseClass([MPVASTAd class]))],
             @"errorURLs":  @[@"VAST.Error.text", MPParseArrayOf(MPParseURLFromString())],
             @"version":    @"VAST.version"};
}

@end
