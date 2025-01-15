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

import Foundation

struct TestCases {
    // GAM Original Api
    let gamOriginalDisplayBannerCase = "GAM (Original API) Display Banner 320x50"
    let gamOriginalNativeCase = "GAM (Original API) Native"
    let gamOriginalVideoBannerCase = "GAM (Original API) Video Banner 300x250"
    let gamOriginalDisplayInterstitialCase = "GAM (Original API) Display Interstitial 320x480"
    let gamOriginalVideoInterstitialCase = "GAM (Original API) Video Interstitial 320x480"
    let gamOriginalVideoRewardedCase = "GAM (Original API) Video Rewarded 320x480"
    let gamOriginalMultiformatInAppNativeCase = "GAM (Original API) Multiformat (Banner + Video + Native In-App)"
    let gamOriginalMultiformatNativeStylesCase = "GAM (Original API) Multiformat (Banner + Video + Native Styles)"
    
    // In-App Rendering Api
    let inAppDisplayBannerCase = "In-App Display Banner 320x50"
    let inAppDisplayBannerCustomRendererCase = "In-App Display Banner Plugin Renderer 320x50"
    let inAppNativeCase = "In-App Native"
    let inAppVideoBannerCase = "In-App Video Banner 300x250"
    let inAppDisplayInterstitialCase = "In-App Display Interstitial 320x480"
    let inAppDisplayInterstitialCustomRendererCase = "In-App Display Interstitial Plugin Renderer 320x480"
    let inAppVideoInterstitialCase = "In-App Video Interstitial 320x480"
    let inAppVideoRewardedCase = "In-App Video Rewarded 320x480"
    
    // GAM Rendering Api
    let gamDisplayBannerCase = "GAM Display Banner 320x50"
    let gamNativeCase = "GAM Native"
    let gamVideoBannerCase = "GAM Video Banner 300x250"
    let gamDisplayInterstitialCase = "GAM Display Interstitial 320x480"
    let gamVideoInterstitialCase = "GAM Video Interstitial 320x480"
    let gamVideoRewardedCase = "GAM Video Rewarded 320x480"
    
    // AdMob Rendering Api
    let adMobDisplayBannerCase = "AdMob Display Banner 320x50"
    let adMobNativeCase = "AdMob Native"
    let adMobVideoBannerCase = "AdMob Video Banner 300x250"
    let adMobDisplayInterstitialCase = "AdMob Display Interstitial 320x480"
    let adMobVideoInterstitialCase = "AdMob Video Interstitial 320x480"
    let adMobVideoRewardedCase = "AdMob Video Rewarded 320x480"
}
