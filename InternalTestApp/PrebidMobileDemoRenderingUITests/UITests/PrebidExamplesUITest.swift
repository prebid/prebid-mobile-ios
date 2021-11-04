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

import UIKit

class PrebidExamplesUITest: AdsLoaderUITestCase {
    
    override func setUp() {
        useMockServerOnSetup = true
        super.setUp()
        
        switchToMockServerIfNeeded()
    }
    
    // MARK: - Banners (In-App)
    
    func testInAppBanner_Small_OK() {
        checkBannerLoadResult(exampleName: "Banner 320x50 (In-App)")
    }
    
    func testInAppBanner_Small_noBids() {
        checkBannerLoadResult(exampleName: "Banner 320x50 (In-App) [noBids]",
                              expectFailure: true)
    }
    
    func testInAppBanner_Medium() {
        checkBannerLoadResult(exampleName: "Banner 300x250 (In-App)")
    }
    
    func testInAppBanner_Large() {
        checkBannerLoadResult(exampleName: "Banner 728x90 (In-App)")
    }
    
    func testInAppBanner_Multisize() {
        checkBannerLoadResult(exampleName: "Banner Multisize (In-App)")
    }
    
    func testInAppBanner_Small_SKAdN() {
        checkBannerLoadResult(exampleName: "Banner 320x50 (In-App) [SKAdN]")
    }
    
    // MARK: - Banners (GAM)
    
    func testGAMBanner_Small_OK_AppEvent() {
        checkBannerLoadResult(exampleName: "Banner 320x50 (GAM) [OK, AppEvent]")
    }
    
    func testGAMBanner_Small_OK_gamAd() {
        checkBannerLoadResult(exampleName: "Banner 320x50 (GAM) [OK, GAM Ad]")
    }
    
    func testGAMBanner_Small_noBids_gamAd() {
        checkBannerLoadResult(exampleName: "Banner 320x50 (GAM) [noBids, GAM Ad]")
    }
    
    func testGAMBanner_Small_OK_Random() {
        checkBannerLoadResult(exampleName: "Banner 320x50 (GAM) [OK, Random]")
    }
    
    func testGAMBanner_Medium() {
        checkBannerLoadResult(exampleName: "Banner 300x250 (GAM)")
    }
    
    func testGAMBanner_Large() {
        checkBannerLoadResult(exampleName: "Banner 728x90 (GAM)")
    }
    
    func testGAMBanner_Multisize() {
        checkBannerLoadResult(exampleName: "Banner Multisize (GAM)")
    }
    
    // MARK: - Banners (MoPub)
    
    func testMoPubBanner_Small_OK() {
        checkBannerLoadResult(exampleName: "Banner 320x50 (MoPub) [OK, OXB Adapter]",
                              adapterBased: true,
                              callbacks: mopubBannerCallbacks)
    }
    
    func testMoPubBanner_Small_OK_Random() {
        checkBannerLoadResult(exampleName: "Banner 320x50 (MoPub) [OK, Random]",
                              adapterBased: true,
                              callbacks: mopubBannerCallbacks)
    }
    
    func testMoPubBanner_Small_NoBids() {
        checkBannerLoadResult(exampleName: "Banner 320x50 (MoPub) [noBids, MoPub Ad]",
                              adapterBased: true,
                              callbacks: mopubBannerCallbacks)
    }
    
    func testMoPubBanner_Medium() {
        checkBannerLoadResult(exampleName: "Banner 300x250 (MoPub)",
                              adapterBased: true,
                              callbacks: mopubBannerCallbacks)
    }
    
    func testMoPubBanner_Large() {
        checkBannerLoadResult(exampleName: "Banner 728x90 (MoPub)",
                              adapterBased: true,
                              callbacks: mopubBannerCallbacks)
    }
    
    func testMoPubBanner_Multisize() {
        checkBannerLoadResult(exampleName: "Banner Multisize (MoPub)",
                              adapterBased: true,
                              callbacks: mopubBannerCallbacks)
    }
    
