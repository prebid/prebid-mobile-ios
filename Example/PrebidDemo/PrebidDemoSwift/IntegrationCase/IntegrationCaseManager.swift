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

import UIKit

/**
    Integration case title template - [IntegrationKind] [AdFormat] [Size]
    [IntegrationKind] - GAM (Original API), GAM, In-App, AdMob, MAX
    [AdFormat] - "Display Banner", "Video Banner", "Native Banner", "Display Interstitial", "Video Interstitial", "Video Rewarded", "Video In-stream", "Native"
    [Size] - size of ad, f.e. 320x50
 */

struct IntegrationCaseManager {
    
    static var allCases: [IntegrationCase] = [
        IntegrationCase(
            title: "GAM (Original API) Display Banner 320x50",
            integrationKind: .gamOriginal,
            adFormat: .displayBanner,
            configurationClosure: {
                GAMOriginalAPIDisplayBannerViewController()
            }
        ),
        
        IntegrationCase(
            title: "GAM (Original API) Video Banner 300x250",
            integrationKind: .gamOriginal,
            adFormat: .videoBanner,
            configurationClosure: {
                GAMOriginalAPIVideoBannerViewController(adSize: CGSize(width: 300, height: 250))
            }
        ),
        
        IntegrationCase(
            title: "GAM (Original API) Multiformat Banner 300x250",
            integrationKind: .gamOriginal,
            adFormat: .multiformat,
            configurationClosure: {
                GAMOriginalAPIMultiformatBannerViewController(adSize: CGSize(width: 300, height: 250))
            }
        ),
        
        IntegrationCase(
            title: "GAM (Original API) Display Interstitial 320x480",
            integrationKind: .gamOriginal,
            adFormat: .displayInterstitial,
            configurationClosure: {
                GAMOriginalAPIDisplayInterstitialViewController()
            }
        ),
        
        IntegrationCase(
            title: "GAM (Original API) Video Interstitial 320x480",
            integrationKind: .gamOriginal,
            adFormat: .videoInterstitial,
            configurationClosure: {
                GAMOriginalAPIVideoInterstitialViewController()
            }
        ),
        
        IntegrationCase(
            title: "GAM (Original API) Multiformat Interstitial 320x480",
            integrationKind: .gamOriginal,
            adFormat: .multiformat,
            configurationClosure: {
                GAMOriginalAPIMultiformatInterstitialViewController()
            }
        ),
        
        IntegrationCase(
            title: "GAM (Original API) Video Rewarded 320x480",
            integrationKind: .gamOriginal,
            adFormat: .videoRewarded,
            configurationClosure: {
                GAMOriginalAPIVideoRewardedViewController()
            }
        ),
        
        IntegrationCase(
            title: "GAM (Original API) Native",
            integrationKind: .gamOriginal,
            adFormat: .native,
            configurationClosure: {
                GAMOriginalAPINativeViewController()
            }
        ),
        
        IntegrationCase(
            title: "GAM (Original API) Native Banner",
            integrationKind: .gamOriginal,
            adFormat: .nativeBanner,
            configurationClosure: {
                GAMOriginalAPINativeBannerViewController()
            }
        ),
    
        IntegrationCase(
            title: "GAM (Original API) Video In-stream 320x480",
            integrationKind: .gamOriginal,
            adFormat: .videoInstream,
            configurationClosure: {
                GAMOriginalAPIVideoInstreamViewController()
            }
        ),
        
        IntegrationCase(
            title: "GAM (Original API) Multiformat (Banner + Video + Native In-App)",
            integrationKind: .gamOriginal,
            adFormat: .multiformat,
            configurationClosure: {
                GAMOriginalAPIMultiformatInAppNativeViewController(adSize: CGSize(width: 300, height: 250))
            }
        ),
        
        IntegrationCase(
            title: "GAM (Original API) Multiformat (Banner + Video + Native Styles)",
            integrationKind: .gamOriginal,
            adFormat: .multiformat,
            configurationClosure: {
                GAMOriginalAPIMultiformatNativeStylesViewController(adSize: CGSize(width: 300, height: 250))
            }
        ),
        
        IntegrationCase(
            title: "In-App Display Banner 320x50",
            integrationKind: .inApp,
            adFormat: .displayBanner,
            configurationClosure: {
                InAppDisplayBannerViewController()
            }
        ),
        
        IntegrationCase(
            title: "In-App Display Banner Plugin Renderer 320x50",
            integrationKind: .inApp,
            adFormat: .displayBanner,
            configurationClosure: {
                InAppDisplayBannerPluginRendererViewController()
            }
        ),
        
        IntegrationCase(
            title: "In-App Video Banner 300x250",
            integrationKind: .inApp,
            adFormat: .videoBanner,
            configurationClosure: {
                InAppVideoBannerViewController(adSize: CGSize(width: 300, height: 250))
            }
        ),
        
        IntegrationCase(
            title: "In-App Display Interstitial 320x480",
            integrationKind: .inApp,
            adFormat: .displayInterstitial,
            configurationClosure: {
                InAppDisplayInterstitialViewController()
            }
        ),
        
        IntegrationCase(
            title: "In-App Display Interstitial Plugin Renderer 320x480",
            integrationKind: .inApp,
            adFormat: .displayInterstitial,
            configurationClosure: {
                InAppDisplayInterstitialPluginRendererViewController()
            }
        ),
        
        IntegrationCase(
            title: "In-App Video Interstitial 320x480",
            integrationKind: .inApp,
            adFormat: .videoInterstitial,
            configurationClosure: {
                InAppVideoInterstitialViewController()
            }
        ),
        
        IntegrationCase(
            title: "In-App Video Interstitial Vertical 320x480",
            integrationKind: .inApp,
            adFormat: .videoInterstitial,
            configurationClosure: {
                InAppVideoInterstitialVerticalViewController()
            }
        ),
        
        IntegrationCase(
            title: "In-App Video Interstitial Landscape 320x480",
            integrationKind: .inApp,
            adFormat: .videoInterstitial,
            configurationClosure: {
                InAppVideoInterstitialLandscapeViewController()
            }
        ),
        
        IntegrationCase(
            title: "In-App Display Rewarded 320x480",
            integrationKind: .inApp,
            adFormat: .displayRewarded,
            configurationClosure: {
                InAppDisplayRewardedViewController()
            }
        ),
        
        IntegrationCase(
            title: "In-App Video Rewarded 320x480",
            integrationKind: .inApp,
            adFormat: .videoRewarded,
            configurationClosure: {
                InAppVideoRewardedViewController()
            }
        ),
        
        IntegrationCase(
            title: "In-App Native",
            integrationKind: .inApp,
            adFormat: .native,
            configurationClosure: {
                InAppNativeViewController()
            }
        ),
        
        IntegrationCase(
            title: "GAM Display Banner 320x50",
            integrationKind: .gam,
            adFormat: .displayBanner,
            configurationClosure: {
                GAMDisplayBannerViewController()
            }
        ),
        
        IntegrationCase(
            title: "GAM Video Banner 300x250",
            integrationKind: .gam,
            adFormat: .videoBanner,
            configurationClosure: {
                GAMVideoBannerViewController(adSize: CGSize(width: 300, height: 250))
            }
        ),
        
        IntegrationCase(
            title: "GAM Display Interstitial 320x480",
            integrationKind: .gam,
            adFormat: .displayInterstitial,
            configurationClosure: {
                GAMDisplayInterstitialViewController()
            }
        ),
        
        IntegrationCase(
            title: "GAM Video Interstitial 320x480",
            integrationKind: .gam,
            adFormat: .videoInterstitial,
            configurationClosure: {
                GAMVideoInterstitialViewController()
            }
        ),
        
        IntegrationCase(
            title: "GAM Display Rewarded 320x480",
            integrationKind: .gam,
            adFormat: .displayRewarded,
            configurationClosure: {
                GAMDisplayRewardedViewController()
            }
        ),
        
        IntegrationCase(
            title: "GAM Video Rewarded 320x480",
            integrationKind: .gam,
            adFormat: .videoRewarded,
            configurationClosure: {
                GAMVideoRewardedViewController()
            }
        ),
        
        IntegrationCase(
            title: "GAM Native",
            integrationKind: .gam,
            adFormat: .native,
            configurationClosure: {
                GAMNativeViewController()
            }
        ),
        
        IntegrationCase(
            title: "AdMob Display Banner 320x50",
            integrationKind: .adMob,
            adFormat: .displayBanner,
            configurationClosure: {
                AdMobDisplayBannerViewController()
            }
        ),
        
        IntegrationCase(
            title: "AdMob Video Banner 300x250",
            integrationKind: .adMob,
            adFormat: .videoBanner,
            configurationClosure: {
                AdMobVideoBannerViewController(adSize: CGSize(width: 300, height: 250))
            }
        ),
        
        IntegrationCase(
            title: "AdMob Display Interstitial 320x480",
            integrationKind: .adMob,
            adFormat: .displayInterstitial,
            configurationClosure: {
                AdMobDisplayInterstitialViewController()
            }
        ),
        
        IntegrationCase(
            title: "AdMob Video Interstitial 320x480",
            integrationKind: .adMob,
            adFormat: .videoInterstitial,
            configurationClosure: {
                AdMobVideoInterstitialViewController()
            }
        ),
        
        IntegrationCase(
            title: "AdMob Display Rewarded 320x480",
            integrationKind: .adMob,
            adFormat: .displayRewarded,
            configurationClosure: {
                AdMobDisplayRewardedViewController()
            }
        ),
        
        IntegrationCase(
            title: "AdMob Video Rewarded 320x480",
            integrationKind: .adMob,
            adFormat: .videoRewarded,
            configurationClosure: {
                AdMobVideoRewardedViewController()
            }
        ),
        
        IntegrationCase(
            title: "AdMob Native",
            integrationKind: .adMob,
            adFormat: .native,
            configurationClosure: {
                AdMobNativeViewController()
            }
        ),
        
        IntegrationCase(
            title: "MAX Display Banner 320x50",
            integrationKind: .max,
            adFormat: .displayBanner,
            configurationClosure: {
                MAXDisplayBannerViewController()
            }
        ),
        
        IntegrationCase(
            title: "MAX Video Banner 300x250",
            integrationKind: .max,
            adFormat: .videoBanner,
            configurationClosure: {
                MAXVideoBannerViewController(adSize: CGSize(width: 300, height: 250))
            }
        ),
        
        IntegrationCase(
            title: "MAX Display Interstitial 320x480",
            integrationKind: .max,
            adFormat: .displayInterstitial,
            configurationClosure: {
                MAXDisplayInterstitialViewController()
            }
        ),
        
        IntegrationCase(
            title: "MAX Video Interstitial 320x480",
            integrationKind: .max,
            adFormat: .videoInterstitial,
            configurationClosure: {
                MAXVideoInterstitialViewController()
            }
        ),
        
        IntegrationCase(
            title: "MAX Display Rewarded 320x480",
            integrationKind: .max,
            adFormat: .videoRewarded,
            configurationClosure: {
                MAXDisplayRewardedViewController()
            }
        ),
        
        IntegrationCase(
            title: "MAX Video Rewarded 320x480",
            integrationKind: .max,
            adFormat: .videoRewarded,
            configurationClosure: {
                MAXVideoRewardedViewController()
            }
        ),
        
        IntegrationCase(
            title: "MAX Native",
            integrationKind: .max,
            adFormat: .native,
            configurationClosure: {
                MAXNativeViewController()
            }
        ),
    ]
}
