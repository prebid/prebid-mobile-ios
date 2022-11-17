/*   Copyright 2019-2022 Prebid.org, Inc.
 
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

#import <Foundation/Foundation.h>
#import "IntegrationCaseManager.h"

#import "GAMOriginalAPIDisplayBannerViewController.h"
#import "GAMOriginalAPIVideoBannerViewController.h"
#import "GAMOriginalAPIDisplayInterstitialViewController.h"
#import "GAMOriginalAPIVideoInterstitialViewController.h"
#import "GAMOriginalAPIVideoRewardedViewController.h"
#import "GAMOriginalAPINativeBannerViewController.h"
#import "GAMOriginalAPINativeViewController.h"

#import "InAppDisplayBannerViewController.h"
#import "InAppVideoBannerViewController.h"
#import "InAppDisplayInterstitialViewController.h"
#import "InAppVideoInterstitialViewController.h"
#import "InAppVideoInterstitialVerticalViewController.h"
#import "InAppVideoInterstitialLandscapeViewController.h"
#import "InAppVideoRewardedViewController.h"
#import "InAppNativeViewController.h"

#import "GAMDisplayBannerViewController.h"
#import "GAMVideoBannerViewController.h"
#import "GAMDisplayInterstitialViewController.h"
#import "GAMVideoInterstitialViewController.h"
#import "GAMVideoRewardedViewController.h"

#import "AdMobDisplayBannerViewController.h"
#import "AdMobVideoBannerViewController.h"
#import "AdMobDisplayInterstitialViewController.h"
#import "AdMobVideoInterstitialViewController.h"
#import "AdMobVideoRewardedViewController.h"
#import "AdMobNativeViewController.h"

#import "MAXDisplayBannerViewController.h"
#import "MAXVideoBannerViewController.h"
#import "MAXDisplayInterstitialViewController.h"
#import "MAXVideoInterstitialViewController.h"
#import "MAXVideoRewardedViewController.h"
#import "MAXNativeViewController.h"

@implementation IntegrationCaseManager

+ (NSArray<IntegrationCase *> *)allCases {
    
    return
    [
        [NSArray alloc]
        initWithObjects:
            [
                [IntegrationCase alloc]
                initWithTitle:@"GAM (Original API) Display Banner 320x50"
                integrationKind:IntegrationKindGAMOriginal
                adFormat:AdFormatDisplayBanner
                configurationClosure:^UIViewController *{
                    return [GAMOriginalAPIDisplayBannerViewController new];
                }
            ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"GAM (Original API) Video Banner 300x250"
            integrationKind:IntegrationKindGAMOriginal
            adFormat:AdFormatVideoBanner
            configurationClosure:^UIViewController *{
                return [[GAMOriginalAPIVideoBannerViewController alloc] initWithAdSize:CGSizeMake(300, 250)];
            }
        ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"GAM (Original API) Display Interstitial 320x480"
            integrationKind:IntegrationKindGAMOriginal
            adFormat:AdFormatDisplayInterstitial
            configurationClosure:^UIViewController *{
                return [[GAMOriginalAPIDisplayInterstitialViewController alloc] init];
            }
        ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"GAM (Original API) Video Interstitial 320x480"
            integrationKind:IntegrationKindGAMOriginal
            adFormat:AdFormatVideoInterstitial
            configurationClosure:^UIViewController *{
                return [[GAMOriginalAPIVideoInterstitialViewController alloc] init];
            }
        ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"GAM (Original API) Video Rewarded 320x480"
            integrationKind:IntegrationKindGAMOriginal
            adFormat:AdFormatVideoRewarded
            configurationClosure:^UIViewController *{
                return [[GAMOriginalAPIVideoRewardedViewController alloc] init];
            }
        ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"GAM (Original API) Native Banner"
            integrationKind:IntegrationKindGAMOriginal
            adFormat:AdFormatNativeBanner
            configurationClosure:^UIViewController *{
                return [[GAMOriginalAPINativeBannerViewController alloc] init];
            }
        ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"GAM (Original API) Native"
            integrationKind:IntegrationKindGAMOriginal
            adFormat:AdFormatNative
            configurationClosure:^UIViewController *{
                return [[GAMOriginalAPINativeViewController alloc] init];
            }
        ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"In-App Display Banner 320x50"
            integrationKind:IntegrationKindInApp
            adFormat:AdFormatDisplayBanner
            configurationClosure:^UIViewController *{
                return [[InAppDisplayBannerViewController alloc] init];
            }
        ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"In-App Video Banner 300x250"
            integrationKind:IntegrationKindInApp
            adFormat:AdFormatVideoBanner
            configurationClosure:^UIViewController *{
                return [[InAppVideoBannerViewController alloc] initWithAdSize:CGSizeMake(300, 250)];
            }
        ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"In-App Display Interstitial 320x480"
            integrationKind:IntegrationKindInApp
            adFormat:AdFormatDisplayInterstitial
            configurationClosure:^UIViewController *{
                return [[InAppDisplayInterstitialViewController alloc] init];
            }
        ],
          
        [
            [IntegrationCase alloc]
            initWithTitle:@"In-App Video Interstitial 320x480"
            integrationKind:IntegrationKindInApp
            adFormat:AdFormatVideoInterstitial
            configurationClosure:^UIViewController *{
                return [[InAppVideoInterstitialViewController alloc] init];
            }
        ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"In-App Video Interstitial Vertical 320x480"
            integrationKind:IntegrationKindInApp
            adFormat:AdFormatVideoInterstitial
            configurationClosure:^UIViewController *{
                return [[InAppVideoInterstitialVerticalViewController alloc] init];
            }
        ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"In-App Video Interstitial Landscape 320x480"
            integrationKind:IntegrationKindInApp
            adFormat:AdFormatVideoInterstitial
            configurationClosure:^UIViewController *{
                return [[InAppVideoInterstitialLandscapeViewController alloc] init];
            }
        ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"In-App Video Rewarded 320x480"
            integrationKind:IntegrationKindInApp
            adFormat:AdFormatVideoRewarded
            configurationClosure:^UIViewController *{
                return [[InAppVideoRewardedViewController alloc] init];
            }
        ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"In-App Native"
            integrationKind:IntegrationKindInApp
            adFormat:AdFormatNative
            configurationClosure:^UIViewController *{
                return [[InAppNativeViewController alloc] init];
            }
        ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"GAM Display Banner 320x50"
            integrationKind:IntegrationKindGAM
            adFormat:AdFormatDisplayBanner
            configurationClosure:^UIViewController *{
                return [[GAMDisplayBannerViewController alloc] init];
            }
        ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"GAM Video Banner 300x250"
            integrationKind:IntegrationKindGAM
            adFormat:AdFormatVideoBanner
            configurationClosure:^UIViewController *{
                return [[GAMVideoBannerViewController alloc] initWithAdSize:CGSizeMake(300, 250)];
            }
        ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"GAM Display Interstitial 320x480"
            integrationKind:IntegrationKindGAM
            adFormat:AdFormatDisplayInterstitial
            configurationClosure:^UIViewController *{
                return [[GAMDisplayInterstitialViewController alloc] init];
            }
        ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"GAM Video Interstitial 320x480"
            integrationKind:IntegrationKindGAM
            adFormat:AdFormatVideoInterstitial
            configurationClosure:^UIViewController *{
                return [[GAMVideoInterstitialViewController alloc] init];
            }
        ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"GAM Video Rewarded 320x480"
            integrationKind:IntegrationKindGAM
            adFormat:AdFormatVideoRewarded
            configurationClosure:^UIViewController *{
                return [[GAMVideoRewardedViewController alloc] init];
            }
        ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"AdMob Display Banner 320x50"
            integrationKind:IntegrationKindAdMob
            adFormat:AdFormatDisplayBanner
            configurationClosure:^UIViewController *{
                return [[AdMobDisplayBannerViewController alloc] init];
            }
        ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"AdMob Video Banner 300x250"
            integrationKind:IntegrationKindAdMob
            adFormat:AdFormatVideoBanner
            configurationClosure:^UIViewController *{
                return [[AdMobVideoBannerViewController alloc] initWithAdSize:CGSizeMake(300, 250)];
            }
        ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"AdMob Display Interstitial 320x480"
            integrationKind:IntegrationKindAdMob
            adFormat:AdFormatDisplayInterstitial
            configurationClosure:^UIViewController *{
                return [[AdMobDisplayInterstitialViewController alloc] init];
            }
        ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"AdMob Video Interstitial 320x480"
            integrationKind:IntegrationKindAdMob
            adFormat:AdFormatVideoInterstitial
            configurationClosure:^UIViewController *{
                return [[AdMobVideoInterstitialViewController alloc] init];
            }
        ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"AdMob Video Rewarded 320x480"
            integrationKind:IntegrationKindAdMob
            adFormat:AdFormatVideoRewarded
            configurationClosure:^UIViewController *{
                return [[AdMobVideoRewardedViewController alloc] init];
            }
        ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"AdMob Native"
            integrationKind:IntegrationKindAdMob
            adFormat:AdFormatNative
            configurationClosure:^UIViewController *{
                return [[AdMobNativeViewController alloc] init];
            }
        ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"MAX Display Banner 320x50"
            integrationKind:IntegrationKindMAX
            adFormat:AdFormatDisplayBanner
            configurationClosure:^UIViewController *{
                return [[MAXDisplayBannerViewController alloc] init];
            }
        ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"MAX Video Banner 320x50"
            integrationKind:IntegrationKindMAX
            adFormat:AdFormatVideoBanner
            configurationClosure:^UIViewController *{
                return [[MAXVideoBannerViewController alloc] initWithAdSize:CGSizeMake(300, 250)];
            }
        ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"MAX Display Interstitial 320x480"
            integrationKind:IntegrationKindMAX
            adFormat:AdFormatDisplayInterstitial
            configurationClosure:^UIViewController *{
                return [[MAXDisplayInterstitialViewController alloc] init];
            }
        ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"MAX Video Interstitial 320x480"
            integrationKind:IntegrationKindMAX
            adFormat:AdFormatVideoInterstitial
            configurationClosure:^UIViewController *{
                return [[MAXVideoInterstitialViewController alloc] init];
            }
        ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"MAX Video Rewarded 320x480"
            integrationKind:IntegrationKindMAX
            adFormat:AdFormatVideoRewarded
            configurationClosure:^UIViewController *{
                return [[MAXVideoRewardedViewController alloc] init];
            }
        ],
        
        [
            [IntegrationCase alloc]
            initWithTitle:@"MAX Native"
            integrationKind:IntegrationKindMAX
            adFormat:AdFormatNative
            configurationClosure:^UIViewController *{
                return [[MAXNativeViewController alloc] init];
            }
        ],
        
        nil];
}

@end
