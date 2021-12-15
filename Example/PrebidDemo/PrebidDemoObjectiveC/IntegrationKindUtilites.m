//
//  IntegrationKindUtilites.m
//  PrebidDemoObjectiveC
//
//  Created by Yuriy Velichko on 15.11.2021.
//  Copyright © 2021 Prebid. All rights reserved.
//

#import "IntegrationKindUtilites.h"
#import "IntegrationKind.h"


@implementation IntegrationKindUtilites

+ (NSArray *)IntegrationKindAllCases {
    return @[
        [NSNumber numberWithInteger:IntegrationKind_OriginalGAM],
        [NSNumber numberWithInteger:IntegrationKind_OriginalMoPub],
        [NSNumber numberWithInteger:IntegrationKind_OriginalAdMob],
        [NSNumber numberWithInteger:IntegrationKind_InApp],
        [NSNumber numberWithInteger:IntegrationKind_RenderingGAM],
        [NSNumber numberWithInteger:IntegrationKind_RenderingMoPub],
        [NSNumber numberWithInteger:IntegrationKind_RenderingAdMob]
    ];
}

+ (NSDictionary *)IntegrationKindDescr {
    return @{
        [NSNumber numberWithInteger:IntegrationKind_OriginalGAM]        : @"Original GAM",
        [NSNumber numberWithInteger:IntegrationKind_OriginalMoPub]      : @"Original MoPub",
        [NSNumber numberWithInteger:IntegrationKind_OriginalAdMob]      : @"Original AdMob",
        [NSNumber numberWithInteger:IntegrationKind_InApp]              : @"In-App",
        [NSNumber numberWithInteger:IntegrationKind_RenderingGAM]       : @"Rendering GAM",
        [NSNumber numberWithInteger:IntegrationKind_RenderingMoPub]     : @"Rendering MoPub",
        [NSNumber numberWithInteger:IntegrationKind_RenderingAdMob]     : @"Rendering AdMob"
    };
}

+ (NSArray *)IntegrationAdFormatAllCases {
    return @[
        [NSNumber numberWithInteger:IntegrationAdFormat_Banner],
        [NSNumber numberWithInteger:IntegrationAdFormat_Interstitial],
        [NSNumber numberWithInteger:IntegrationAdFormat_InterstitialVideo],
        [NSNumber numberWithInteger:IntegrationAdFormat_Rewarded],
        [NSNumber numberWithInteger:IntegrationAdFormat_NativeInApp]
    ];
}

+ (NSDictionary *)IntegrationAdFormatDescr {
    return @{
        [NSNumber numberWithInteger:IntegrationAdFormat_Banner]             : @"Banner",
        [NSNumber numberWithInteger:IntegrationAdFormat_Interstitial]       : @"Interstitial",
        [NSNumber numberWithInteger:IntegrationAdFormat_InterstitialVideo]  : @"Interstitial Video",
        [NSNumber numberWithInteger:IntegrationAdFormat_Rewarded]           : @"Rewarded",
        [NSNumber numberWithInteger:IntegrationAdFormat_NativeInApp]        : @"Native In-App"
    };
}

+ (NSArray *)IntegrationAdFormatFor:(IntegrationKind) integrationKind {
    return [IntegrationKindUtilites isRenderingIntegrationKind:integrationKind] ?
        [IntegrationKindUtilites IntegrationAdFormatRendering] :
        [IntegrationKindUtilites IntegrationAdFormatOriginal];
}

+ (NSArray *)IntegrationAdFormatOriginal {
    return @[
        [NSNumber numberWithInteger:IntegrationAdFormat_Banner],
        [NSNumber numberWithInteger:IntegrationAdFormat_Interstitial],
        [NSNumber numberWithInteger:IntegrationAdFormat_NativeInApp]
    ];
}
+ (NSArray *)IntegrationAdFormatRendering {
    return @[
        [NSNumber numberWithInteger:IntegrationAdFormat_Banner],
        [NSNumber numberWithInteger:IntegrationAdFormat_Interstitial],
        [NSNumber numberWithInteger:IntegrationAdFormat_InterstitialVideo],
        [NSNumber numberWithInteger:IntegrationAdFormat_Rewarded],
    ];
}

+ (BOOL)isRenderingIntegrationKind:(IntegrationKind) integrationKind {
    return
        integrationKind == IntegrationKind_InApp ||
        integrationKind == IntegrationKind_RenderingGAM ||
        integrationKind == IntegrationKind_RenderingMoPub ||
        integrationKind == IntegrationKind_RenderingAdMob;
}

@end
