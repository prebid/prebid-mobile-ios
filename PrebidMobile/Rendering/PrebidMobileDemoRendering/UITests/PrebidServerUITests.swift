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

import XCTest

class PrebidServerUITests: AdsLoaderUITestCase {
    
    override func setUp() {
        useMockServerOnSetup = false
        super.setUp()
        
        switchToPrebidXServerIfNeeded()
    }

    // MARK: - Banner
    
    func testBanner() {
        checkBannerLoadResult(exampleName: "Banner 320x50 (In-App)")
    }
    
    func testInAppBanner_noBids() {
        checkBannerLoadResult(exampleName: "Banner 320x50 (In-App) [noBids]",
                              expectFailure: true)
    }
    
    func testGAMBanner() {
        checkBannerLoadResult(exampleName: "Banner 320x50 (GAM) [OK, AppEvent]")
    }
    
    func testGAMBanner_noBids_gamAd() {
        checkBannerLoadResult(exampleName: "Banner 320x50 (GAM) [noBids, GAM Ad]")
    }
    
    func testGAMBanner_VanillaPrebidOrder() {
        checkBannerLoadResult(exampleName: "Banner 320x50 (GAM) [Vanilla Prebid Order]")
    }
    
    func testMoPubBanner() {
        checkBannerLoadResult(exampleName: "Banner 320x50 (MoPub) [OK, OXB Adapter]",
                              adapterBased: true,
                              callbacks: mopubBannerCallbacks)
    }
    
    func testMoPubBanner_NoBids() {
        checkBannerLoadResult(exampleName: "Banner 320x50 (MoPub) [noBids, MoPub Ad]",
                              adapterBased: true,
                              callbacks: mopubBannerCallbacks)
    }
    
    func testMoPubBanner_VanillaPrebidOrder() {
           checkBannerLoadResult(exampleName: "Banner 320x50 (MoPub) [Vanilla Prebid Order]",
                                 adapterBased: true,
                                 callbacks: mopubBannerCallbacks)
    }
    
    // MARK: - MRAID
    
    func testBannerMRAID() {
        checkBannerLoadResult(exampleName: "MRAID 2.0: Resize (In-App)")
    }
    
    func testMRAID_Resize_GAM() {
        checkBannerLoadResult(exampleName: "MRAID 2.0: Resize (GAM)")
    }
    
    func testMRAID_Resize_MoPub() {
        checkBannerLoadResult(exampleName: "MRAID 2.0: Resize (MoPub)",
                                     adapterBased: true,
                                     callbacks: mopubBannerCallbacks)
    }
    
    // MARK: - Interstitials
    
    func testInterstitial_Display_320x480() {
        checkInterstitialLoadResult(exampleName: "Display Interstitial 320x480 (In-App)")
    }
    
    func testInAppInterstitial_Display_320x480_noBids() {
        checkInterstitialLoadResult(exampleName: "Display Interstitial 320x480 (In-App) [noBids]",
                                    expectFailure: true)
    }
    
    func testGAMInterstitial_Display() {
        checkInterstitialLoadResult(exampleName: "Display Interstitial 320x480 (GAM) [OK, AppEvent]")
    }
    
    func testGAMInterstitial_Display_320x480_noBids() {
        checkInterstitialLoadResult(exampleName: "Display Interstitial 320x480 (GAM) [noBids, GAM Ad]")
    }
    
    func testGAMInterstitial_Display_VanillaPrebidOrder() {
           checkInterstitialLoadResult(exampleName: "Display Interstitial 320x480 (GAM) [Vanilla Prebid Order]")
    }
    
    func testMoPubInterstitial_Display_320x480() {
        checkInterstitialLoadResult(exampleName: "Display Interstitial 320x480 (MoPub) [OK, OXB Adapter]",
                                    callbacks: mopubInterstitialCallbacks)
    }
    
    func testMoPubInterstitial_Display_320x480_NoBids() {
        checkInterstitialLoadResult(exampleName: "Display Interstitial 320x480 (MoPub) [noBids, MoPub Ad]",
                                    callbacks: mopubInterstitialCallbacks)
    }
    
    func testMoPubInterstitial_Display_VanillaPrebidOrder() {
        checkInterstitialLoadResult(exampleName: "Display Interstitial 320x480 (MoPub) [Vanilla Prebid Order]",
                                    callbacks: mopubInterstitialCallbacks)
    }
    
    // MARK: - Video
    
    func testVideo() {
        checkBannerLoadResult(exampleName: "Video Outstream with End Card (In-App)", video: true)
    }
    
    func testInAppVideo_noBids() {
        checkBannerLoadResult(exampleName: "Video Outstream (In-App) [noBids]",
                              video: true,
                              expectFailure: true)
    }
    
