//
//  PBMInterstitialLayoutConfigurator.m
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import "PBMInterstitialLayoutConfigurator.h"

@implementation PBMInterstitialLayoutConfigurator

+ (void)configurePropertiesWithAdConfiguration:(PBMAdConfiguration *)adConfiguration displayProperties:(PBMInterstitialDisplayProperties *)displayProperties {
    PBMInterstitialLayout layout = adConfiguration.interstitialLayout;
    if (layout && layout != PBMInterstitialLayoutUndefined) {
        displayProperties.interstitialLayout = layout;
        return;
    }
    
    displayProperties.interstitialLayout = [self calculateLayoutFromSize:adConfiguration.size];
}

+ (PBMInterstitialLayout)calculateLayoutFromSize:(CGSize)size {
    if ([self isPortrait:size]) {
        return PBMInterstitialLayoutPortrait;
    } else if ([self isLandscape:size]) {
        return PBMInterstitialLayoutLandscape;
    } else {
        return PBMInterstitialLayoutAspectRatio;
    }
}

+ (NSSet<NSValue *> *)portraitSizes {
    return [NSSet setWithObjects:
            [NSValue valueWithCGSize:CGSizeMake(270, 480)],
            [NSValue valueWithCGSize:CGSizeMake(300, 1050)],
            [NSValue valueWithCGSize:CGSizeMake(320, 480)],
            [NSValue valueWithCGSize:CGSizeMake(360, 480)],
            [NSValue valueWithCGSize:CGSizeMake(360, 640)],
            [NSValue valueWithCGSize:CGSizeMake(480, 640)],
            [NSValue valueWithCGSize:CGSizeMake(576, 1024)],
            [NSValue valueWithCGSize:CGSizeMake(720, 1280)],
            [NSValue valueWithCGSize:CGSizeMake(768, 1024)],
            [NSValue valueWithCGSize:CGSizeMake(960, 1280)],
            [NSValue valueWithCGSize:CGSizeMake(1080, 1920)],
            [NSValue valueWithCGSize:CGSizeMake(1440, 1920)],
            nil];
}

+ (NSSet<NSValue *> *)landscapeSizes {
    return [NSSet setWithObjects:
            [NSValue valueWithCGSize:CGSizeMake(480, 320)],
            [NSValue valueWithCGSize:CGSizeMake(480, 360)],
            [NSValue valueWithCGSize:CGSizeMake(1024, 768)],
            nil];
}

+ (BOOL)isPortrait:(CGSize)size {
    return [[self portraitSizes] containsObject:[NSValue valueWithCGSize:size]];
}

+ (BOOL)isLandscape:(CGSize)size {
    return [[self landscapeSizes] containsObject:[NSValue valueWithCGSize:size]];
}

@end
