/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "PBMInterstitialLayoutConfigurator.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

@implementation PBMInterstitialLayoutConfigurator

+ (void)configurePropertiesWithAdConfiguration:(PBMAdConfiguration *)adConfiguration displayProperties:(PBMInterstitialDisplayProperties *)displayProperties {
    PBMInterstitialLayout layout = adConfiguration.interstitialLayout;
    if (layout && layout != PBMInterstitialLayoutUndefined) {
        displayProperties.interstitialLayout = layout;
        return;
    }
    
    displayProperties.interstitialLayout = [self calculateLayoutFromSize:adConfiguration.size];
}

//FIXME: - Need to figure out how to determine orientation properly. Autorotate is enabled for now.
+ (PBMInterstitialLayout)calculateLayoutFromSize:(CGSize)size {
    return PBMInterstitialLayoutAspectRatio;
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