    func testGAMVideo_OK_AppEvent() {
        checkBannerLoadResult(exampleName: "Video Outstream with End Card (GAM) [OK, AppEvent]", video: true)
    }
    
    func testGAMVideo_noBids_gamAd() {
        checkBannerLoadResult(exampleName: "Video Outstream (GAM) [noBids, GAM Ad]", video: true)
    }
    
    // MARK: - Video Interstitials
    
    func testInAppInterstitial_Video_320x480_with_EndCard() {
        checkInterstitialLoadResult(exampleName: "Video Interstitial 320x480 with End Card (In-App)")
    }
    
    func testInAppInterstitial_Video_noBids() {
        checkInterstitialLoadResult(exampleName: "Video Interstitial 320x480 (In-App) [noBids]",
                                    expectFailure: true)
    }
    
    func testGAMInterstitial_Video_OK_AppEvent() {
        checkInterstitialLoadResult(exampleName: "Video Interstitial 320x480 (GAM) [OK, AppEvent]")
    }
    
    func testGAMInterstitial_Video_noBids_gamAd() {
        checkInterstitialLoadResult(exampleName: "Video Interstitial 320x480 (GAM) [noBids, GAM Ad]")
    }
    
    func testGAMInterstitial_Video_VanillaPrebidOrder() {
        checkInterstitialLoadResult(exampleName: "Video Interstitial 320x480 (GAM) [Vanilla Prebid Order]")
    }
    
    func testMoPubInterstitial_Video() {
        checkInterstitialLoadResult(exampleName: "Video Interstitial 320x480 (MoPub) [OK, OXB Adapter]",
                                    callbacks: mopubInterstitialCallbacks)
    }
    
    func testMoPubInterstitial_Video_NoBids() {
        checkInterstitialLoadResult(exampleName: "Video Interstitial 320x480 (MoPub) [noBids, MoPub Ad]",
                                    callbacks: mopubInterstitialCallbacks)
    }
    
    func testMoPubInterstitial_Video_VanillaPrebidOrder() {
        checkInterstitialLoadResult(exampleName: "Video Interstitial 320x480 (MoPub) [Vanilla Prebid Order]",
                                    callbacks: mopubInterstitialCallbacks)
    }
    
    // MARK: - Rewarded Video
    
    func testRewardedVideo() {
        checkRewardedLoadResult(exampleName: "Video Rewarded 320x480 (In-App)")
    }
    
    func testInAppRewarded_noBids() {
        checkRewardedLoadResult(exampleName: "Video Rewarded 320x480 (In-App) [noBids]",
                                expectFailure: true)
    }
    
    func testGAMRewarded() {
        checkRewardedLoadResult(exampleName: "Video Rewarded 320x480 (GAM) [OK, Metadata]")
    }
    
    func testGAMRewarded_noBids_gamAd() {
        checkRewardedLoadResult(exampleName: "Video Rewarded 320x480 (GAM) [noBids, GAM Ad]")
    }
    
    func testMoPubRewarded() {
        checkRewardedLoadResult(exampleName: "Video Rewarded 320x480 (MoPub) [OK, OXB Adapter]",
                                callbacks: mopubRewardedCallbacks)
    }
    
    func testMoPubRewarded_noBids() {
        checkRewardedLoadResult(exampleName: "Video Rewarded 320x480 (MoPub) [noBids, MoPub Ad]",
                                callbacks: mopubRewardedCallbacks)
    }
    
    func testMoPubRewarded_DeprecatedAPI() {
        checkRewardedLoadResult(exampleName: "[Deprecated API] Video Rewarded 320x480 (MoPub) [OK, OXB Adapter]",
                                callbacks: mopubRewardedCallbacks)
    }
    
    func testMoPubRewarded_noBids_DeprecatedAPI() {
        checkRewardedLoadResult(exampleName: "[Deprecated API] Video Rewarded 320x480 (MoPub) [noBids, MoPub Ad]",
                                callbacks: mopubRewardedCallbacks)
    }

    // MARK: - Native Styles
    
    //This test are temporary disabled, as the server returns:
    //"request.imp[0] uses native, but this bidder doesn't support it"
    func testBannerNativeStyle() {
        checkBannerLoadResult(exampleName: "Banner Native Styles")
    }
    
    func testGAMBannerNativeStyle_MRect() {
        checkBannerLoadResult(exampleName: "Banner Native Styles (GAM) [MRect]")
    }
    
    func testMoPubBannerNativeStyle_OK() {
        checkBannerLoadResult(exampleName: "Banner Native Styles (MoPub)",
                              adapterBased: true,
                              callbacks: mopubBannerCallbacks)
    }

}