    // MARK: - Interstitials (In-App)
    
    func testInAppInterstitial_Display_320x480() {
        checkInterstitialLoadResult(exampleName: "Display Interstitial 320x480 (In-App)")
    }
    
    func testInAppInterstitial_Display_320x480_noBids() {
        checkInterstitialLoadResult(exampleName: "Display Interstitial 320x480 (In-App) [noBids]",
                                    expectFailure: true)
    }
    
    func testInAppInterstitial_Display_Multisize() {
        checkInterstitialLoadResult(exampleName: "Display Interstitial Multisize (In-App)")
    }
    
    func testInAppInterstitial_Display_320x480_SKAdN() {
        checkInterstitialLoadResult(exampleName: "Display Interstitial 320x480 (In-App) [SKAdN]")
    }
    
    // MARK: - Video Interstitials (In-App)
    
    func testInAppInterstitial_Video_320x480() {
        checkInterstitialLoadResult(exampleName: "Video Interstitial 320x480 (In-App)")
    }
    
    func testInAppInterstitial_Video_320x480_with_EndCard() {
        checkInterstitialLoadResult(exampleName: "Video Interstitial 320x480 with End Card (In-App)")
    }
    
    func testInAppInterstitial_Video_noBids() {
        checkInterstitialLoadResult(exampleName: "Video Interstitial 320x480 (In-App) [noBids]",
                                    expectFailure: true)
    }
    
    func testInAppInterstitial_Video_Vertical() {
        checkInterstitialLoadResult(exampleName: "Video Interstitial Vertical (In-App)")
    }
    
    func testInAppInterstitial_Video_SkipOffset() {
        checkInterstitialLoadResult(exampleName: "Video Interstitial 320x480 SkipOffset (In-App)")
    }
    
    func testInAppInterstitial_Video_MP4() {
        checkInterstitialLoadResult(exampleName: "Video Interstitial 320x480 .mp4 (In-App)")
    }
    
    func testInAppInterstitial_Video_M4V() {
        checkInterstitialLoadResult(exampleName: "Video Interstitial 320x480 .m4v (In-App)")
    }
    
    func testInAppInterstitial_Video_MOV() {
        checkInterstitialLoadResult(exampleName: "Video Interstitial 320x480 .mov (In-App)")
    }
    
    func testInAppInterstitial_Video_320x480_SKAdN() {
        checkInterstitialLoadResult(exampleName: "Video Interstitial 320x480 (In-App) [SKAdN]")
    }
    
    // MARK: - Interstitials (GAM)
    
    func testGAMInterstitial_Display_AppEvent() {
        checkInterstitialLoadResult(exampleName: "Display Interstitial 320x480 (GAM) [OK, AppEvent]")
    }
    
    func testGAMInterstitial_Display_Random() {
        checkInterstitialLoadResult(exampleName: "Display Interstitial 320x480 (GAM) [OK, Random]")
    }
    
    func testGAMInterstitial_Display_320x480_noBids() {
        checkInterstitialLoadResult(exampleName: "Display Interstitial 320x480 (GAM) [noBids, GAM Ad]")
    }
    
    func testGAMInterstitial_Display_Multisize() {
        checkInterstitialLoadResult(exampleName: "Display Interstitial Multisize (GAM) [OK, AppEvent]")
    }
    
    // MARK: - Video Interstitials (GAM)
    
    func testGAMInterstitial_Video_OK_AppEvent() {
        checkInterstitialLoadResult(exampleName: "Video Interstitial 320x480 (GAM) [OK, AppEvent]")
    }
    
    func testGAMInterstitial_Video_OK_Random() {
        checkInterstitialLoadResult(exampleName: "Video Interstitial 320x480 (GAM) [OK, Random]")
    }
    
    func testGAMInterstitial_Video_noBids_gamAd() {
        checkInterstitialLoadResult(exampleName: "Video Interstitial 320x480 (GAM) [noBids, GAM Ad]")
    }
    
