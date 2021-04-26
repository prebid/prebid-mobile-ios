//
//  PBMPathBuilderBase.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMPathBuilder.h"

#pragma mark - Constants

static NSString * const PBMPathBuilderApiVersion  = @"1.0";
static NSString * const PBMPathBuilderRoute = @"ma";
static NSString * const PBMPathBuilderVideoRoute = @"v";
static NSString * const PBMPathBuilderSecureProtocol = @"https";
static NSString * const PBMPathBuilderAcjResource = @"acj";
static NSString * const PBMPathBuilderVASTResource = @"av";

#pragma mark - Implementation

@implementation PBMPathBuilder

#pragma mark - PBMURLPathBuilder

+ (NSString *)buildBaseURLForDomain:(NSString *)domain {
    return [NSString stringWithFormat:@"%@://%@",
            PBMPathBuilderSecureProtocol,
            domain];
}

+ (NSString *)buildURLPathForDomain:(NSString *)domain path:(NSString *)path {
    return [NSString stringWithFormat:@"%@://%@/%@/%@/",
            PBMPathBuilderSecureProtocol,
            domain,
            path,
            PBMPathBuilderApiVersion];
}

+ (NSString *)buildACJURLPathForDomain:(NSString *)domain {
    return [[PBMPathBuilder buildURLPathForDomain:domain path:PBMPathBuilderRoute] stringByAppendingString:PBMPathBuilderAcjResource];
}

+ (NSString *)buildVASTURLPathForDomain:(NSString *)domain {
    return [[PBMPathBuilder buildURLPathForDomain:domain path:PBMPathBuilderVideoRoute] stringByAppendingString:PBMPathBuilderVASTResource];
}

@end
