//
//  OXMPathBuilderBase.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMPathBuilder.h"

#pragma mark - Constants

static NSString * const OXMPathBuilderApiVersion  = @"1.0";
static NSString * const OXMPathBuilderRoute = @"ma";
static NSString * const OXMPathBuilderVideoRoute = @"v";
static NSString * const OXMPathBuilderSecureProtocol = @"https";
static NSString * const OXMPathBuilderAcjResource = @"acj";
static NSString * const OXMPathBuilderVASTResource = @"av";

#pragma mark - Implementation

@implementation OXMPathBuilder

#pragma mark - OXMURLPathBuilder

+ (NSString *)buildBaseURLForDomain:(NSString *)domain {
    return [NSString stringWithFormat:@"%@://%@",
            OXMPathBuilderSecureProtocol,
            domain];
}

+ (NSString *)buildURLPathForDomain:(NSString *)domain path:(NSString *)path {
    return [NSString stringWithFormat:@"%@://%@/%@/%@/",
            OXMPathBuilderSecureProtocol,
            domain,
            path,
            OXMPathBuilderApiVersion];
}

+ (NSString *)buildACJURLPathForDomain:(NSString *)domain {
    return [[OXMPathBuilder buildURLPathForDomain:domain path:OXMPathBuilderRoute] stringByAppendingString:OXMPathBuilderAcjResource];
}

+ (NSString *)buildVASTURLPathForDomain:(NSString *)domain {
    return [[OXMPathBuilder buildURLPathForDomain:domain path:OXMPathBuilderVideoRoute] stringByAppendingString:OXMPathBuilderVASTResource];
}

@end