    // MARK: - Interstitials (MoPub)
    
    func testMoPubInterstitial_Display_320x480() {
        checkInterstitialLoadResult(exampleName: "Display Interstitial 320x480 (MoPub) [OK, OXB Adapter]",
                                    callbacks: mopubInterstitialCallbacks)
    }
    
    func testMoPubInterstitial_Display_320x480_Random() {
        checkInterstitialLoadResult(exampleName: "Display Interstitial 320x480 (MoPub) [OK, Random]",
                                    callbacks: mopubInterstitialCallbacks)
    }
    
    func testMoPubInterstitial_Display_320x480_NoBids() {
        checkInterstitialLoadResult(exampleName: "Display Interstitial 320x480 (MoPub) [noBids, MoPub Ad]",
                                    callbacks: mopubInterstitialCallbacks)
    }
    
    func testMoPubInterstitial_Display_Multisize() {
        checkInterstitialLoadResult(exampleName: "Display Interstitial Multisize (MoPub)",
                                    callbacks: mopubInterstitialCallbacks)
    }
    
    // MARK: - Video Interstitials (MoPub)
    
    func testMoPubInterstitial_Video() {
        checkInterstitialLoadResult(exampleName: "Video Interstitial 320x480 (MoPub) [OK, OXB Adapter]",
                                    callbacks: mopubInterstitialCallbacks)
    }
    
    func testMoPubInterstitial_Video_Random() {
        checkInterstitialLoadResult(exampleName: "Video Interstitial 320x480 (MoPub) [OK, Random]",
                                    callbacks: mopubInterstitialCallbacks)
    }
    
    func testMoPubInterstitial_Video_NoBids() {
        checkInterstitialLoadResult(exampleName: "Video Interstitial 320x480 (MoPub) [noBids, MoPub Ad]",
                                    callbacks: mopubInterstitialCallbacks)
    }
    
    // MARK: - Video
    
    func testInAppVideo() {
        checkBannerLoadResult(exampleName: "Video Outstream (In-App)", video: true)
    }
    
    func testInAppVideoWithEndCard() {
        checkBannerLoadResult(exampleName: "Video Outstream with End Card (In-App)", video: true)
    }
    
    func testInAppVideo_noBids() {
        checkBannerLoadResult(exampleName: "Video Outstream (In-App) [noBids]",
                              video: true,
                              expectFailure: true)
    }
    
    func testInAppVideo_SKAdN() {
        checkBannerLoadResult(exampleName: "Video Outstream (In-App) [SKAdN]", video: true)
    }
    
    func testGAMVideo_OK_AppEvent() {
        checkBannerLoadResult(exampleName: "Video Outstream (GAM) [OK, AppEvent]", video: true)
    }
    
    func testGAMVideo_OK_Random() {
        checkBannerLoadResult(exampleName: "Video Outstream (GAM) [OK, Random]", video: true)
    }
    func testGAMVideo_noBids_gamAd() {
        checkBannerLoadResult(exampleName: "Video Outstream (GAM) [noBids, GAM Ad]", video: true)
    }
    
    // MARK: - Rewarded Video
    
    func testInAppRewarded_320x480() {
        checkRewardedLoadResult(exampleName: "Video Rewarded 320x480 (In-App)")
    }
    
    func testInAppRewarded_320x480_noBids() {
        checkRewardedLoadResult(exampleName: "Video Rewarded 320x480 (In-App) [noBids]",
                                expectFailure: true)
    }
    
    func testInAppRewarded_320x480_noEndCard() {
        checkRewardedLoadResult(exampleName: "Video Rewarded 320x480 without End Card (In-App)")
    }
    
    func testInAppRewarded_480x320() {
        checkRewardedLoadResult(exampleName: "Video Rewarded 480x320 (In-App)")
    }
    
