//
//  MPVASTJavaScriptResource.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVASTJavaScriptResource.h"

@implementation MPVASTJavaScriptResource

+ (NSDictionary *)modelMap {
    return @{
        @"apiFramework":    @"apiFramework",
        @"resourceUrl":     @[@"text", MPParseURLFromString()],
    };
}

@end
