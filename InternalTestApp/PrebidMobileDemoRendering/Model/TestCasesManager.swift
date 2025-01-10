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
import UIKit

import GoogleMobileAds
import PrebidMobileGAMEventHandlers

import PrebidMobile

let nativeStylesCreative = """
<html><body>
    <style type='text/css'>.sponsored-post {
    background-color: #fffdeb;
    font-family: sans-serif;
}

.content {
    overflow: hidden;
}

.thumbnail {
    width: 50px;
    height: 50px;
    float: left;
    margin: 0 20px 10px 0;
    background-size: cover;
}

h1 {
    font-size: 18px;
    margin: 0;
}

a {
    color: #0086b3;
    text-decoration: none;
}

p {
    font-size: 16px;
    color: #000;
    margin: 10px 0 10px 0;
}

.attribution {
    color: #000;
    font-size: 9px;
    font-weight: bold;
    display: inline-block;
    letter-spacing: 2px;
    background-color: #ffd724;
    border-radius: 2px;
    padding: 4px;
}</style>
<div class="sponsored-post">
    <div class="thumbnail">
        <img src="hb_native_icon" alt="hb_native_icon" width="50" height="50"></div>
    <div class="content">
        <h1><p>hb_native_title</p></h1>
        <p>hb_native_body</p>
        <a target="_blank" href="hb_native_linkurl" class="pb-click">hb_native_cta</a>
        <div class="attribution">hb_native_brand</div>
    </div>
    <img src="hb_native_image" alt="hb_native_image" width="320" height="50">
</div>
<script src="https://cdn.jsdelivr.net/npm/prebid-universal-creative@latest/dist/native-trk.js"></script>
<script>
  let pbNativeTagData = {};
  pbNativeTagData.pubUrl = "%%PATTERN:url%%";
  pbNativeTagData.targetingMap = %%PATTERN:TARGETINGMAP%%;

  // if not DFP, use these params
  pbNativeTagData.adId = "%%PATTERN:hb_adid%%";
  pbNativeTagData.cacheHost = "%%PATTERN:hb_cache_host%%";
  pbNativeTagData.cachePath = "%%PATTERN:hb_cache_path%%";
  pbNativeTagData.uuid = "%%PATTERN:hb_cache_id%%";
  pbNativeTagData.env = "%%PATTERN:hb_env%%";
  pbNativeTagData.hbPb = "%%PATTERN:hb_pb%%";

  window.pbNativeTag.startTrackers(pbNativeTagData);
</script>
</body>
</html>
""";

//NOTE: there is no pbNativeTagData.targetingMap = %%PATTERN:TARGETINGMAP%%; in this creative
let nativeStylesCreativeKeys = """
<html><body>
    <style type='text/css'>.sponsored-post {
    background-color: #fffdeb;
    font-family: sans-serif;
}

.content {
    overflow: hidden;
}

.thumbnail {
    width: 50px;
    height: 50px;
    float: left;
    margin: 0 20px 10px 0;
    background-size: cover;
}

h1 {
    font-size: 18px;
    margin: 0;
}

a {
    color: #0086b3;
    text-decoration: none;
}

p {
    font-size: 16px;
    color: #000;
    margin: 10px 0 10px 0;
}

.attribution {
    color: #000;
    font-size: 9px;
    font-weight: bold;
    display: inline-block;
    letter-spacing: 2px;
    background-color: #ffd724;
    border-radius: 2px;
    padding: 4px;
}</style>
<div class="sponsored-post">
    <div class="thumbnail">
        <img src="hb_native_icon" alt="hb_native_icon" width="50" height="50"></div>
    <div class="content">
        <h1><p>hb_native_title</p></h1>
        <p>hb_native_body</p>
        <a target="_blank" href="hb_native_linkurl" class="pb-click">hb_native_cta</a>
        <div class="attribution">hb_native_brand</div>
    </div>
    <img src="hb_native_image" alt="hb_native_image" width="320" height="50">
</div>
<script src="https://cdn.jsdelivr.net/npm/prebid-universal-creative@latest/dist/native-trk.js"></script>
<script>
  let pbNativeTagData = {};
  pbNativeTagData.pubUrl = "%%PATTERN:url%%";

  // if not DFP, use these params
  pbNativeTagData.adId = "%%PATTERN:hb_adid%%";
  pbNativeTagData.cacheHost = "%%PATTERN:hb_cache_host%%";
  pbNativeTagData.cachePath = "%%PATTERN:hb_cache_path%%";
  pbNativeTagData.uuid = "%%PATTERN:hb_cache_id%%";
  pbNativeTagData.env = "%%PATTERN:hb_env%%";
  pbNativeTagData.hbPb = "%%PATTERN:hb_pb%%";

  window.pbNativeTag.startTrackers(pbNativeTagData);
</script>
</body>
</html>
""";

struct TestCaseManager {
    
    // {"configId": ["7e2c753a-2aad-49fb-b3b3-9b18018feb67": params1, "0e04335b-c39a-41f8-8f91-24ff13767dcc": params2]}
    private static var customORTBParams: [String: [String: [String: Any]]] = [:]
    // MARK: - Public Methods
    
    let testCases = TestCaseManager.prebidExamples
    
    mutating func parseCustomOpenRTB(openRTBString: String) {
        guard let data = openRTBString.data(using: .utf8) else { return }
        guard let jsonArray = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [Any] else { return }
        
        for param in jsonArray {
            guard let dictParam = param as? [String:Any],
                let openRtb = dictParam["openRtb"] as? [String: Any] else { continue }
            
            if let configId = dictParam["configId"] as? String {
                TestCaseManager.customORTBParams["configId", default: [:]][configId] = openRtb
            }
        }
    }
    
    /*
    EXTRA_OPEN_RTB "[ { "auid":"537454411","openRtb":{ "auid":"537454411", "age":23, "url":"https://url.com", "crr":"carrier",  "ip":"127.0.0.1", "xid":"007", "gen":"MALE", "buyerid":"buyerid", "publisherName": "publisherName", "customdata":"customdata", "keywords":"keyword1,keyword2", "geo":{ "lat":1.0, "lon":2.0 }, "ext":{ "key1":"string", "key2":1, "object":{ "inner":"value" } } } } ]"
    */
    static func updateUserData(_ openRtb: [String: Any]) {
        let targeting = Targeting.shared
        
        if let age = openRtb["age"] as? Int {
            targeting.yearOfBirth = age
        }
        
        if let value = openRtb["url"] as? String {
            targeting.storeURL = value
        }
        
        if let value = openRtb["gen"] as? String {
            targeting.userGender = TestCaseManager.strToGender(value)
        }
        
        if let value = openRtb["buyerid"] as? String {
            targeting.buyerUID = value
        }
        if let value = openRtb["xid"] as? String {
            targeting.userID = value
        }
        if let value = openRtb["publisherName"] as? String {
            targeting.publisherName = value
        }
        
        if let value = openRtb["keywords"] as? String {
            Targeting.shared.addUserKeyword(value)
        }
        if let value = openRtb["customdata"] as? String {
            targeting.userCustomData = value
        }
        
        if let geo = openRtb["geo"] as? [String: Double] {
            if let lat = geo["lat"], let lon = geo["lon"] {
                targeting.setLatitude(lat, longitude: lon)
            }
        }
        if let dictExt = openRtb["ext"] as? [String : AnyHashable] {
            targeting.userExt = dictExt
        }
    }
    
    // MARK: - Private Methods
    
    // MARK: - --== PREBID ==--
    