    func testGAMRewarded_Ok_Metadata() {
        checkRewardedLoadResult(exampleName: "Video Rewarded 320x480 (GAM) [OK, Metadata]")
    }
    
    func testGAMRewarded_Ok_Random() {
        checkRewardedLoadResult(exampleName: "Video Rewarded 320x480 (GAM) [OK, Random]")
    }
    
    func testGAMRewarded_noBids_gamAd() {
        checkRewardedLoadResult(exampleName: "Video Rewarded 320x480 (GAM) [noBids, GAM Ad]")
    }
    
    func testGAMRewarded_noEndCard_Ok_Metadata() {
        checkRewardedLoadResult(exampleName: "Video Rewarded 320x480 without End Card (GAM) [OK, Metadata]")
    }
    
    func testMoPubRewarded_Ok() {
        checkRewardedLoadResult(exampleName: "Video Rewarded 320x480 (MoPub) [OK, OXB Adapter]",
                                callbacks: mopubRewardedCallbacks)
    }
    
    func testMoPubRewarded_Ok_Random() {
        checkRewardedLoadResult(exampleName: "Video Rewarded 320x480 (MoPub) [OK, Random]",
                                callbacks: mopubRewardedCallbacks)
    }
    
    func testMoPubRewarded_noBids() {
        checkRewardedLoadResult(exampleName: "Video Rewarded 320x480 (MoPub) [noBids, MoPub Ad]",
                                callbacks: mopubRewardedCallbacks)
    }
    
    func testMoPubRewarded_noEndCard_Ok() {
        checkRewardedLoadResult(exampleName: "Video Rewarded 320x480 without End Card (MoPub) [OK, OXB Adapter]",
                                callbacks: mopubRewardedCallbacks)
    }
    
    func testMoPubRewarded_Ok_DeprecatedAPI() {
        checkRewardedLoadResult(exampleName: "[Deprecated API] Video Rewarded 320x480 (MoPub) [OK, OXB Adapter]",
                                callbacks: mopubRewardedCallbacks)
    }
    
    func testMoPubRewarded_Ok_Random_DeprecatedAPI() {
        checkRewardedLoadResult(exampleName: "[Deprecated API] Video Rewarded 320x480 (MoPub) [OK, Random]",
                                callbacks: mopubRewardedCallbacks)
    }
    
    func testMoPubRewarded_noBids_DeprecatedAPI() {
        checkRewardedLoadResult(exampleName: "[Deprecated API] Video Rewarded 320x480 (MoPub) [noBids, MoPub Ad]",
                                callbacks: mopubRewardedCallbacks)
    }
    
    func testMoPubRewarded_noEndCard_Ok_DeprecatedAPI() {
        checkRewardedLoadResult(exampleName: "[Deprecated API] Video Rewarded 320x480 without End Card (MoPub) [OK, OXB Adapter]",
                                callbacks: mopubRewardedCallbacks)
    }
    
    // MARK: - MRAID
    
    func testMRAID_Resize_InApp() {
        checkBannerLoadResult(exampleName: "MRAID 2.0: Resize (In-App)")
    }
    
    func testMRAID_Expand_InApp() {
        checkBannerLoadResult(exampleName: "MRAID 2.0: Expand - 1 Part (In-App)")
    }
    
    func testMRAID_Resize_GAM() {
        checkBannerLoadResult(exampleName: "MRAID 2.0: Resize (GAM)")
    }
    
    func testMRAID_Expand_GAM() {
        checkBannerLoadResult(exampleName: "MRAID 2.0: Expand - 1 Part (GAM)")
    }
    
    func testMRAID_Resize_MoPub() {
        checkBannerLoadResult(exampleName: "MRAID 2.0: Resize (MoPub)",
                                     adapterBased: true,
                                     callbacks: mopubBannerCallbacks)
    }
    
    func testMRAID_Expand_MoPub() {
        checkBannerLoadResult(exampleName: "MRAID 2.0: Expand - 1 Part (MoPub)",
                              adapterBased: true,
                              callbacks: mopubBannerCallbacks)
    }
    