    private static let prebidExamples: [TestCase] = {
        return [
            
            // MARK: ---- Banner (Original API)
            
            TestCase(title: "Banner 320x50 (GAM Original) [OK, PUC]",
                     tags: [.banner, .originalAPI, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                         
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                
                let bannerController = PrebidOriginalAPIDisplayBannerController(rootController: adapterVC)
                bannerController.adSize = CGSize(width: 320, height: 50)
                        
                bannerController.prebidConfigId = "prebid-ita-banner-320-50";
                bannerController.adUnitID = "/21808260008/prebid_demo_app_original_api_banner"
                         
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (GAM Original) [NO SKAdN]",
                     tags: [.banner, .originalAPI, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                         
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                Targeting.shared.sourceapp = "InternalTestApp"
                
                let bannerController = PrebidOriginalAPIDisplayBannerController(rootController: adapterVC)
                bannerController.adSize = CGSize(width: 320, height: 50)
                        
                bannerController.prebidConfigId = "prebid-ita-banner-320-50";
                bannerController.adUnitID = "/21808260008/prebid_demo_app_original_api_banner"
                         
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 300x250 (GAM Original) [OK, PUC]",
                     tags: [.banner, .originalAPI, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                         
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                
                let bannerController = PrebidOriginalAPIDisplayBannerController(rootController: adapterVC)
                bannerController.adSize = CGSize(width: 300, height: 250)
                        
                bannerController.prebidConfigId = "prebid-ita-banner-300-250"
                bannerController.adUnitID = "/21808260008/prebid_demo_app_original_api_banner_300x250_order"
                         
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 728x90 (GAM Original) [OK, PUC]",
                     tags: [.banner, .originalAPI, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                         
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                
                let bannerController = PrebidOriginalAPIDisplayBannerController(rootController: adapterVC)
                bannerController.adSize = CGSize(width: 728, height: 90)
                bannerController.gamSizes = [GADAdSizeLeaderboard]
                bannerController.prebidConfigId = "prebid-demo-banner-728-90"
                bannerController.adUnitID = "/21808260008/prebid_demo_app_original_api_banner_728x90"
                         
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner Multisize (GAM Original) [OK, PUC]",
                     tags: [.banner, .originalAPI, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                         
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                
                let bannerController = PrebidOriginalAPIDisplayBannerController(rootController: adapterVC)
                bannerController.adSize = CGSize(width: 728, height: 90)
                bannerController.gamSizes = [GADAdSizeLeaderboard, GADAdSizeBanner]
                bannerController.prebidConfigId = "prebid-demo-banner-multisize"
                bannerController.adUnitID = "/21808260008/prebid_demo_app_original_api_banner_multisize"
                         
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Video Outstream (GAM Original) [OK, PUC]",
                     tags: [.banner, .originalAPI, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                         
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                
                let bannerController = PrebidOriginalAPIVideoBannerController(rootController: adapterVC)
                bannerController.adSize = CGSize(width: 300, height: 250)
                bannerController.prebidConfigId = "prebid-ita-video-outstream-original-api"
                bannerController.adUnitID = "/21808260008/prebid-demo-original-api-video-banner"   
                         
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Multiformat Banner (GAM Original) [OK, PUC]",
                     tags: [.multiformat, .originalAPI, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                         
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                
                let bannerController = PrebidOriginalAPIMultiformatBannerController(rootController: adapterVC)
                bannerController.adSize = CGSize(width: 300, height: 250)
                    
                let configIds = ["prebid-ita-banner-300-250", "prebid-ita-video-outstream-original-api"]
                bannerController.prebidConfigId = configIds.randomElement()!
                bannerController.adUnitID = "/21808260008/prebid-demo-original-banner-multiformat"
                         
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            // MARK: ---- Interstitial (Original API)
            
            TestCase(title: "Display Interstitial 320x480 (GAM Original) [OK, PUC]",
                     tags: [.interstitial, .originalAPI, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                         
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let interstitialController = PrebidOriginalAPIDisplayInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "prebid-ita-display-interstitial-320-480"
                interstitialController.adUnitID = "/21808260008/prebid-demo-app-original-api-display-interstitial"
                         
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial 320x480 (GAM Original) [OK, PUC]",
                     tags: [.interstitial, .originalAPI, .server, .video],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                         
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let interstitialController = PrebidOriginalAPIVideoInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "prebid-ita-video-interstitial-320-480-original-api"
                interstitialController.adUnitID = "/21808260008/prebid-demo-app-original-api-video-interstitial"
                         
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Rewarded 320x480 (GAM Original) [OK, PUC]",
                     tags: [.interstitial, .originalAPI, .server, .video],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                         
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let interstitialController = PrebidOriginalAPIVideoRewardedController(rootController: adapterVC)
                interstitialController.prebidConfigId = "prebid-ita-video-rewarded-320-480-original-api"
                interstitialController.adUnitID = "/21808260008/prebid-demo-app-original-api-video-interstitial"
                         
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Multiformat Interstitial 320x480 (GAM Original) [OK, PUC]",
                     tags: [.multiformat, .originalAPI, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                         
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let interstitialController = PrebidOriginalAPIMultiformatInterstitialController(rootController: adapterVC)
                         
                let configIds = ["prebid-ita-display-interstitial-320-480", "prebid-ita-video-interstitial-320-480-original-api"]
                interstitialController.prebidConfigId = configIds.randomElement()!
                interstitialController.adUnitID = "/21808260008/prebid-demo-intestitial-multiformat"
                         
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            
            // MARK: ---- Prebid Universal Creative Tests
            
            TestCase(title: "Prebid Universal Creative (GAM)",
                     tags: [.banner, .originalAPI, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                
                let bannerController = PrebidUniversalCreativeTestingGAMController(rootController: adapterVC)
                bannerController.adSize = CGSize(width: 300, height: 250)
                bannerController.gamAdUnitID = "/21808260008/puc-testing-secure-banner-300x250"
                         
                adapterVC.setup(adapter: bannerController)
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Prebid Universal Creative (WebView)",
                     tags: [.banner, .originalAPI, .server],
                     exampleVCStoryboardID: "PrebidUniversalCreativeTestingWebViewController",
                     configurationClosure: { vc in }),
            
            // MARK: ---- Native (Original API)
            
            TestCase(title: "Native Banner (GAM Original) [OK, PUC]",
                     tags: [.native, .originalAPI, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                         
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let nativeController = PrebidOriginalAPINativeBannerController(rootController: adapterVC)
                nativeController.adUnitID = "/21808260008/prebid-demo-original-native-styles"
                nativeController.prebidConfigId = "prebid-ita-banner-native-styles"
                nativeController.nativeAssets = .defaultNativeRequestAssets
                nativeController.eventTrackers = .defaultNativeEventTrackers
                         
                adapterVC.setup(adapter: nativeController)
                setupCustomParams(for: nativeController.prebidConfigId)
            }),
            
            TestCase(title: "Native In-App (GAM Original) [OK, PUC]",
                     tags: [.native, .originalAPI, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                         
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let nativeController = PrebidOriginalAPINativeController(rootController: adapterVC)
                nativeController.setupNativeAdView(NativeAdViewBox())
                         
                nativeController.adUnitID = "/21808260008/apollo_custom_template_native_ad_unit"
                nativeController.prebidConfigId = "prebid-ita-banner-native-styles"
                nativeController.nativeAssets = .defaultNativeRequestAssets
                nativeController.eventTrackers = .defaultNativeEventTrackers
                         
                adapterVC.setup(adapter: nativeController)
                setupCustomParams(for: nativeController.prebidConfigId)
            }),
            
            // MARK: ---- In-Stream (Original API)
            
            TestCase(title: "Instream Video (GAM Original) [OK, PUC]",
                     tags: [.instream, .originalAPI, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                         
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let instreamController = PrebidOriginalAPIVideoInstreamViewController(rootController: adapterVC)
                instreamController.videoContentURL = "https://storage.googleapis.com/gvabox/media/samples/stock.mp4"
                instreamController.prebidConfigId = "prebid-demo-video-interstitial-320-480-original-api"
                instreamController.gamAdUnitVideo = "/21808260008/prebid_demo_app_instream"
                         
                adapterVC.setup(adapter: instreamController)
                setupCustomParams(for: instreamController.prebidConfigId)
            }),
            
            
            // MARK: ---- Multiformat (Original API)
            
            TestCase(title: "Multiformat (Banner + Video + In-App Native) (GAM Original)",
                     tags: [.multiformat, .originalAPI, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                         
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let multiformatController = PrebidOriginalAPIMultiformatInAppNativeController(rootController: adapterVC)
                multiformatController.bannerAdSize = CGSize(width: 300, height: 250)
                multiformatController.adUnitID = "/21808260008/prebid-demo-multiformat"
                adapterVC.setup(adapter: multiformatController)
            }),
            
            TestCase(title: "Multiformat (Banner + Video + Native Styles) (GAM Original)",
                     tags: [.multiformat, .originalAPI, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                         
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let multiformatController = PrebidOriginalAPIMultiformatNativeStylesController(rootController: adapterVC)
                multiformatController.adSize = CGSize(width: 300, height: 250)
                multiformatController.adUnitID = "/21808260008/prebid-demo-multiformat-native-styles"
                multiformatController.gamSizes = [GADAdSizeFluid, GADAdSizeBanner, GADAdSizeMediumRectangle]
                adapterVC.setup(adapter: multiformatController)
            }),
        
            // MARK: ---- Banner (In-App) ----
            
            TestCase(title: "Banner 320x50 (In-App)",
                     tags: [.banner, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                        
                bannerController.prebidConfigId = "prebid-ita-banner-320-50";
                        
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (In-App, Custom Renderer)",
                     tags: [.banner, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                
                let bannerController = CustomRendererBannerController(rootController: adapterVC)
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                bannerController.prebidConfigId = "prebid-demo-display-banner-320-50-custom-ad-view-renderer"
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 Server-Side Creative Factory Timeout (In-App)",
                     tags: [.banner, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                Prebid.shared.prebidServerAccountId = "prebid-stored-request-sdk-config"
                
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                        
                bannerController.prebidConfigId = "prebid-ita-banner-320-50"
                
                bannerController.testPBSSDKConfig = true
                        
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner Events 320x50 (In-App)",
                     tags: [.banner, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                Prebid.shared.prebidServerAccountId = "prebid-stored-request-enabled-events"
                
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                        
                bannerController.prebidConfigId = "prebid-ita-banner-320-50";
                        
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (In-App) [noBids]",
                     tags: [.banner, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                        
                bannerController.prebidConfigId = "prebid-demo-no-bids"
                        
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (In-App) [Items]",
                     tags: [.banner, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "prebid-demo-banner-items"
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (In-App) [New Tab]",
                     tags: [.banner, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                        
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "prebid-demo-banner-newtab"
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (In-App) [Incorrect VAST]",
                     tags: [.banner, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                        
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "prebid-demo-banner-incorrect-vast"
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (In-App) [DeepLink+]",
                     tags: [.banner, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "prebid-demo-banner-deeplink"
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (In-App) [Scrollable]",
                     tags: [.banner, .inapp, .server],
                     exampleVCStoryboardID: "ScrollableAdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "prebid-ita-banner-320-50"
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 300x250 (In-App)",
                     tags: [.banner, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                        
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "prebid-ita-banner-300-250"
                bannerController.adSizes = [CGSize(width: 300, height: 250)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 728x90 (In-App)",
                     tags: [.banner, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "prebid-demo-banner-728-90"
                bannerController.adSizes = [CGSize(width: 728, height: 90)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner Multisize (In-App)",
                     tags: [.banner, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "prebid-demo-banner-multisize"
                bannerController.adSizes = [CGSize(width: 320, height: 50), CGSize(width: 728, height: 90)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (In-App) ATS",
                     tags: [.banner, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                        
                       
                                       
                Targeting.shared.eids = [
                    [
                        "source" : "liveramp.com",
                        "uids" : [
                            [
                                "id": "XY1000bIVBVah9ium-sZ3ykhPiXQbEcUpn4GjCtxrrw2BRDGM"
                            ]
                        ]
                    ]
                ]
                        
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "prebid-ita-banner-320-50"
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            // NOTE: works only with InternalTestApp-Skadn target
            TestCase(title: "Banner 320x50 (In-App) [SKAdN]",
                     tags: [.banner, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                Targeting.shared.sourceapp = "InternalTestApp"
                         
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "prebid-ita-banner-320-50-skadn"
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            // MARK: ---- Banner (GAM) ----
            
            TestCase(title: "Banner 320x50 (GAM) [OK, AppEvent]",
                     tags: [.banner, .gam, .server, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
                gamBannerController.gamAdUnitId = "/21808260008/prebid_oxb_320x50_banner"
                gamBannerController.validAdSizes = [GADAdSizeBanner]
                        
                gamBannerController.prebidConfigId = "prebid-ita-banner-320-50"
                        
                adapterVC.setup(adapter: gamBannerController)
                        
                setupCustomParams(for: gamBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 Events (GAM) [OK, AppEvent]",
                     tags: [.banner, .gam, .server, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                Prebid.shared.prebidServerAccountId = "prebid-stored-request-enabled-events"
                         
                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
                gamBannerController.gamAdUnitId = "/21808260008/prebid_oxb_320x50_banner"
                gamBannerController.validAdSizes = [GADAdSizeBanner]
                        
                gamBannerController.prebidConfigId = "prebid-ita-banner-320-50"
                        
                adapterVC.setup(adapter: gamBannerController)
                        
                setupCustomParams(for: gamBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (GAM) [OK, GAM Ad]",
                     tags: [.banner, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
                gamBannerController.prebidConfigId = "prebid-ita-banner-320-50"
                gamBannerController.gamAdUnitId = "/21808260008/prebid_oxb_320x50_banner_static"
                gamBannerController.validAdSizes = [GADAdSizeBanner]
                adapterVC.setup(adapter: gamBannerController)
                        
                setupCustomParams(for: gamBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (GAM) [noBids, GAM Ad]",
                     tags: [.banner, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)

                gamBannerController.prebidConfigId = "prebid-demo-no-bids"
                gamBannerController.gamAdUnitId = "/21808260008/prebid_oxb_320x50_banner_static"
                gamBannerController.validAdSizes = [GADAdSizeBanner]
                adapterVC.setup(adapter: gamBannerController)
                        
                setupCustomParams(for: gamBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (GAM) [OK, Random]",
                     tags: [.banner, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
                gamBannerController.prebidConfigId = "prebid-ita-banner-320-50"
                gamBannerController.gamAdUnitId = "/21808260008/prebid_oxb_320x50_banner_random"
                gamBannerController.validAdSizes = [GADAdSizeBanner]
                adapterVC.setup(adapter: gamBannerController)
                        
                setupCustomParams(for: gamBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (GAM) [Random, Respective]",
                     tags: [.banner, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
                gamBannerController.prebidConfigId = "prebid-ita-banner-320-50"
                gamBannerController.gamAdUnitId = "/21808260008/prebid_oxb_320x50_banner"
                gamBannerController.validAdSizes = [GADAdSizeBanner]
                adapterVC.setup(adapter: gamBannerController)
                        
                setupCustomParams(for: gamBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 300x250 (GAM)",
                     tags: [.banner, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
                gamBannerController.prebidConfigId = "prebid-ita-banner-300-250"
                gamBannerController.gamAdUnitId = "/21808260008/prebid_oxb_300x250_banner"
                gamBannerController.validAdSizes = [GADAdSizeMediumRectangle]
                adapterVC.setup(adapter: gamBannerController)
                        
                setupCustomParams(for: gamBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 728x90 (GAM)",
                     tags: [.banner, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
                gamBannerController.prebidConfigId = "prebid-demo-banner-728-90"
                gamBannerController.gamAdUnitId = "/21808260008/prebid_oxb_728x90_banner"
                gamBannerController.validAdSizes = [GADAdSizeLeaderboard]
                adapterVC.setup(adapter: gamBannerController)
                        
                setupCustomParams(for: gamBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner Multisize (GAM)",
                     tags: [.banner, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
                gamBannerController.prebidConfigId = "prebid-demo-banner-multisize"
                gamBannerController.gamAdUnitId = "/21808260008/prebid_oxb_multisize_banner"
                gamBannerController.validAdSizes = [GADAdSizeBanner, GADAdSizeLeaderboard]
                adapterVC.setup(adapter: gamBannerController)
                        
                setupCustomParams(for: gamBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (GAM) [Vanilla Prebid Order]",
                     tags: [.banner, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                        
                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
                gamBannerController.prebidConfigId = "prebid-ita-banner-320-50"
                gamBannerController.gamAdUnitId = "/21808260008/prebid_android_300x250_banner"
                gamBannerController.validAdSizes = [GADAdSizeMediumRectangle]
                adapterVC.setup(adapter: gamBannerController)
                        
                setupCustomParams(for: gamBannerController.prebidConfigId)
            }),
            

            // MARK: ---- Interstitial (In-App) ----
            
            TestCase(title: "Display Interstitial 320x480 (In-App)",
                     tags: [.interstitial, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.adFormats = [.banner]
                interstitialController.prebidConfigId = "prebid-ita-display-interstitial-320-480"
                 
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Display Interstitial 320x480 (In-App, Custom Renderer)",
                     tags: [.interstitial, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let interstitialController = CustomRendererInterstitialController(rootController: adapterVC)
                interstitialController.adFormats = [.banner]
                interstitialController.prebidConfigId = "prebid-demo-display-interstitial-320-480-custom-interstitial-renderer"
                 
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Display Interstitial 320x480 (In-App) [noBids]",
                     tags: [.interstitial, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.adFormats = [.banner]
                interstitialController.prebidConfigId = "prebid-demo-no-bids"
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Display Interstitial 320x480 (In-App) [Presentation]",
                     tags: [.interstitial, .inapp, .server],
                     exampleVCStoryboardID: "PrebidPresentationViewController",
                     configurationClosure: { vc in
                guard let presentationVC = vc as? PrebidPresentationViewController else {
                    return
                }
                presentationVC.adFormats = [.banner]
                presentationVC.prebidConfigId = "prebid-ita-display-interstitial-320-480"
                        
                setupCustomParams(for: presentationVC.prebidConfigId)
            }),
            
            TestCase(title: "Display Interstitial Multisize (In-App)",
                     tags: [.interstitial, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.adFormats = [.banner]
                interstitialController.prebidConfigId = "prebid-demo-display-interstitial-multisize"
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            // NOTE: works only with InternalTestApp-Skadn target
            TestCase(title: "Display Interstitial 320x480 (In-App) [SKAdN]",
                     tags: [.interstitial, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                Targeting.shared.sourceapp = "InternalTestApp"
                         
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.adFormats = [.banner]
                interstitialController.prebidConfigId = "prebid-demo-display-interstitial-320-480-skadn"
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            // MARK: ---- Multiformat Interstitial (In-App)
            
            TestCase(title: "MultiBid Video Interstitial 320x480 (In-App)",
                     tags: [.interstitial, .video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)

                interstitialController.prebidConfigId = "prebid-demo-interstitial-multiformat"
                adapterVC.setup(adapter: interstitialController)
                         
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Multiformat Interstitial 320x480 (In-App)",
                     tags: [.interstitial, .video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)

                let configIds = ["prebid-ita-display-interstitial-320-480", "prebid-ita-video-interstitial-320-480"]
                interstitialController.prebidConfigId = configIds.randomElement()!

                adapterVC.setup(adapter: interstitialController)
                         
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            // MARK: ---- Interstitial (GAM) ----
            
            TestCase(title: "Display Interstitial 320x480 (GAM) [OK, AppEvent]",
                     tags: [.interstitial, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamInterstitialController = PrebidGAMInterstitialController(rootController: adapterVC)
                gamInterstitialController.adFormats = [.banner]
                gamInterstitialController.gamAdUnitId = "/21808260008/prebid_oxb_html_interstitial"
                        
                gamInterstitialController.prebidConfigId = "prebid-ita-display-interstitial-320-480"
                
                adapterVC.setup(adapter: gamInterstitialController)
                        
                setupCustomParams(for: gamInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Display Interstitial 320x480 (GAM) [OK, Random]",
                     tags: [.interstitial, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let gamInterstitialController = PrebidGAMInterstitialController(rootController: adapterVC)
                gamInterstitialController.adFormats = [.banner]
                gamInterstitialController.prebidConfigId = "prebid-ita-display-interstitial-320-480"
                gamInterstitialController.gamAdUnitId = "/21808260008/prebid_oxb_html_interstitial_random"
                adapterVC.setup(adapter: gamInterstitialController)
                        
                setupCustomParams(for: gamInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Display Interstitial 320x480 (GAM) [noBids, GAM Ad]",
                     tags: [.interstitial, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamInterstitialController = PrebidGAMInterstitialController(rootController: adapterVC)
                gamInterstitialController.adFormats = [.banner]
                gamInterstitialController.prebidConfigId = "prebid-demo-no-bids"
                gamInterstitialController.gamAdUnitId = "/21808260008/prebid_oxb_320x480_html_interstitial_static"
                adapterVC.setup(adapter: gamInterstitialController)
                        
                setupCustomParams(for: gamInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Display Interstitial Multisize (GAM) [OK, AppEvent]",
                     tags: [.interstitial, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let gamInterstitialController = PrebidGAMInterstitialController(rootController: adapterVC)
                gamInterstitialController.adFormats = [.banner]
                gamInterstitialController.prebidConfigId = "prebid-demo-display-interstitial-multisize"
                gamInterstitialController.gamAdUnitId = "/21808260008/prebid_oxb_html_interstitial"
                adapterVC.setup(adapter: gamInterstitialController)
                        
                setupCustomParams(for: gamInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Display Interstitial 320x480 (GAM) [Vanilla Prebid Order]",
                     tags: [.interstitial, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let gamInterstitialController = PrebidGAMInterstitialController(rootController: adapterVC)
                gamInterstitialController.adFormats = [.banner]
                gamInterstitialController.prebidConfigId = "prebid-ita-display-interstitial-320-480"
                gamInterstitialController.gamAdUnitId = "/21808260008/prebid_html_interstitial"
                adapterVC.setup(adapter: gamInterstitialController)
                        
                setupCustomParams(for: gamInterstitialController.prebidConfigId)
            }),
            
            // MARK: ---- Multiformat Interstitial (GAM)
            
            TestCase(title: "Multiformat Interstitial 320x480 (GAM)",
                     tags: [.interstitial, .video, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let randomId = [0, 1].randomElement() ?? 0
                let interstitialController = PrebidGAMInterstitialController(rootController: adapterVC)
                let gamAdUnitIds = ["/21808260008/prebid_html_interstitial", "/21808260008/prebid_oxb_interstitial_video"]
                        
                let configIds = ["prebid-ita-display-interstitial-320-480", "prebid-ita-video-interstitial-320-480"]
                interstitialController.prebidConfigId = configIds[randomId]
                         
                interstitialController.gamAdUnitId = gamAdUnitIds[randomId]
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),

            // MARK: ---- Video Interstitial (In-App) ----
            
            TestCase(title: "Video Interstitial 320x480 (In-App)",
                     tags: [.video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "prebid-ita-video-interstitial-320-480"
                interstitialController.adFormats = [.video]
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial With Ad Configuration API 320x480 (In-App)",
                     tags: [.video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "prebid-demo-video-interstitial-320-480-with-ad-configuration"
                interstitialController.adFormats = [.video]
                         
                // Custom video configuration
                interstitialController.maxDuration = 30
                interstitialController.closeButtonArea = 0.15
                interstitialController.closeButtonPosition = .topLeft
                interstitialController.skipDelay = 5
                         
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial With Ad Configuration With End Card API 320x480 (In-App)",
                     tags: [.video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                         
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "prebid-demo-video-interstitial-320-480-with-end-card"
                interstitialController.adFormats = [.video]
                         
                // Custom video configuration
                interstitialController.maxDuration = 30
                interstitialController.closeButtonArea = 0.15
                interstitialController.closeButtonPosition = .topLeft
                interstitialController.skipButtonArea = 0.15
                interstitialController.skipButtonPosition = .topRight
                interstitialController.skipDelay = 5
                         
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial With Ad Configuration Server 320x480 (In-App)",
                     tags: [.video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "prebid-demo-video-interstitial-320-480-with-ad-configuration"
                interstitialController.adFormats = [.video]
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial With Ad Configuration With End Card Server 320x480 (In-App)",
                     tags: [.video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "prebid-demo-video-interstitial-320-480-with-end-card-with-ad-configuration"
                interstitialController.adFormats = [.video]
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),

            TestCase(title: "Video Interstitial 320x480 (In-App) [noBids]",
                     tags: [.video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "prebid-demo-no-bids"
                interstitialController.adFormats = [.video]
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial 320x480 with End Card (In-App)",
                     tags: [.video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "prebid-demo-video-interstitial-320-480-with-end-card"
                interstitialController.adFormats = [.video]
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial Vertical (In-App)",
                     tags: [.video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "prebid-demo-video-interstitial-vertical"
                interstitialController.adFormats = [.video]
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial Vertical With End Card (In-App)",
                     tags: [.video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "prebid-demo-video-interstitial-vertical-with-end-card"
                interstitialController.adFormats = [.video]
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial Landscape With End Card (In-App)",
                     tags: [.video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "prebid-demo-video-interstitial-landscape-with-end-card"
                interstitialController.adFormats = [.video]
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial 320x480 DeepLink+ (In-App)",
                     tags: [.video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "prebid-demo-video-interstitial-320-480-deeplink"
                interstitialController.adFormats = [.video]
                
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial 320x480 SkipOffset (In-App)",
                     tags: [.video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "prebid-demo-video-interstitial-320-480-skip-offset"
                interstitialController.adFormats = [.video]
                
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial 320x480 .mp4 (In-App)",
                     tags: [.video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "prebid-demo-video-interstitial-mp4"
                interstitialController.adFormats = [.video]
                
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial 320x480 .m4v (In-App)",
                     tags: [.video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "prebid-demo-video-interstitial-m4v"
                interstitialController.adFormats = [.video]
                
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial 320x480 .mov (In-App)",
                     tags: [.video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "prebid-demo-video-interstitial-mov"
                interstitialController.adFormats = [.video]
                
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial 320x480 with MRAID End Card (In-App)",
                     tags: [.video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "prebid-demo-video-interstitial-mraid-end-card"
                interstitialController.adFormats = [.video]
                
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),

            // NOTE: works only with InternalTestApp-Skadn target
            TestCase(title: "Video Interstitial 320x480 (In-App) [SKAdN]",
                     tags: [.video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                Targeting.shared.sourceapp = "InternalTestApp"
                         
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "prebid-demo-video-interstitial-320-480-skadn"
                interstitialController.adFormats = [.video]
                
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            // MARK: ---- Video Interstitial (GAM) ----
            
            TestCase(title: "Video Interstitial 320x480 (GAM) [OK, AppEvent]",
                     tags: [.video, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let gamInterstitialController = PrebidGAMInterstitialController(rootController: adapterVC)
                gamInterstitialController.prebidConfigId = "prebid-ita-video-interstitial-320-480"
                gamInterstitialController.adFormats = [.video]
                gamInterstitialController.gamAdUnitId = "/21808260008/prebid_oxb_interstitial_video"
                adapterVC.setup(adapter: gamInterstitialController)
                        
                setupCustomParams(for: gamInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial 320x480 (GAM) [OK, Random]",
                     tags: [.video, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let gamInterstitialController = PrebidGAMInterstitialController(rootController: adapterVC)
                gamInterstitialController.prebidConfigId = "prebid-ita-video-interstitial-320-480"
                gamInterstitialController.adFormats = [.video]
                gamInterstitialController.gamAdUnitId = "/21808260008/prebid_oxb_320x480_interstitial_video_random"
                adapterVC.setup(adapter: gamInterstitialController)
                        
                setupCustomParams(for: gamInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial 320x480 (GAM) [noBids, GAM Ad]",
                     tags: [.video, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let gamInterstitialController = PrebidGAMInterstitialController(rootController: adapterVC)
                gamInterstitialController.prebidConfigId = "prebid-demo-no-bids"
                gamInterstitialController.adFormats = [.video]
                gamInterstitialController.gamAdUnitId = "/21808260008/prebid_oxb_320x480_interstitial_video_static"
                adapterVC.setup(adapter: gamInterstitialController)
                        
                setupCustomParams(for: gamInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial 320x480 With Ad Configuration API (GAM) [OK, AppEvent]",
                     tags: [.video, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamInterstitialController = PrebidGAMInterstitialController(rootController: adapterVC)
                gamInterstitialController.prebidConfigId = "prebid-ita-video-interstitial-320-480"
                gamInterstitialController.adFormats = [.video]
                gamInterstitialController.gamAdUnitId = "/21808260008/prebid_oxb_interstitial_video"
                      
                // Custom video configuration
                gamInterstitialController.maxDuration = 30
                gamInterstitialController.closeButtonArea = 0.15
                gamInterstitialController.closeButtonPosition = .topLeft
                gamInterstitialController.skipDelay = 5
                         
                adapterVC.setup(adapter: gamInterstitialController)
                        
                setupCustomParams(for: gamInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial With Ad Configuration With End Card API 320x480 (GAM) [OK, AppEvent]",
                     tags: [.video, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let gamInterstitialController = PrebidGAMInterstitialController(rootController: adapterVC)
                gamInterstitialController.prebidConfigId = "prebid-demo-video-interstitial-320-480-with-end-card"
                gamInterstitialController.adFormats = [.video]
                gamInterstitialController.gamAdUnitId = "/21808260008/prebid_oxb_interstitial_video"
                         
                // Custom video configuration
                gamInterstitialController.maxDuration = 30
                gamInterstitialController.closeButtonArea = 0.15
                gamInterstitialController.closeButtonPosition = .topLeft
                gamInterstitialController.skipButtonArea = 0.15
                gamInterstitialController.skipButtonPosition = .topRight
                gamInterstitialController.skipDelay = 5
                         
                adapterVC.setup(adapter: gamInterstitialController)
                        
                setupCustomParams(for: gamInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial With Ad Configuration Server 320x480 (GAM) [OK, AppEvent]",
                     tags: [.video, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let gamInterstitialController = PrebidGAMInterstitialController(rootController: adapterVC)
                gamInterstitialController.prebidConfigId = "prebid-demo-video-interstitial-320-480-with-ad-configuration"
                gamInterstitialController.adFormats = [.video]
                gamInterstitialController.gamAdUnitId = "/21808260008/prebid_oxb_interstitial_video"
                adapterVC.setup(adapter: gamInterstitialController)
                        
                setupCustomParams(for: gamInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial With Ad Configuration With End Card Server 320x480 (GAM) [OK, AppEvent]",
                     tags: [.video, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let gamInterstitialController = PrebidGAMInterstitialController(rootController: adapterVC)
                gamInterstitialController.prebidConfigId = "prebid-demo-video-interstitial-320-480-with-end-card-with-ad-configuration"
                gamInterstitialController.adFormats = [.video]
                gamInterstitialController.gamAdUnitId = "/21808260008/prebid_oxb_interstitial_video"
                adapterVC.setup(adapter: gamInterstitialController)
                        
                setupCustomParams(for: gamInterstitialController.prebidConfigId)
            }),
            
            
            TestCase(title: "Video Interstitial 320x480 (GAM) [Vanilla Prebid Order]",
                     tags: [.video, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                   return
                }
                         
                let gamInterstitialController = PrebidGAMInterstitialController(rootController: adapterVC)
                gamInterstitialController.prebidConfigId = "prebid-ita-video-interstitial-320-480"
                gamInterstitialController.adFormats = [.video]
               
                gamInterstitialController.gamAdUnitId = "/21808260008/prebid_interstitial_video"
                adapterVC.setup(adapter: gamInterstitialController)
                        
                setupCustomParams(for: gamInterstitialController.prebidConfigId)
            }),

            // MARK: ---- Video (In-App) ----
            
            TestCase(title: "Video Outstream (In-App)",
                     tags: [.video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "prebid-ita-video-outstream"
                bannerController.adSizes = [CGSize(width: 300, height: 250)]
                bannerController.adFormat = .video
                        
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Video Outstream (In-App) [noBids]",
                     tags: [.video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "prebid-demo-no-bids"
                bannerController.adSizes = [CGSize(width: 300, height: 250)]
                bannerController.adFormat = .video
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Video Outstream with End Card (In-App)",
                     tags: [.video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let bannerController = PrebidBannerController(rootController: adapterVC)
                
                bannerController.adSizes = [CGSize(width: 300, height: 250)]
                bannerController.adFormat = .video
                        
                bannerController.prebidConfigId = "prebid-demo-video-outstream-with-end-card"
                 
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Video Outstream Feed (In-App)",
                     tags: [.video, .inapp, .server],
                     exampleVCStoryboardID: "PrebidFeedTableViewController",
                     configurationClosure: { vc in
                        
                guard let feedVC = vc as? PrebidFeedTableViewController,
                    let tableView = feedVC.tableView else {
                    return
                }
            
                feedVC.testCases = [
                    TestCaseManager.createDummyTableCell(for: tableView),
                    TestCaseManager.createDummyTableCell(for: tableView),
                    TestCaseManager.createDummyTableCell(for: tableView),
                    
                    TestCaseForTableCell(configurationClosureForTableCell: { [weak feedVC, weak tableView] cell in
                        
                        guard let videoViewCell = tableView?.dequeueReusableCell(withIdentifier: "FeedAdTableViewCell") as? FeedAdTableViewCell else {
                            return
                        }
                        cell = videoViewCell
                        guard videoViewCell.adView == nil else {
                            return
                        }
                        
                        
                        var prebidConfigId = "prebid-ita-video-outstream"
                        let adSize = CGSize(width: 300, height: 250)
                        let adBannerView = BannerView(frame: CGRect(origin: .zero, size: adSize),configID: prebidConfigId,adSize: adSize)
                        
                        adBannerView.adFormat = .video
                        adBannerView.videoParameters.placement = .InFeed
                        adBannerView.delegate = feedVC
                        adBannerView.accessibilityIdentifier = "PrebidBannerView"
                        
                        if let adUnitContext = AppConfiguration.shared.adUnitContext {
                            for dataPair in adUnitContext {
                                adBannerView.addContextData(dataPair.value, forKey: dataPair.key)
                            }
                        }
                        
                        setupCustomParams(for: prebidConfigId)
                        adBannerView.loadAd()
                        
                        videoViewCell.bannerView.addSubview(adBannerView)
                        videoViewCell.adView = adBannerView
                    }),
                    
                    TestCaseManager.createDummyTableCell(for: tableView),
                    TestCaseManager.createDummyTableCell(for: tableView),
                    TestCaseManager.createDummyTableCell(for: tableView),
                ];
            }),
            
            // NOTE: works only with InternalTestApp-Skadn target
            TestCase(title: "Video Outstream (In-App) [SKAdN]",
                     tags: [.video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                Targeting.shared.sourceapp = "InternalTestApp"
                         
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "prebid-demo-video-outstream-skadn"
                bannerController.adSizes = [CGSize(width: 300, height: 250)]
                bannerController.adFormat = .video
                
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            // MARK: ---- Video (GAM) ----
            
            TestCase(title: "Video Outstream (GAM) [OK, AppEvent]",
                     tags: [.video, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
                gamBannerController.gamAdUnitId = "/21808260008/prebid_oxb_300x250_banner"
                gamBannerController.validAdSizes = [GADAdSizeMediumRectangle]
                gamBannerController.adFormat = .video
                gamBannerController.prebidConfigId = "prebid-ita-video-outstream"
                 
                adapterVC.setup(adapter: gamBannerController)
                        
                setupCustomParams(for: gamBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Video Outstream with End Card (GAM) [OK, AppEvent]",
                     tags: [.video, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
                gamBannerController.gamAdUnitId = "/21808260008/prebid_oxb_300x250_banner"
                gamBannerController.validAdSizes = [GADAdSizeMediumRectangle]
                gamBannerController.adFormat = .video
                gamBannerController.prebidConfigId = "prebid-demo-video-outstream-with-end-card"
                 
                adapterVC.setup(adapter: gamBannerController)
                        
                setupCustomParams(for: gamBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Video Outstream (GAM) [OK, Random]",
                     tags: [.video, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
                gamBannerController.prebidConfigId = "prebid-ita-video-outstream"
                gamBannerController.gamAdUnitId = "/21808260008/prebid_oxb_outstream_video_reandom"
                gamBannerController.validAdSizes = [GADAdSizeMediumRectangle]
                gamBannerController.adFormat = .video
                adapterVC.setup(adapter: gamBannerController)
                        
                setupCustomParams(for: gamBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Video Outstream (GAM) [noBids, GAM Ad]",
                     tags: [.video, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
                gamBannerController.prebidConfigId = "prebid-demo-no-bids"
                gamBannerController.gamAdUnitId = "/21808260008/prebid_oxb_outsream_video"
                gamBannerController.validAdSizes = [GADAdSizeMediumRectangle]
                gamBannerController.adFormat = .video
                
                adapterVC.setup(adapter: gamBannerController)
                        
                setupCustomParams(for: gamBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Video Outstream Feed (GAM)",
                     tags: [.video, .gam, .server],
                     exampleVCStoryboardID: "PrebidFeedTableViewController",
                     configurationClosure: { vc in
                        
                guard let feedVC = vc as? PrebidFeedTableViewController,
                    let tableView = feedVC.tableView else {
                    return
                }
                feedVC.testCases = [
                    TestCaseManager.createDummyTableCell(for: tableView),
                    TestCaseManager.createDummyTableCell(for: tableView),
                    TestCaseManager.createDummyTableCell(for: tableView),
                    
                    TestCaseForTableCell(configurationClosureForTableCell: { [weak feedVC, weak tableView] cell in
                        
                        guard let videoViewCell = tableView?.dequeueReusableCell(withIdentifier: "FeedAdTableViewCell") as? FeedAdTableViewCell else {
                            return
                        }
                        cell = videoViewCell
                        guard videoViewCell.adView == nil else {
                            return
                        }
                        
                        var prebidConfigId = "prebid-ita-video-outstream"
                        let gamAdUnitId = "/21808260008/prebid_oxb_outstream_video_reandom"
                        let validAdSize = GADAdSizeMediumRectangle
                        let adSize = validAdSize.size
                        let adEventHandler = GAMBannerEventHandler(adUnitID: gamAdUnitId, validGADAdSizes: [NSValueFromGADAdSize(validAdSize)])
                        let adBannerView = BannerView(configID: prebidConfigId,eventHandler: adEventHandler)
                        adBannerView.adFormat = .video
                        adBannerView.videoParameters.placement = .InFeed
                        adBannerView.delegate = feedVC
                        adBannerView.accessibilityIdentifier = "PrebidBannerView"
                        
                        if let adUnitContext = AppConfiguration.shared.adUnitContext {
                            for dataPair in adUnitContext {
                                adBannerView.addContextData(dataPair.value, forKey: dataPair.key)
                            }
                        }
                        
                        setupCustomParams(for: prebidConfigId)
                        adBannerView.loadAd()
                        
                        videoViewCell.bannerView.addSubview(adBannerView)
                        videoViewCell.adView = adBannerView
                    }),
                    
                    TestCaseManager.createDummyTableCell(for: tableView),
                    TestCaseManager.createDummyTableCell(for: tableView),
                    TestCaseManager.createDummyTableCell(for: tableView),
                ];
            }),
            
            // MARK: ---- Rewarded (In-App) ----
            
            TestCase(title: "Banner Rewarded Default 320x480 (In-App)",
                     tags: [.interstitial, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let rewardedAdController = PrebidRewardedController(rootController: adapterVC)
                rewardedAdController.prebidConfigId = "prebid-demo-banner-rewarded-default"
                adapterVC.setup(adapter: rewardedAdController)
                setupCustomParams(for: rewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "Banner Rewarded Time 320x480 (In-App)",
                     tags: [.interstitial, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let rewardedAdController = PrebidRewardedController(rootController: adapterVC)
                rewardedAdController.prebidConfigId = "prebid-demo-banner-rewarded-time"
                adapterVC.setup(adapter: rewardedAdController)
                setupCustomParams(for: rewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "Banner Rewarded Event 320x480 (In-App)",
                     tags: [.interstitial, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let rewardedAdController = PrebidRewardedController(rootController: adapterVC)
                rewardedAdController.prebidConfigId = "prebid-demo-banner-rewarded-event"
                adapterVC.setup(adapter: rewardedAdController)
                setupCustomParams(for: rewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "Video Rewarded Default 320x480 (In-App)",
                     tags: [.interstitial, .video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let rewardedAdController = PrebidRewardedController(rootController: adapterVC)
                rewardedAdController.prebidConfigId = "prebid-demo-video-rewarded-default"
                adapterVC.setup(adapter: rewardedAdController)
                setupCustomParams(for: rewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "Video Rewarded Playbackevent 320x480 (In-App)",
                     tags: [.interstitial, .video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let rewardedAdController = PrebidRewardedController(rootController: adapterVC)
                rewardedAdController.prebidConfigId = "prebid-demo-video-rewarded-playbackevent"
                adapterVC.setup(adapter: rewardedAdController)
                setupCustomParams(for: rewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "Video Rewarded Time 320x480 (In-App)",
                     tags: [.interstitial, .video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let rewardedAdController = PrebidRewardedController(rootController: adapterVC)
                rewardedAdController.prebidConfigId = "prebid-demo-video-rewarded-time"
                adapterVC.setup(adapter: rewardedAdController)
                setupCustomParams(for: rewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "Video Rewarded Time 320x480 (In-App) [SKAdN]",
                     tags: [.interstitial, .video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                Targeting.shared.sourceapp = "InternalTestApp"
                let rewardedAdController = PrebidRewardedController(rootController: adapterVC)
                rewardedAdController.prebidConfigId = "prebid-demo-video-rewarded-time-skadn"
                adapterVC.setup(adapter: rewardedAdController)
                setupCustomParams(for: rewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "Video Rewarded Time With Server Ad Configuration 320x480 (In-App)",
                     tags: [.interstitial, .video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                
                let rewardedAdController = PrebidRewardedController(rootController: adapterVC)
                rewardedAdController.prebidConfigId = "prebid-demo-video-rewarded-time-ad-config"
                adapterVC.setup(adapter: rewardedAdController)
                setupCustomParams(for: rewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "Video Rewarded Endcard Default 320x480 (In-App)",
                     tags: [.interstitial, .video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let rewardedAdController = PrebidRewardedController(rootController: adapterVC)
                rewardedAdController.prebidConfigId = "prebid-demo-video-rewarded-endcard-default"
                adapterVC.setup(adapter: rewardedAdController)
                setupCustomParams(for: rewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "Video Rewarded Endcard Event 320x480 (In-App)",
                     tags: [.interstitial, .video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let rewardedAdController = PrebidRewardedController(rootController: adapterVC)
                rewardedAdController.prebidConfigId = "prebid-demo-video-rewarded-endcard-event"
                adapterVC.setup(adapter: rewardedAdController)
                setupCustomParams(for: rewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "Video Rewarded Endcard Time 320x480 (In-App)",
                     tags: [.interstitial, .video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let rewardedAdController = PrebidRewardedController(rootController: adapterVC)
                rewardedAdController.prebidConfigId = "prebid-demo-video-rewarded-endcard-time"
                adapterVC.setup(adapter: rewardedAdController)
                setupCustomParams(for: rewardedAdController.prebidConfigId)
            }),

            TestCase(title: "Video Rewarded 320x480 (In-App) [noBids]",
                     tags: [.interstitial, .video, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController", configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let rewardedAdController = PrebidRewardedController(rootController: adapterVC)
                rewardedAdController.prebidConfigId = "prebid-demo-no-bids"
                adapterVC.setup(adapter: rewardedAdController)
                setupCustomParams(for: rewardedAdController.prebidConfigId)
            }),
            
            // MARK: ---- Rewarded (GAM) ----
            
            TestCase(title: "Banner Rewarded Time 320x480 (GAM) [OK, Metadata]",
                     tags: [.interstitial, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                         
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let gamRewardedAdController = PrebidGAMRewardedController(rootController: adapterVC)
                gamRewardedAdController.gamAdUnitId = "/21808260008/prebid_oxb_rewarded_video_test"
                gamRewardedAdController.prebidConfigId = "prebid-demo-banner-rewarded-time"
                adapterVC.setup(adapter: gamRewardedAdController)
                setupCustomParams(for: gamRewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "Video Rewarded Time 320x480 (GAM) [OK, Metadata]",
                     tags: [.interstitial, .video, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let gamRewardedAdController = PrebidGAMRewardedController(rootController: adapterVC)
                gamRewardedAdController.prebidConfigId = "prebid-demo-video-rewarded-time"
                gamRewardedAdController.gamAdUnitId = "/21808260008/prebid_oxb_rewarded_video_test"
                adapterVC.setup(adapter: gamRewardedAdController)
                setupCustomParams(for: gamRewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "Video Rewarded 320x480 Time With Server Ad Configuration (GAM) [OK, Metadata]",
                     tags: [.interstitial, .video, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let gamRewardedAdController = PrebidGAMRewardedController(rootController: adapterVC)
                gamRewardedAdController.gamAdUnitId = "/21808260008/prebid_oxb_rewarded_video_test"
                gamRewardedAdController.prebidConfigId = "prebid-demo-video-rewarded-time-ad-config"
                adapterVC.setup(adapter: gamRewardedAdController)
                setupCustomParams(for: gamRewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "Video Rewarded Endcard Time 320x480 (GAM) [OK, Metadata]",
                     tags: [.interstitial, .video, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                         
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let gamRewardedAdController = PrebidGAMRewardedController(rootController: adapterVC)
                gamRewardedAdController.gamAdUnitId = "/21808260008/prebid_oxb_rewarded_video_test"
                gamRewardedAdController.prebidConfigId = "prebid-demo-video-rewarded-endcard-time"
                adapterVC.setup(adapter: gamRewardedAdController)
                setupCustomParams(for: gamRewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "Video Rewarded 320x480 (GAM) [noBids, GAM Ad]",
                     tags: [.interstitial, .video, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let gamRewardedAdController = PrebidGAMRewardedController(rootController: adapterVC)
                gamRewardedAdController.prebidConfigId = "prebid-demo-no-bids"
                gamRewardedAdController.gamAdUnitId = "/21808260008/prebid_oxb_rewarded_video_static"
                adapterVC.setup(adapter: gamRewardedAdController)
                setupCustomParams(for: gamRewardedAdController.prebidConfigId)
            }),

            // MARK: ---- MRAID (In-App) ----
            
            TestCase(title: "MRAID 2.0: Expand - 1 Part (In-App)",
                     tags: [.mraid, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "prebid-demo-mraid-expand-1-part"
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "MRAID 2.0: Expand - 2 Part (In-App)",
                     tags: [.mraid, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "prebid-demo-mraid-expand-2-part"
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                 
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "MRAID 2.0: Resize (In-App)",
                     tags: [.mraid, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                bannerController.prebidConfigId = "prebid-demo-mraid-resize"
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "MRAID 2.0: Resize with Errors (In-App)",
                     tags: [.mraid, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "prebid-demo-mraid-resize-with-errors"
                bannerController.adSizes = [CGSize(width: 300, height: 250)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "MRAID 2.0: Fullscreen (In-App)",
                     tags: [.mraid, .inapp, .server],
                     exampleVCStoryboardID: "ScrollableAdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "prebid-demo-mraid-fullscreen"
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),

            TestCase(title: "MRAID 2.0: Video Interstitial (In-App)",
                     tags: [.mraid, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "prebid-demo-mraid-video-interstitial"
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "MRAID 3.0: Viewability Compliance (In-App)",
                     tags: [.mraid, .inapp, .server],
                     exampleVCStoryboardID: "ScrollableAdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "prebid-demo-mraid-viewability-compliance"
                bannerController.adSizes = [CGSize(width: 300, height: 250)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "MRAID 3.0: Resize Negative Test (In-App)",
                     tags: [.mraid, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                        
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "prebid-demo-mraid-resize-negative-test"
                bannerController.adSizes = [CGSize(width: 300, height: 250)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "MRAID 3.0: Load And Events (In-App)",
                     tags: [.mraid, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "prebid-demo-mraid-load-and-events"
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "MRAID OX: Test Properties 3.0 (In-App)",
                     tags: [.mraid, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "prebid-demo-mraid-test-properties-3"
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "MRAID OX: Test Methods 3.0 (In-App)",
                     tags: [.mraid, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "prebid-demo-mraid-test-methods-3"
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "MRAID OX: Resize (Expandable) (In-App)",
                     tags: [.mraid, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                        
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "prebid-demo-mraid-resize-expandable"
                bannerController.adSizes = [CGSize(width: 300, height: 50)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "MRAID OX: Resize (With Scroll) (In-App)",
                     tags: [.mraid, .inapp, .server],
                     exampleVCStoryboardID: "ScrollableAdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                        
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "prebid-demo-mraid-resize"
                bannerController.adSizes = [CGSize(width: 300, height: 50)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            // MARK: ---- MRAID (GAM) ----
            
            TestCase(title: "MRAID 2.0: Expand - 1 Part (GAM)",
                     tags: [.mraid, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
                gamBannerController.prebidConfigId = "prebid-demo-mraid-expand-1-part"
                gamBannerController.gamAdUnitId = "/21808260008/prebid_oxb_320x50_banner"
                gamBannerController.validAdSizes = [GADAdSizeBanner]
                adapterVC.setup(adapter: gamBannerController)
                        
                setupCustomParams(for: gamBannerController.prebidConfigId)
            }),
            
            
            TestCase(title: "MRAID 2.0: Resize (GAM)",
                     tags: [.mraid, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
                gamBannerController.prebidConfigId = "prebid-demo-mraid-resize"
                gamBannerController.gamAdUnitId = "/21808260008/prebid_oxb_320x50_banner"
                gamBannerController.validAdSizes = [GADAdSizeBanner]
                adapterVC.setup(adapter: gamBannerController)
                        
                setupCustomParams(for: gamBannerController.prebidConfigId)
            }),
            
            TestCase(title: "MRAID 2.0: Video Interstitial (GAM)",
                     tags: [.mraid, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let gamInterstitialController = PrebidGAMInterstitialController(rootController: adapterVC)
                gamInterstitialController.prebidConfigId = "prebid-demo-mraid-video-interstitial"
                gamInterstitialController.gamAdUnitId = "/21808260008/prebid_oxb_html_interstitial"
                adapterVC.setup(adapter: gamInterstitialController)
                        
                setupCustomParams(for: gamInterstitialController.prebidConfigId)
            }),
            

            // MARK: ---- Banner (AdMob) ----
            
            TestCase(title: "Banner 320x50 (AdMob) [OK, OXB Adapter]",
                     tags: [.banner, .admob, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let admobBannerController = PrebidAdMobBannerViewController(rootController: adapterVC)
                admobBannerController.adMobAdUnitId = "ca-app-pub-5922967660082475/9483570409"
                admobBannerController.adUnitSize = CGSize(width: 320, height: 50);
                        
                admobBannerController.prebidConfigId = "prebid-ita-banner-320-50"
                 
                adapterVC.setup(adapter: admobBannerController)
                        
                setupCustomParams(for: admobBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 Events (AdMob) [OK, OXB Adapter]",
                     tags: [.banner, .admob, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                Prebid.shared.prebidServerAccountId = "prebid-stored-request-enabled-events"
                         
                let admobBannerController = PrebidAdMobBannerViewController(rootController: adapterVC)
                admobBannerController.adMobAdUnitId = "ca-app-pub-5922967660082475/9483570409"
                admobBannerController.adUnitSize = CGSize(width: 320, height: 50);
                        
                admobBannerController.prebidConfigId = "prebid-ita-banner-320-50"
                 
                adapterVC.setup(adapter: admobBannerController)
                        
                setupCustomParams(for: admobBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (AdMob) [OK, Random]",
                     tags: [.banner, .admob, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let admobBannerController = PrebidAdMobBannerViewController(rootController: adapterVC)
                admobBannerController.prebidConfigId = "prebid-ita-banner-320-50"
                admobBannerController.adMobAdUnitId = "ca-app-pub-5922967660082475/9483570409"
                admobBannerController.adUnitSize = CGSize(width: 320, height: 50);
                adapterVC.setup(adapter: admobBannerController)
                        
                setupCustomParams(for: admobBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (AdMob) [noBids, AdMob Ad]",
                     tags: [.banner, .admob, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let admobBannerController = PrebidAdMobBannerViewController(rootController: adapterVC)
                admobBannerController.prebidConfigId = "prebid-demo-no-bids"
                admobBannerController.adMobAdUnitId = "ca-app-pub-5922967660082475/9483570409"
                admobBannerController.adUnitSize = CGSize(width: 320, height: 50);
                adapterVC.setup(adapter: admobBannerController)
                        
                setupCustomParams(for: admobBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (AdMob) [Random, Respective]",
                     tags: [.banner, .admob, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let admobBannerController = PrebidAdMobBannerViewController(rootController: adapterVC)
                admobBannerController.prebidConfigId = "prebid-ita-banner-320-50"
                admobBannerController.adMobAdUnitId = "ca-app-pub-5922967660082475/9483570409"
                admobBannerController.adUnitSize = CGSize(width: 320, height: 50);
                adapterVC.setup(adapter: admobBannerController)
                        
                setupCustomParams(for: admobBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 300x250 (AdMob)",
                     tags: [.banner, .admob, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let admobBannerController = PrebidAdMobBannerViewController(rootController: adapterVC)
                admobBannerController.prebidConfigId = "prebid-ita-banner-300-250"
                admobBannerController.adMobAdUnitId = "ca-app-pub-5922967660082475/9483570409"
                admobBannerController.adUnitSize = CGSize(width: 300, height: 250);
                adapterVC.setup(adapter: admobBannerController)
                        
                setupCustomParams(for: admobBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner Adaptive (AdMob)",
                     tags: [.banner, .admob, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let admobBannerController = PrebidAdMobBannerViewController(rootController: adapterVC)
                admobBannerController.prebidConfigId = "prebid-demo-banner-multisize"
                admobBannerController.adMobAdUnitId = "ca-app-pub-5922967660082475/9483570409"
                admobBannerController.adUnitSize = CGSize(width: 320, height: 50);
                admobBannerController.additionalAdSizes = [CGSize(width: 728, height: 90)]
                admobBannerController.gadAdSizeType = .adaptiveAnchored
                adapterVC.setup(adapter: admobBannerController)
                        
                setupCustomParams(for: admobBannerController.prebidConfigId)
            }),
            
            // MARK: ---- Interstitial (AdMob) ----
            
            TestCase(title: "Display Interstitial 320x480 (AdMob) [OK, OXB Adapter]",
                     tags: [.interstitial, .admob, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let admobInterstitialController = PrebidAdMobInterstitialViewController(rootController: adapterVC)
                admobInterstitialController.adMobAdUnitId = "ca-app-pub-5922967660082475/3383099861"
                admobInterstitialController.adFormats = [.banner]
                admobInterstitialController.prebidConfigId = "prebid-ita-display-interstitial-320-480"
                
                adapterVC.setup(adapter: admobInterstitialController)
                        
                setupCustomParams(for: admobInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Display Interstitial 320x480 (AdMob) [noBids, AdMob Ad]",
                     tags: [.interstitial, .admob, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let admobInterstitialController = PrebidAdMobInterstitialViewController(rootController: adapterVC)
                admobInterstitialController.adFormats = [.banner]
                admobInterstitialController.prebidConfigId = "prebid-demo-no-bids"
                admobInterstitialController.adMobAdUnitId = "ca-app-pub-5922967660082475/3383099861"
                adapterVC.setup(adapter: admobInterstitialController)
                        
                setupCustomParams(for: admobInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Display Interstitial 320x480 (AdMob) [OK, Random]",
                     tags: [.interstitial, .admob, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let admobInterstitialController = PrebidAdMobInterstitialViewController(rootController: adapterVC)
                admobInterstitialController.adFormats = [.banner]
                admobInterstitialController.prebidConfigId = "prebid-ita-display-interstitial-320-480"
                admobInterstitialController.adMobAdUnitId = "ca-app-pub-5922967660082475/3383099861"
                adapterVC.setup(adapter: admobInterstitialController)
                        
                setupCustomParams(for: admobInterstitialController.prebidConfigId)
            }),
            
            // MARK: ---- Video Interstitial (AdMob) ----
            
            TestCase(title: "Video Interstitial 320x480 (AdMob) [OK, OXB Adapter]",
                     tags: [.video, .admob, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let admobInterstitialController = PrebidAdMobInterstitialViewController(rootController: adapterVC)
                admobInterstitialController.prebidConfigId = "prebid-ita-video-interstitial-320-480"
                admobInterstitialController.adFormats = [.video]
                admobInterstitialController.adMobAdUnitId = "ca-app-pub-5922967660082475/4527792002"
                adapterVC.setup(adapter: admobInterstitialController)
                        
                setupCustomParams(for: admobInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial With Ad Configuration 320x480 API (AdMob) [OK, OXB Adapter]",
                     tags: [.video, .admob, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let admobInterstitialController = PrebidAdMobInterstitialViewController(rootController: adapterVC)
                admobInterstitialController.prebidConfigId = "prebid-ita-video-interstitial-320-480"
                admobInterstitialController.adFormats = [.video]
                admobInterstitialController.adMobAdUnitId = "ca-app-pub-5922967660082475/4527792002"
                         
                // Custom video configuration
                admobInterstitialController.maxDuration = 30
                admobInterstitialController.closeButtonArea = 0.15
                admobInterstitialController.closeButtonPosition = .topLeft
                admobInterstitialController.skipDelay = 5
                         
                adapterVC.setup(adapter: admobInterstitialController)
                        
                setupCustomParams(for: admobInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial With Ad Configuration With End Card 320x480 API (AdMob) [OK, OXB Adapter]",
                     tags: [.video, .admob, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let admobInterstitialController = PrebidAdMobInterstitialViewController(rootController: adapterVC)
                admobInterstitialController.prebidConfigId = "prebid-demo-video-interstitial-320-480-with-end-card"
                admobInterstitialController.adFormats = [.video]
                admobInterstitialController.adMobAdUnitId = "ca-app-pub-5922967660082475/4527792002"
                         
                // Custom video configuration
                admobInterstitialController.maxDuration = 30
                admobInterstitialController.closeButtonArea = 0.15
                admobInterstitialController.closeButtonPosition = .topLeft
                admobInterstitialController.skipButtonArea = 0.15
                admobInterstitialController.skipButtonPosition = .topRight
                admobInterstitialController.skipDelay = 5
                         
                adapterVC.setup(adapter: admobInterstitialController)
                        
                setupCustomParams(for: admobInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial With Ad Configuration 320x480 Server (AdMob) [OK, OXB Adapter]",
                     tags: [.video, .admob, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let admobInterstitialController = PrebidAdMobInterstitialViewController(rootController: adapterVC)
                admobInterstitialController.prebidConfigId = "prebid-demo-video-interstitial-320-480-with-ad-configuration"
                admobInterstitialController.adFormats = [.video]
                admobInterstitialController.adMobAdUnitId = "ca-app-pub-5922967660082475/4527792002"
                adapterVC.setup(adapter: admobInterstitialController)
                        
                setupCustomParams(for: admobInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial With Ad Configuration With End Card 320x480 Server (AdMob) [OK, OXB Adapter]",
                     tags: [.video, .admob, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let admobInterstitialController = PrebidAdMobInterstitialViewController(rootController: adapterVC)
                admobInterstitialController.prebidConfigId = "prebid-demo-video-interstitial-320-480-with-end-card-with-ad-configuration"
                admobInterstitialController.adFormats = [.video]
                admobInterstitialController.adMobAdUnitId = "ca-app-pub-5922967660082475/4527792002"
                adapterVC.setup(adapter: admobInterstitialController)
                        
                setupCustomParams(for: admobInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial 320x480 (AdMob) [OK, Random]",
                     tags: [.video, .admob, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let admobInterstitialController = PrebidAdMobInterstitialViewController(rootController: adapterVC)
                admobInterstitialController.prebidConfigId = "prebid-ita-video-interstitial-320-480"
                admobInterstitialController.adFormats = [.video]
                admobInterstitialController.adMobAdUnitId = "ca-app-pub-5922967660082475/4527792002"
                adapterVC.setup(adapter: admobInterstitialController)
                        
                setupCustomParams(for: admobInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial 320x480 (AdMob) [noBids, AdMob Ad]",
                     tags: [.video, .admob, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let admobInterstitialController = PrebidAdMobInterstitialViewController(rootController: adapterVC)
                admobInterstitialController.prebidConfigId = "prebid-demo-no-bids"
                admobInterstitialController.adFormats = [.video]
                admobInterstitialController.adMobAdUnitId = "ca-app-pub-5922967660082475/4527792002"
                adapterVC.setup(adapter: admobInterstitialController)
                setupCustomParams(for: admobInterstitialController.prebidConfigId)
            }),
            
            // MARK: ---- Multiformat Interstitial (AdMob) ----
            
            TestCase(title: "Multiformat Interstitial 320x480 (AdMob)",
                     tags: [.interstitial, .video, .admob, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let randomId = [0, 1].randomElement() ?? 0
                let interstitialController = PrebidAdMobInterstitialViewController(rootController: adapterVC)
                let admobAdUnitIds = ["ca-app-pub-5922967660082475/3383099861", "ca-app-pub-5922967660082475/4527792002"]
                interstitialController.adMobAdUnitId = admobAdUnitIds[randomId]
                         
                let configIds = ["prebid-ita-display-interstitial-320-480", "prebid-ita-video-interstitial-320-480"]
                interstitialController.prebidConfigId = configIds[randomId]
                         
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            // MARK: ---- Rewarded (AdMob) ----
            
            TestCase(title: "Banner Rewarded Time 320x480 (AdMob) [OK, OXB Adapter]",
                     tags: [.interstitial, .video, .admob, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let admobRewardedAdController = PrebidAdMobRewardedViewController(rootController: adapterVC)
                admobRewardedAdController.adMobAdUnitId = "ca-app-pub-5922967660082475/5628505938"
                admobRewardedAdController.prebidConfigId = "prebid-demo-banner-rewarded-time"
                adapterVC.setup(adapter: admobRewardedAdController)
                setupCustomParams(for: admobRewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "Video Rewarded Endcard Time 320x480 (AdMob) [OK, OXB Adapter]",
                     tags: [.interstitial, .video, .admob, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let admobRewardedAdController = PrebidAdMobRewardedViewController(rootController: adapterVC)
                admobRewardedAdController.adMobAdUnitId = "ca-app-pub-5922967660082475/5628505938"
                admobRewardedAdController.prebidConfigId = "prebid-demo-video-rewarded-endcard-time"
                adapterVC.setup(adapter: admobRewardedAdController)
                setupCustomParams(for: admobRewardedAdController.prebidConfigId)
            }),

            TestCase(title: "Video Rewarded Time 320x480 (AdMob) [OK, OXB Adapter]",
                     tags: [.interstitial, .video, .admob, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let admobRewardedAdController = PrebidAdMobRewardedViewController(rootController: adapterVC)
                admobRewardedAdController.prebidConfigId = "prebid-demo-video-rewarded-time"
                admobRewardedAdController.adMobAdUnitId = "ca-app-pub-5922967660082475/5628505938"
                adapterVC.setup(adapter: admobRewardedAdController)
                setupCustomParams(for: admobRewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "Video Rewarded Time With Server Ad Configuration 320x480 (AdMob) [OK, OXB Adapter]",
                     tags: [.interstitial, .video, .admob, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let admobRewardedAdController = PrebidAdMobRewardedViewController(rootController: adapterVC)
                admobRewardedAdController.adMobAdUnitId = "ca-app-pub-5922967660082475/5628505938"
                admobRewardedAdController.prebidConfigId = "prebid-demo-video-rewarded-time-ad-config"
                adapterVC.setup(adapter: admobRewardedAdController)
                setupCustomParams(for: admobRewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "Video Rewarded 320x480 (AdMob) [noBids, AdMob Ad]",
                     tags: [.interstitial, .video, .admob, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let admobRewardedAdController = PrebidAdMobRewardedViewController(rootController: adapterVC)
                admobRewardedAdController.prebidConfigId = "prebid-demo-no-bids"
                admobRewardedAdController.adMobAdUnitId = "ca-app-pub-5922967660082475/5628505938"
                adapterVC.setup(adapter: admobRewardedAdController)
                setupCustomParams(for: admobRewardedAdController.prebidConfigId)
            }),
            
            // MARK: ---- Native (AdMob) ----
            
            TestCase(title: "Native Ad (AdMob) [OK, OXB Adapter]",
                     tags: [.native, .admob, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let nativeController = PrebidAdMobNativeViewController(rootController: adapterVC)
                nativeController.adMobAdUnitId = "ca-app-pub-5922967660082475/8634069303"
                nativeController.prebidConfigId = "prebid-ita-banner-native-styles"
                nativeController.nativeAssets = .defaultNativeRequestAssets
                nativeController.eventTrackers = .defaultNativeEventTrackers
                         
                adapterVC.setup(adapter: nativeController)
                setupCustomParams(for: nativeController.prebidConfigId)
            }),
            
            TestCase(title: "Native Ad Events (AdMob) [OK, OXB Adapter]",
                     tags: [.native, .admob, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                Prebid.shared.prebidServerAccountId = "prebid-stored-request-enabled-events"
                         
                let nativeController = PrebidAdMobNativeViewController(rootController: adapterVC)
                nativeController.adMobAdUnitId = "ca-app-pub-5922967660082475/8634069303"
                nativeController.prebidConfigId = "prebid-ita-banner-native-styles"
                nativeController.nativeAssets = .defaultNativeRequestAssets
                nativeController.eventTrackers = .defaultNativeEventTrackers
                         
                adapterVC.setup(adapter: nativeController)
                setupCustomParams(for: nativeController.prebidConfigId)
            }),
            
            TestCase(title: "Native Ad (AdMob) [noBids, GADNativeAd]",
                     tags: [.native, .admob, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let nativeController = PrebidAdMobNativeViewController(rootController: adapterVC)
                nativeController.adMobAdUnitId = "ca-app-pub-5922967660082475/8634069303"
                         
                nativeController.prebidConfigId = "prebid-demo-no-bids"
                nativeController.nativeAssets = .defaultNativeRequestAssets
                nativeController.eventTrackers = .defaultNativeEventTrackers
                         
                adapterVC.setup(adapter: nativeController)
                setupCustomParams(for: nativeController.prebidConfigId)
            }),
            
            // MARK: ---- Native (In-App) ----
            
            TestCase(title: "Native Ad (In-App)",
                     tags: [.native, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let nativeAdController = PrebidNativeAdController(rootController: adapterVC)
                nativeAdController.setupNativeAdView(NativeAdViewBox())

                nativeAdController.prebidConfigId = "prebid-ita-banner-native-styles"

                nativeAdController.nativeAssets = .defaultNativeRequestAssets
                nativeAdController.eventTrackers = .defaultNativeEventTrackers
                adapterVC.setup(adapter: nativeAdController)

                setupCustomParams(for: nativeAdController.prebidConfigId)
            }),
            
            TestCase(title: "Native Ad Events (In-App)",
                     tags: [.native, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                Prebid.shared.prebidServerAccountId = "prebid-stored-request-enabled-events"
                         
                let nativeAdController = PrebidNativeAdController(rootController: adapterVC)
                nativeAdController.setupNativeAdView(NativeAdViewBox())

                nativeAdController.prebidConfigId = "prebid-ita-banner-native-styles"

                nativeAdController.nativeAssets = .defaultNativeRequestAssets
                nativeAdController.eventTrackers = .defaultNativeEventTrackers
                adapterVC.setup(adapter: nativeAdController)

                setupCustomParams(for: nativeAdController.prebidConfigId)
            }),

            TestCase(title: "Native Ad Links (In-App)",
                     tags: [.native, .inapp, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let nativeAdController = PrebidNativeAdController(rootController: adapterVC)
                nativeAdController.setupNativeAdView(NativeAdViewBoxLinks())
                nativeAdController.prebidConfigId = "prebid-demo-native-links"
                         
                Prebid.shared.shouldAssignNativeAssetID = true
                         
                let sponsored = NativeAssetData(type: .sponsored, required: true)
                let rating = NativeAssetData(type: .rating, required: true)
                let desc = NativeAssetData(type: .description, required: true)
                let cta = NativeAssetData(type: .ctatext, required: true)
                         
                nativeAdController.nativeAssets = [sponsored, desc, rating, cta]
                nativeAdController.eventTrackers = .defaultNativeEventTrackers

                adapterVC.setup(adapter: nativeAdController)

                setupCustomParams(for: nativeAdController.prebidConfigId)
            }),

            TestCase(title: "Native Ad Feed (In-App)",
                     tags: [.native, .inapp, .server],
                     exampleVCStoryboardID: "PrebidFeedTableViewController",
                     configurationClosure: { vc in

                guard let feedVC = vc as? PrebidFeedTableViewController else {
                    return
                }

                let nativeAdFeedController = PrebidNativeAdFeedController(rootTableViewController: feedVC)

                nativeAdFeedController.prebidConfigId = "prebid-ita-banner-native-styles"
                nativeAdFeedController.nativeAssets = .defaultNativeRequestAssets
                nativeAdFeedController.eventTrackers = .defaultNativeEventTrackers

                feedVC.adapter = nativeAdFeedController
                feedVC.loadAdClosure = nativeAdFeedController.allowLoadingAd

                nativeAdFeedController.createCells()

                setupCustomParams(for: nativeAdFeedController.prebidConfigId)
            }),
            
            // MARK: ---- Native (GAM, CustomTemplate) ----

            TestCase(title: "Native Ad Custom Templates (GAM) [OK, NativeAd]",
                     tags: [.native, .gam,.server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamNativeAdController = PrebidGAMNativeAdController(rootController: adapterVC)

                gamNativeAdController.prebidConfigId = "prebid-ita-banner-native-styles"
                gamNativeAdController.gamAdUnitId = "/21808260008/apollo_custom_template_native_ad_unit"
                gamNativeAdController.adTypes = [.customNative]
                gamNativeAdController.gamCustomTemplateIDs = ["11934135"]

                gamNativeAdController.nativeAssets = .defaultNativeRequestAssets
                gamNativeAdController.eventTrackers = .defaultNativeEventTrackers

                adapterVC.setup(adapter: gamNativeAdController)

                setupCustomParams(for: gamNativeAdController.prebidConfigId)
            }),

            
            TestCase(title: "Native Ad Custom Templates Events (GAM) [OK, NativeAd]",
                     tags: [.native, .gam,.server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                Prebid.shared.prebidServerAccountId = "prebid-stored-request-enabled-events"
                         
                let gamNativeAdController = PrebidGAMNativeAdController(rootController: adapterVC)

                gamNativeAdController.prebidConfigId = "prebid-ita-banner-native-styles"
                gamNativeAdController.gamAdUnitId = "/21808260008/apollo_custom_template_native_ad_unit"
                gamNativeAdController.adTypes = [.customNative]
                gamNativeAdController.gamCustomTemplateIDs = ["11934135"]

                gamNativeAdController.nativeAssets = .defaultNativeRequestAssets
                gamNativeAdController.eventTrackers = .defaultNativeEventTrackers

                adapterVC.setup(adapter: gamNativeAdController)

                setupCustomParams(for: gamNativeAdController.prebidConfigId)
            }),
            
            TestCase(title: "Native Ad (GAM) [OK, GADNativeCustomTemplateAd]",
                     tags: [.native, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamNativeAdController = PrebidGAMNativeAdController(rootController: adapterVC)

                gamNativeAdController.prebidConfigId = "prebid-ita-banner-native-styles"
                gamNativeAdController.gamAdUnitId = "/21808260008/apollo_custom_template_native_ad_unit"
                gamNativeAdController.adTypes = [.customNative]
                gamNativeAdController.gamCustomTemplateIDs = ["11982639"]

                gamNativeAdController.nativeAssets = .defaultNativeRequestAssets
                gamNativeAdController.eventTrackers = .defaultNativeEventTrackers

                adapterVC.setup(adapter: gamNativeAdController)

                setupCustomParams(for: gamNativeAdController.prebidConfigId)
            }),

            TestCase(title: "Native Ad (GAM) [noBids, GADNativeCustomTemplateAd]",
                     tags: [.native, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamNativeAdController = PrebidGAMNativeAdController(rootController: adapterVC)

                gamNativeAdController.prebidConfigId = "prebid-demo-native-video-with-end-card--dummy"
                gamNativeAdController.gamAdUnitId = "/21808260008/apollo_custom_template_native_ad_unit"
                gamNativeAdController.adTypes = [.customNative]
                gamNativeAdController.gamCustomTemplateIDs = ["11982639"]

                gamNativeAdController.nativeAssets = .defaultNativeRequestAssets
                gamNativeAdController.eventTrackers = .defaultNativeEventTrackers

                adapterVC.setup(adapter: gamNativeAdController)

                setupCustomParams(for: gamNativeAdController.prebidConfigId)
            }),

            TestCase(title: "Native Ad Feed (GAM) [OK, NativeAd]",
                     tags: [.native, .gam, .server],
                     exampleVCStoryboardID: "PrebidFeedTableViewController",
                     configurationClosure: { vc in

                guard let feedVC = vc as? PrebidFeedTableViewController else {
                    return
                }
                let gamNativeAdController = PrebidGAMNativeAdFeedController(rootTableViewController: feedVC)

                gamNativeAdController.prebidConfigId = "prebid-ita-banner-native-styles"
                gamNativeAdController.gamAdUnitId = "/21808260008/apollo_custom_template_native_ad_unit"
                gamNativeAdController.adTypes = [.customNative]
                gamNativeAdController.gamCustomTemplateIDs = ["11934135"]
                gamNativeAdController.nativeAssets = .defaultNativeRequestAssets
                gamNativeAdController.eventTrackers = .defaultNativeEventTrackers

                feedVC.adapter = gamNativeAdController
                feedVC.loadAdClosure = gamNativeAdController.allowLoadingAd

                gamNativeAdController.createCells()

                setupCustomParams(for: gamNativeAdController.prebidConfigId)
            }),
            
            // MARK: ---- Native (GAM, Unified) ----

            TestCase(title: "Native Ad Unified Ad (GAM) [OK, NativeAd]",
                     tags: [.native, .gam,.server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamNativeAdController = PrebidGAMNativeAdController(rootController: adapterVC)
                           
                gamNativeAdController.prebidConfigId = "prebid-ita-banner-native-styles"
                gamNativeAdController.gamAdUnitId = "/21808260008/unified_native_ad_unit"
                gamNativeAdController.adTypes = [.native]
                        
                gamNativeAdController.nativeAssets = .defaultNativeRequestAssets
                gamNativeAdController.eventTrackers = .defaultNativeEventTrackers
                         
                adapterVC.setup(adapter: gamNativeAdController)
                        
                setupCustomParams(for: gamNativeAdController.prebidConfigId)
            }),
            
            TestCase(title: "Native Ad (GAM) [OK, GADUnifiedNativeAd]",
                     tags: [.native, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamNativeAdController = PrebidGAMNativeAdController(rootController: adapterVC)
                        
                gamNativeAdController.prebidConfigId = "prebid-ita-banner-native-styles"
                gamNativeAdController.gamAdUnitId = "/21808260008/unified_native_ad_unit_static"
                gamNativeAdController.adTypes = [.native]
                        
                gamNativeAdController.nativeAssets = .defaultNativeRequestAssets
                gamNativeAdController.eventTrackers = .defaultNativeEventTrackers
                        
                adapterVC.setup(adapter: gamNativeAdController)
                        
                setupCustomParams(for: gamNativeAdController.prebidConfigId)
            }),
            
            TestCase(title: "Native Ad (GAM) [noBids, GADUnifiedNativeAd]",
                     tags: [.native, .gam, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let gamNativeAdController = PrebidGAMNativeAdController(rootController: adapterVC)
                        
                gamNativeAdController.prebidConfigId = "prebid-demo-native-video-with-end-card--dummy"
                gamNativeAdController.gamAdUnitId = "/21808260008/unified_native_ad_unit_static"
                gamNativeAdController.adTypes = [.native]
                
                gamNativeAdController.nativeAssets = .defaultNativeRequestAssets
                gamNativeAdController.eventTrackers = .defaultNativeEventTrackers
                        
                adapterVC.setup(adapter: gamNativeAdController)
                        
                setupCustomParams(for: gamNativeAdController.prebidConfigId)
            }),
            
            // MARK: ---- Banner (MAX) ----
            
            TestCase(title: "Banner 320x50 (MAX) [OK, OXB Adapter]",
                     tags: [.banner, .max, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let maxBannerController = PrebidMAXBannerController(rootController: adapterVC)
                maxBannerController.maxAdUnitId = "5f111f4bcd0f58ca"
                maxBannerController.adUnitSize = CGSize(width: 320, height: 50);
                        
                maxBannerController.prebidConfigId = "prebid-ita-banner-320-50"
                 
                adapterVC.setup(adapter: maxBannerController)
                        
                setupCustomParams(for: maxBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 Events (MAX) [OK, OXB Adapter]",
                     tags: [.banner, .max, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                Prebid.shared.prebidServerAccountId = "prebid-stored-request-enabled-events"
                         
                let maxBannerController = PrebidMAXBannerController(rootController: adapterVC)
                maxBannerController.maxAdUnitId = "5f111f4bcd0f58ca"
                maxBannerController.adUnitSize = CGSize(width: 320, height: 50);
                        
                maxBannerController.prebidConfigId = "prebid-ita-banner-320-50"
                 
                adapterVC.setup(adapter: maxBannerController)
                        
                setupCustomParams(for: maxBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (MAX) [noBids, MAX Ad]",
                     tags: [.banner, .max, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let maxBannerController = PrebidMAXBannerController(rootController: adapterVC)
                maxBannerController.prebidConfigId = "prebid-demo-no-bids"
                maxBannerController.maxAdUnitId = "5f111f4bcd0f58ca"
                maxBannerController.adUnitSize = CGSize(width: 320, height: 50);
                adapterVC.setup(adapter: maxBannerController)
                        
                setupCustomParams(for: maxBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (MAX) [OK, Random]",
                     tags: [.banner, .max, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let maxBannerController = PrebidMAXBannerController(rootController: adapterVC)
                maxBannerController.prebidConfigId = "prebid-ita-banner-320-50"
                maxBannerController.maxAdUnitId = "5f111f4bcd0f58ca"
                maxBannerController.adUnitSize = CGSize(width: 320, height: 50);
                adapterVC.setup(adapter: maxBannerController)
                        
                setupCustomParams(for: maxBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (MAX) [Random, Respective]",
                     tags: [.banner, .max, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                        
                let maxBannerController = PrebidMAXBannerController(rootController: adapterVC)
                maxBannerController.prebidConfigId = "prebid-ita-banner-320-50"
                maxBannerController.maxAdUnitId = "5f111f4bcd0f58ca"
                maxBannerController.adUnitSize = CGSize(width: 320, height: 50);
                adapterVC.setup(adapter: maxBannerController)
                        
                setupCustomParams(for: maxBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 300x250 (MAX)",
                     tags: [.banner, .max, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let maxBannerController = PrebidMAXBannerController(rootController: adapterVC)
                maxBannerController.prebidConfigId = "prebid-ita-banner-300-250"
                maxBannerController.maxAdUnitId = "7715f9965a065152"
                maxBannerController.adUnitSize = CGSize(width: 300, height: 250);
                adapterVC.setup(adapter: maxBannerController)
                        
                setupCustomParams(for: maxBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner Adaptive (MAX)",
                     tags: [.banner, .max, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let maxBannerController = PrebidMAXBannerController(rootController: adapterVC)
                maxBannerController.prebidConfigId = "prebid-demo-banner-multisize"
                maxBannerController.maxAdUnitId = "5f111f4bcd0f58ca"
                maxBannerController.adUnitSize = CGSize(width: 320, height: 50);
                maxBannerController.additionalAdSizes = [CGSize(width: 728, height: 90)]
                maxBannerController.isAdaptive = true
                adapterVC.setup(adapter: maxBannerController)
                        
                setupCustomParams(for: maxBannerController.prebidConfigId)
            }),
            
            // MARK: ---- Interstitial (MAX) ----
            
            TestCase(title: "Display Interstitial 320x480 (MAX) [OK, OXB Adapter]",
                     tags: [.interstitial, .max, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let maxInterstitialController = PrebidMAXInterstitialController(rootController: adapterVC)
                maxInterstitialController.adFormats = [.banner]
                maxInterstitialController.maxAdUnitId = "78f9d445b8a1add7"
                maxInterstitialController.prebidConfigId = "prebid-ita-display-interstitial-320-480"
                adapterVC.setup(adapter: maxInterstitialController)
                        
                setupCustomParams(for: maxInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Display Interstitial 320x480 (MAX) [noBids, MAX Ad]",
                     tags: [.interstitial, .max, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let maxInterstitialController = PrebidMAXInterstitialController(rootController: adapterVC)
                maxInterstitialController.adFormats = [.banner]
                maxInterstitialController.prebidConfigId = "prebid-demo-no-bids"
                maxInterstitialController.maxAdUnitId = "78f9d445b8a1add7"
                adapterVC.setup(adapter: maxInterstitialController)
                        
                setupCustomParams(for: maxInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Display Interstitial 320x480 (MAX) [OK, Random]",
                     tags: [.interstitial, .max, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let maxInterstitialController = PrebidMAXInterstitialController(rootController: adapterVC)
                maxInterstitialController.adFormats = [.banner]
                maxInterstitialController.prebidConfigId = "prebid-ita-display-interstitial-320-480"
                maxInterstitialController.maxAdUnitId = "78f9d445b8a1add7"
                adapterVC.setup(adapter: maxInterstitialController)
                        
                setupCustomParams(for: maxInterstitialController.prebidConfigId)
            }),
            
            // MARK: ---- Video Interstitial (MAX) ----
            
            TestCase(title: "Video Interstitial 320x480 (MAX) [OK, OXB Adapter]",
                     tags: [.video, .max, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let maxInterstitialController = PrebidMAXInterstitialController(rootController: adapterVC)
                maxInterstitialController.prebidConfigId = "prebid-ita-video-interstitial-320-480"
                maxInterstitialController.adFormats = [.video]
                maxInterstitialController.maxAdUnitId = "78f9d445b8a1add7"
                adapterVC.setup(adapter: maxInterstitialController)
                        
                setupCustomParams(for: maxInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial With Ad Configuration 320x480 API (MAX) [OK, OXB Adapter]",
                     tags: [.video, .max, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let maxInterstitialController = PrebidMAXInterstitialController(rootController: adapterVC)
                maxInterstitialController.prebidConfigId = "prebid-ita-video-interstitial-320-480"
                maxInterstitialController.adFormats = [.video]
                maxInterstitialController.maxAdUnitId = "78f9d445b8a1add7"
                        
                // Custom video configuration
                maxInterstitialController.maxDuration = 30
                maxInterstitialController.closeButtonArea = 0.15
                maxInterstitialController.closeButtonPosition = .topLeft
                maxInterstitialController.skipDelay = 5
                         
                adapterVC.setup(adapter: maxInterstitialController)
                        
                setupCustomParams(for: maxInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial With Ad Configuration With End Card 320x480 API (MAX) [OK, OXB Adapter]",
                     tags: [.video, .max, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let maxInterstitialController = PrebidMAXInterstitialController(rootController: adapterVC)
                maxInterstitialController.prebidConfigId = "prebid-demo-video-interstitial-320-480-with-end-card"
                maxInterstitialController.adFormats = [.video]
                maxInterstitialController.maxAdUnitId = "78f9d445b8a1add7"
                      
                // Custom video configuration
                maxInterstitialController.maxDuration = 30
                maxInterstitialController.closeButtonArea = 0.15
                maxInterstitialController.closeButtonPosition = .topLeft
                maxInterstitialController.skipButtonArea = 0.15
                maxInterstitialController.skipButtonPosition = .topRight
                maxInterstitialController.skipDelay = 5
                         
                adapterVC.setup(adapter: maxInterstitialController)
                        
                setupCustomParams(for: maxInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial With Ad Configuration 320x480 Server (MAX) [OK, OXB Adapter]",
                     tags: [.video, .max, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let maxInterstitialController = PrebidMAXInterstitialController(rootController: adapterVC)
                maxInterstitialController.prebidConfigId = "prebid-demo-video-interstitial-320-480-with-ad-configuration"
                maxInterstitialController.adFormats = [.video]
                maxInterstitialController.maxAdUnitId = "78f9d445b8a1add7"
                adapterVC.setup(adapter: maxInterstitialController)
                        
                setupCustomParams(for: maxInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial With Ad Configuration With End Card 320x480 Server (MAX) [OK, OXB Adapter]",
                     tags: [.video, .max, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let maxInterstitialController = PrebidMAXInterstitialController(rootController: adapterVC)
                maxInterstitialController.prebidConfigId = "prebid-demo-video-interstitial-320-480-with-end-card-with-ad-configuration"
                maxInterstitialController.adFormats = [.video]
                maxInterstitialController.maxAdUnitId = "78f9d445b8a1add7"
                adapterVC.setup(adapter: maxInterstitialController)
                        
                setupCustomParams(for: maxInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial 320x480 (MAX) [OK, Random]",
                     tags: [.video, .max, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let maxInterstitialController = PrebidMAXInterstitialController(rootController: adapterVC)
                maxInterstitialController.prebidConfigId = "prebid-ita-video-interstitial-320-480"
                maxInterstitialController.adFormats = [.video]
                maxInterstitialController.maxAdUnitId = "78f9d445b8a1add7"
                adapterVC.setup(adapter: maxInterstitialController)
                        
                setupCustomParams(for: maxInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial 320x480 (MAX) [noBids, MAX Ad]",
                     tags: [.video, .max, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let maxInterstitialController = PrebidMAXInterstitialController(rootController: adapterVC)
                maxInterstitialController.prebidConfigId = "prebid-demo-no-bids"
                maxInterstitialController.adFormats = [.video]
                maxInterstitialController.maxAdUnitId = "78f9d445b8a1add7"
                adapterVC.setup(adapter: maxInterstitialController)
                        
                setupCustomParams(for: maxInterstitialController.prebidConfigId)
            }),
            
            // MARK: ---- Multiformat Interstitial (MAX) ----
            
            TestCase(title: "Multiformat Interstitial 320x480 (MAX)",
                     tags: [.interstitial, .video, .max, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let randomId = [0, 1].randomElement() ?? 0
                let interstitialController = PrebidMAXInterstitialController(rootController: adapterVC)
                let configIds = ["prebid-ita-display-interstitial-320-480", "prebid-ita-video-interstitial-320-480"]
                interstitialController.prebidConfigId = configIds.randomElement()!
                         
                interstitialController.maxAdUnitId = "78f9d445b8a1add7"
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            // MARK: ---- Rewarded (MAX) ----
            
            TestCase(title: "Banner Rewarded Time 320x480 (MAX) [OK, OXB Adapter]",
                     tags: [.interstitial, .max, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let maxRewardedAdController = PrebidMAXRewardedController(rootController: adapterVC)
                maxRewardedAdController.maxAdUnitId = "8c68716a67d5a5af"
                maxRewardedAdController.prebidConfigId = "prebid-demo-banner-rewarded-time"
                adapterVC.setup(adapter: maxRewardedAdController)
                setupCustomParams(for: maxRewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "Video Rewarded Endcard Time 320x480 (MAX) [OK, OXB Adapter]",
                     tags: [.interstitial, .video, .max, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let maxRewardedAdController = PrebidMAXRewardedController(rootController: adapterVC)
                maxRewardedAdController.maxAdUnitId = "8c68716a67d5a5af"
                maxRewardedAdController.prebidConfigId = "prebid-demo-video-rewarded-endcard-time"
                adapterVC.setup(adapter: maxRewardedAdController)
                setupCustomParams(for: maxRewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "Video Rewarded 320x480 Time (MAX) [OK, OXB Adapter]",
                     tags: [.interstitial, .video, .max, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let maxRewardedAdController = PrebidMAXRewardedController(rootController: adapterVC)
                maxRewardedAdController.maxAdUnitId = "8c68716a67d5a5af"
                maxRewardedAdController.prebidConfigId = "prebid-demo-video-rewarded-time"
                adapterVC.setup(adapter: maxRewardedAdController)
                        
                setupCustomParams(for: maxRewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "Video Rewarded 320x480 Time With Server Ad Configuration (MAX) [OK, OXB Adapter]",
                     tags: [.interstitial, .video, .max, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let maxRewardedAdController = PrebidMAXRewardedController(rootController: adapterVC)
                maxRewardedAdController.maxAdUnitId = "8c68716a67d5a5af"
                maxRewardedAdController.prebidConfigId = "prebid-demo-video-rewarded-time-ad-config"
                adapterVC.setup(adapter: maxRewardedAdController)
                        
                setupCustomParams(for: maxRewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "Video Rewarded 320x480 (MAX) [noBids, MAX Ad]",
                     tags: [.interstitial, .video, .max, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let maxRewardedAdController = PrebidMAXRewardedController(rootController: adapterVC)
                maxRewardedAdController.maxAdUnitId = "8c68716a67d5a5af"
                maxRewardedAdController.prebidConfigId = "prebid-demo-no-bids"
                adapterVC.setup(adapter: maxRewardedAdController)
                        
                setupCustomParams(for: maxRewardedAdController.prebidConfigId)
            }),
            
            // MARK: ---- Native (MAX) ----
            
            TestCase(title: "Native Ad (MAX) [OK, OXB Adapter]",
                     tags: [.native, .max, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let nativeController = PrebidMAXNativeController(rootController: adapterVC)
                nativeController.maxAdUnitId = "f4c3d8281ebf3c39"
                nativeController.prebidConfigId = "prebid-ita-banner-native-styles"
                nativeController.nativeAssets = .defaultNativeRequestAssets
                nativeController.eventTrackers = .defaultNativeEventTrackers
                         
                adapterVC.setup(adapter: nativeController)
                setupCustomParams(for: nativeController.prebidConfigId)
            }),
            
            TestCase(title: "Native Ad Events (MAX) [OK, OXB Adapter]",
                     tags: [.native, .max, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                Prebid.shared.prebidServerAccountId = "prebid-stored-request-enabled-events"
                         
                let nativeController = PrebidMAXNativeController(rootController: adapterVC)
                nativeController.maxAdUnitId = "f4c3d8281ebf3c39"
                nativeController.prebidConfigId = "prebid-ita-banner-native-styles"
                nativeController.nativeAssets = .defaultNativeRequestAssets
                nativeController.eventTrackers = .defaultNativeEventTrackers
                         
                adapterVC.setup(adapter: nativeController)
                setupCustomParams(for: nativeController.prebidConfigId)
            }),
            
            TestCase(title: "Native Ad (MAX) [noBids, MAX Ad]",
                     tags: [.native, .max, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                         
                let nativeController = PrebidMAXNativeController(rootController: adapterVC)
                nativeController.maxAdUnitId = "f4c3d8281ebf3c39"
                nativeController.prebidConfigId = "prebid-demo-no-bids"
                nativeController.nativeAssets = .defaultNativeRequestAssets
                nativeController.eventTrackers = .defaultNativeEventTrackers
                         
                adapterVC.setup(adapter: nativeController)
                setupCustomParams(for: nativeController.prebidConfigId)
            }),
        ]
    }()
    
    // MARK: - Helper Methods
    private static func setupCustomParams(for prebidConfigId: String) {
        if let customParams = TestCaseManager.customORTBParams["configId"]?[prebidConfigId] {
            TestCaseManager.updateUserData(customParams)
        }
    }

    static func createDummyTableCell(for tableView: UITableView) -> TestCaseForTableCell {
        return TestCaseForTableCell(configurationClosureForTableCell: { cell in
            cell = tableView.dequeueReusableCell(withIdentifier: "DummyTableViewCell")
        });
    }
    
    // MALE, FEMALE, OTHER to PBMGender {
    private static func strToGender(_ gender: String) -> Gender {
        switch gender {
            case "MALE":
                return .male
            case "FEMALE":
                return .female
            case "OTHER":
                return .female
            default:
                return .unknown
        }
    }
}