    // MARK: - MRAID Video
    
    func testMRAID_Video_Interstitial_InApp() {
        checkInterstitialLoadResult(exampleName: "MRAID 2.0: Video Interstitial (In-App)")
    }
    
    func testMRAID_Video_Interstitial_GAM() {
        checkInterstitialLoadResult(exampleName: "MRAID 2.0: Video Interstitial (GAM)")
    }
    
    func testMRAID_Video_Interstitial_MoPub() {
        checkInterstitialLoadResult(exampleName: "MRAID 2.0: Video Interstitial (MoPub)",
                                    callbacks: mopubInterstitialCallbacks)
    }
    
    // MARK: - Banner Native Styles
    
    func testInAppBannerNativeStyleMap_OK() {
        checkBannerLoadResult(exampleName: "Banner Native Styles (In-App) [MAP]")
    }
    
    func testInAppBannerNativeStyleKeys_OK() {
        checkBannerLoadResult(exampleName: "Banner Native Styles (In-App) [KEYS]")
    }
    
    func testInAppBannerNativeStyle_NoAssets() {
        checkBannerLoadResult(exampleName: "Banner Native Styles No Assets (In-App)",
                              expectFailure: true)
    }
    
    func testGAMBannerNativeStyle_MRect_OK() {
        checkBannerLoadResult(exampleName: "Banner Native Styles (GAM) [MRect]")
    }
    
    func testGAMBannerNativeStyle_MRect_NoAssets() {
        checkBannerLoadResult(exampleName: "Banner Native Styles No Assets (GAM) [MRect]",
                              expectFailure: true)
    }
    
    func testGAMBannerNativeStyle_Fluid_OK() {
        checkBannerLoadResult(exampleName: "Banner Native Styles (GAM) [Fluid]")
    }
    
    func testMoPubBannerNativeStyle_OK() {
        checkBannerLoadResult(exampleName: "Banner Native Styles (MoPub)",
                              adapterBased: true,
                              callbacks: mopubBannerCallbacks)
    }
    
    func testMoPubBannerNativeStyle_NoAssets() {
        checkBannerLoadResult(exampleName: "Banner Native Styles No Assets (MoPub)",
                              adapterBased: true,
                              callbacks: mopubBannerCallbacks,
                              expectFailure: true)
    }
    
    // MARK: - Native Ads
    
    func testInAppNativeAd_OK() {
        checkNativeAdLoadResult(exampleName: "Native Ad (In-App)", successCallback: "getNativeAd success")
    }
    
    func testInAppNativeAd_Links() {
        checkNativeAdLoadResult(exampleName: "Native Ad Links (In-App)", successCallback: "getNativeAd success")
    }
    
    func testMoPubNativeAd_OK() {
        checkNativeAdLoadResult(exampleName: "Native Ad (MoPub) [OK, PBM Native AdAdapter]",
                                successCallback: "getNativeAd success")
    }
    
    func testMoPubNativeAdNib_OK() {
        checkNativeAdLoadResult(exampleName: "Native Ad (MoPub) [OK, PBM Native AdAdapter, Nib]",
                                successCallback: "getNativeAd success")
    }
    
    func testMoPubNativeAd_WithoutAdapters() {
        checkNativeAdLoadResult(exampleName: "Native Ad (MoPub) [OK, MPNativeAd]",
                                successCallback: "getNativeAd success")
    }
    
    func testMoPubNativeAd_noBids() {
        checkNativeAdLoadResult(exampleName: "Native Ad (MoPub) [noBids, MPNativeAd]",
                                successCallback: "getNativeAd success")
    }
    
    func testMoPubNativeAd_Video() {
        checkNativeAdLoadResult(exampleName: "Native Ad Video (MoPub) [OK, PBM Native AdAdapter]",
                                successCallback: "getNativeAd success")
    }
}
