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

import OpenXMockServer
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
        let targeting = PrebidRenderingTargeting.shared
        
        if let age = openRtb["age"] as? NSNumber {
            targeting.userAge = age
        }
        
        if let value = openRtb["url"] as? String {
            targeting.appStoreMarketURL = value
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
            targeting.keywords = value
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
        
            // MARK: ---- Banner (In-App) ----
            
            TestCase(title: "Banner 320x50 (In-App)",
                     tags: [.banner, .inapp, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                        
                if AppConfiguration.shared.useMockServer {
                    bannerController.prebidConfigId = "mock-banner-320-50"
                } else {
                    bannerController.prebidConfigId = "50699c03-0910-477c-b4a4-911dbe2b9d42"
                }
                        
                adapterVC.setup(adapter: bannerController)
                        
               setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (In-App) [noBids]",
                     tags: [.banner, .inapp, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                        
                if AppConfiguration.shared.useMockServer {
                    bannerController.prebidConfigId = "mock-no-bids"
                } else {
                    PrebidRenderingConfig.shared.accountID = "1768035c-74d3-4786-b056-13bd41f34bde"
                    bannerController.prebidConfigId = "28259226-68de-49f8-88d6-f0f2fab846e3"
                }
                        
                adapterVC.setup(adapter: bannerController)
                        
               setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (In-App) [Items]",
                     tags: [.banner, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "mock-banner-items"
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (In-App) [New Tab]",
                     tags: [.banner, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                        
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "mock-banner-newtab"
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (In-App) [Incorrect VAST]",
                     tags: [.banner, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                        
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "mock-banner-incorrect-vast"
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (In-App) [DeepLink+]",
                     tags: [.banner, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "mock-banner-deeplink"
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (In-App) [Scrollable]",
                     tags: [.banner, .inapp, .mock],
                     exampleVCStoryboardID: "ScrollableAdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "mock-banner-320-50"
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 300x250 (In-App)",
                     tags: [.banner, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                        
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "mock-banner-300-250"
                bannerController.adSizes = [CGSize(width: 300, height: 250)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 728x90 (In-App)",
                     tags: [.banner, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "mock-banner-728-90"
                bannerController.adSizes = [CGSize(width: 728, height: 90)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner Multisize (In-App)",
                     tags: [.banner, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "mock-banner-multisize"
                bannerController.adSizes = [CGSize(width: 320, height: 50), CGSize(width: 728, height: 90)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (In-App) ATS",
                     tags: [.banner, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                        
                       
                                       
                PrebidRenderingTargeting.shared.eids = [
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
                bannerController.prebidConfigId = "mock-banner-320-50"
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (In-App) [SKAdN]",
                     tags: [.banner, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "mock-banner-320-50-skadn"
                bannerController.adSizes = [CGSize(width: 320, height: 50)]

                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (In-App) [SKAdN 2.2]",
                     tags: [.banner, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "mock-banner-320-50-skadn-v22"
                bannerController.adSizes = [CGSize(width: 320, height: 50)]

                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            // MARK: ---- Banner (GAM) ----
            
            TestCase(title: "Banner 320x50 (GAM) [OK, AppEvent]",
                     tags: [.banner, .gam, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
                gamBannerController.gamAdUnitId = "/21808260008/prebid_oxb_320x50_banner"
                gamBannerController.validAdSizes = [kGADAdSizeBanner]
                        
                if AppConfiguration.shared.useMockServer {
                    gamBannerController.prebidConfigId = "mock-banner-320-50"
                } else {
                    gamBannerController.prebidConfigId = "50699c03-0910-477c-b4a4-911dbe2b9d42"
                }
                        
                adapterVC.setup(adapter: gamBannerController)
                        
                setupCustomParams(for: gamBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (GAM) [OK, GAM Ad]",
                     tags: [.banner, .gam, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
                gamBannerController.prebidConfigId = "mock-banner-320-50"
                gamBannerController.gamAdUnitId = "/21808260008/prebid_oxb_320x50_banner_static"
                gamBannerController.validAdSizes = [kGADAdSizeBanner]
                adapterVC.setup(adapter: gamBannerController)
                        
                setupCustomParams(for: gamBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (GAM) [noBids, GAM Ad]",
                     tags: [.banner, .gam, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)

                if AppConfiguration.shared.useMockServer {
                    gamBannerController.prebidConfigId = "mock-no-bids"
                } else {
                    PrebidRenderingConfig.shared.accountID = "1768035c-74d3-4786-b056-13bd41f34bde"
                    gamBannerController.prebidConfigId = "28259226-68de-49f8-88d6-f0f2fab846e3"
                }
                gamBannerController.gamAdUnitId = "/21808260008/prebid_oxb_320x50_banner_static"
                gamBannerController.validAdSizes = [kGADAdSizeBanner]
                adapterVC.setup(adapter: gamBannerController)
                        
                setupCustomParams(for: gamBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (GAM) [OK, Random]",
                     tags: [.banner, .gam, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
                gamBannerController.prebidConfigId = "mock-banner-320-50"
                gamBannerController.gamAdUnitId = "/21808260008/prebid_oxb_320x50_banner_random"
                gamBannerController.validAdSizes = [kGADAdSizeBanner]
                adapterVC.setup(adapter: gamBannerController)
                        
                setupCustomParams(for: gamBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (GAM) [Random, Respective]",
                     tags: [.banner, .gam, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                        
                let mockServer = PBMMockServer()
                mockServer.setRandomNoBids();
                        
                adapterVC.postActionClosure = {
                    let mockServer = PBMMockServer()
                    mockServer.cancelRandomNoBids();
                }
                        
                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
                gamBannerController.prebidConfigId = "mock-banner-320-50"
                gamBannerController.gamAdUnitId = "/21808260008/prebid_oxb_320x50_banner"
                gamBannerController.validAdSizes = [kGADAdSizeBanner]
                adapterVC.setup(adapter: gamBannerController)
                        
                setupCustomParams(for: gamBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 300x250 (GAM)",
                     tags: [.banner, .gam, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
                gamBannerController.prebidConfigId = "mock-banner-300-250"
                gamBannerController.gamAdUnitId = "/21808260008/prebid_oxb_300x250_banner"
                gamBannerController.validAdSizes = [kGADAdSizeMediumRectangle]
                adapterVC.setup(adapter: gamBannerController)
                        
                setupCustomParams(for: gamBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 728x90 (GAM)",
                     tags: [.banner, .gam, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
                gamBannerController.prebidConfigId = "mock-banner-728-90"
                gamBannerController.gamAdUnitId = "/21808260008/prebid_oxb_728x90_banner"
                gamBannerController.validAdSizes = [kGADAdSizeLeaderboard]
                adapterVC.setup(adapter: gamBannerController)
                        
                setupCustomParams(for: gamBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner Multisize (GAM)",
                     tags: [.banner, .gam, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
                gamBannerController.prebidConfigId = "mock-banner-multisize"
                gamBannerController.gamAdUnitId = "/21808260008/prebid_oxb_multisize_banner"
                gamBannerController.validAdSizes = [kGADAdSizeBanner, kGADAdSizeLeaderboard]
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
                gamBannerController.prebidConfigId = "50699c03-0910-477c-b4a4-911dbe2b9d42"
                gamBannerController.gamAdUnitId = "/21808260008/prebid_android_300x250_banner"
                gamBannerController.validAdSizes = [kGADAdSizeBanner]
                adapterVC.setup(adapter: gamBannerController)
                        
                setupCustomParams(for: gamBannerController.prebidConfigId)
            }),
            
            // MARK: ---- Banner (MoPub) ----
            
            TestCase(title: "Banner 320x50 (MoPub) [OK, OXB Adapter]",
                     tags: [.banner, .mopub, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let mopubBannerController = PrebidMoPubBannerController(rootController: adapterVC)
                mopubBannerController.moPubAdUnitId = "0df35635801e4110b65e762a62437698"
                mopubBannerController.adUnitSize = CGSize(width: 320, height: 50);
                        
                if AppConfiguration.shared.useMockServer {
                    mopubBannerController.prebidConfigId = "mock-banner-320-50"
                } else {
                    mopubBannerController.prebidConfigId = "50699c03-0910-477c-b4a4-911dbe2b9d42"
                }
                 
                adapterVC.setup(adapter: mopubBannerController)
                        
                setupCustomParams(for: mopubBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (MoPub) [OK, Random]",
                     tags: [.banner, .mopub, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let mopubBannerController = PrebidMoPubBannerController(rootController: adapterVC)
                mopubBannerController.prebidConfigId = "mock-banner-320-50"
                mopubBannerController.moPubAdUnitId = "6f69ef70b52f427fa9a1277337ca72fc"
                mopubBannerController.adUnitSize = CGSize(width: 320, height: 50);
                adapterVC.setup(adapter: mopubBannerController)
                        
                setupCustomParams(for: mopubBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (MoPub) [noBids, MoPub Ad]",
                     tags: [.banner, .mopub, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let mopubBannerController = PrebidMoPubBannerController(rootController: adapterVC)

                if AppConfiguration.shared.useMockServer {
                    mopubBannerController.prebidConfigId = "mock-no-bids"
                } else {
                    PrebidRenderingConfig.shared.accountID = "1768035c-74d3-4786-b056-13bd41f34bde"
                    mopubBannerController.prebidConfigId = "28259226-68de-49f8-88d6-f0f2fab846e3"
                }
                mopubBannerController.moPubAdUnitId = "2b664935d41c4f4f8b8148ae39d22c99"
                mopubBannerController.adUnitSize = CGSize(width: 320, height: 50);
                adapterVC.setup(adapter: mopubBannerController)
                        
                setupCustomParams(for: mopubBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (MoPub) [Random, Respective]",
                     tags: [.banner, .mopub, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                        
                let mockServer = PBMMockServer()
                mockServer.setRandomNoBids();
                        
                adapterVC.postActionClosure = {
                    let mockServer = PBMMockServer()
                    mockServer.cancelRandomNoBids();
                }

                let mopubBannerController = PrebidMoPubBannerController(rootController: adapterVC)
                mopubBannerController.prebidConfigId = "mock-banner-320-50"
                mopubBannerController.moPubAdUnitId = "2b664935d41c4f4f8b8148ae39d22c99"
                mopubBannerController.adUnitSize = CGSize(width: 320, height: 50);
                adapterVC.setup(adapter: mopubBannerController)
                        
                setupCustomParams(for: mopubBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 300x250 (MoPub)",
                     tags: [.banner, .mopub, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let mopubBannerController = PrebidMoPubBannerController(rootController: adapterVC)
                mopubBannerController.prebidConfigId = "mock-banner-300-250"
                mopubBannerController.moPubAdUnitId = "8ac25e6a5d0f4f9293e6520ccd35a572"
                mopubBannerController.adUnitSize = CGSize(width: 300, height: 250);
                adapterVC.setup(adapter: mopubBannerController)
                        
                setupCustomParams(for: mopubBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 728x90 (MoPub)",
                     tags: [.banner, .mopub, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let mopubBannerController = PrebidMoPubBannerController(rootController: adapterVC)
                mopubBannerController.prebidConfigId = "mock-banner-728-90"
                mopubBannerController.moPubAdUnitId = "c33fd3d864e94306b2fc698dc88f4f8c"
                mopubBannerController.adUnitSize = CGSize(width: 728, height: 90);
                adapterVC.setup(adapter: mopubBannerController)
                        
                setupCustomParams(for: mopubBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner Multisize (MoPub)",
                     tags: [.banner, .mopub, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let mopubBannerController = PrebidMoPubBannerController(rootController: adapterVC)
                mopubBannerController.prebidConfigId = "mock-banner-multisize"
                mopubBannerController.moPubAdUnitId = "a64373c094d4461e9521bf3f7b9f39f0"
                mopubBannerController.adUnitSize = CGSize(width: 320, height: 50);
                mopubBannerController.additionalAdSizes = [CGSize(width: 728, height: 90)]
                adapterVC.setup(adapter: mopubBannerController)
                        
                setupCustomParams(for: mopubBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Banner 320x50 (MoPub) [Vanilla Prebid Order]",
                     tags: [.banner, .mopub, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let mopubBannerController = PrebidMoPubBannerController(rootController: adapterVC)
                mopubBannerController.prebidConfigId = "50699c03-0910-477c-b4a4-911dbe2b9d42"
                mopubBannerController.moPubAdUnitId = "062f48338d404485aca738bd70e71878"
                mopubBannerController.adUnitSize = CGSize(width: 320, height: 50);
                adapterVC.setup(adapter: mopubBannerController)
                        
                setupCustomParams(for: mopubBannerController.prebidConfigId)
            }),
            
            // MARK: ---- Interstitial (In-App) ----
            
            TestCase(title: "Display Interstitial 320x480 (In-App)",
                     tags: [.interstitial, .inapp, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                
                if AppConfiguration.shared.useMockServer {
                    interstitialController.prebidConfigId = "mock-display-interstitial-320-480"
                } else {
                    interstitialController.prebidConfigId = "5a4b8dcf-f984-4b04-9448-6529908d6cb6"
                }
                 
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Display Interstitial 320x480 (In-App) [noBids]",
                     tags: [.interstitial, .inapp, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                if AppConfiguration.shared.useMockServer {
                    interstitialController.prebidConfigId = "mock-no-bids"
                } else {
                    PrebidRenderingConfig.shared.accountID = "1768035c-74d3-4786-b056-13bd41f34bde"
                    interstitialController.prebidConfigId = "28259226-68de-49f8-88d6-f0f2fab846e3"
                }
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Display Interstitial 320x480 (In-App) [Presentation]",
                     tags: [.interstitial, .inapp, .mock],
                     exampleVCStoryboardID: "PrebidPresentationViewController",
                     configurationClosure: { vc in
                guard let presentationVC = vc as? PrebidPresentationViewController else {
                    return
                }
                presentationVC.prebidConfigId = "mock-display-interstitial-320-480"
                        
                setupCustomParams(for: presentationVC.prebidConfigId)
            }),
            
            TestCase(title: "Display Interstitial Multisize (In-App)",
                     tags: [.interstitial, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "mock-display-interstitial-multisize"
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Display Interstitial 320x480 (In-App) [SKAdN]",
                     tags: [.interstitial, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "mock-display-interstitial-320-480-skadn"

                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            // MARK: ---- Interstitial (GAM) ----
            
            TestCase(title: "Display Interstitial 320x480 (GAM) [OK, AppEvent]",
                     tags: [.interstitial, .gam, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamInterstitialController = PrebidGAMInterstitialController(rootController: adapterVC)
                gamInterstitialController.gamAdUnitId = "/21808260008/prebid_oxb_html_interstitial"
                        
                if AppConfiguration.shared.useMockServer {
                    gamInterstitialController.prebidConfigId = "mock-display-interstitial-320-480"
                } else {
                    gamInterstitialController.prebidConfigId = "5a4b8dcf-f984-4b04-9448-6529908d6cb6"
                }
                 
                adapterVC.setup(adapter: gamInterstitialController)
                        
                setupCustomParams(for: gamInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Display Interstitial 320x480 (GAM) [OK, Random]",
                     tags: [.interstitial, .gam, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamInterstitialController = PrebidGAMInterstitialController(rootController: adapterVC)
                gamInterstitialController.prebidConfigId = "mock-display-interstitial-320-480"
                gamInterstitialController.gamAdUnitId = "/21808260008/prebid_oxb_html_interstitial_random"
                adapterVC.setup(adapter: gamInterstitialController)
                        
                setupCustomParams(for: gamInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Display Interstitial 320x480 (GAM) [noBids, GAM Ad]",
                     tags: [.interstitial, .gam, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamInterstitialController = PrebidGAMInterstitialController(rootController: adapterVC)
                if AppConfiguration.shared.useMockServer {
                    gamInterstitialController.prebidConfigId = "mock-no-bids"
                } else {
                    PrebidRenderingConfig.shared.accountID = "1768035c-74d3-4786-b056-13bd41f34bde"
                    gamInterstitialController.prebidConfigId = "28259226-68de-49f8-88d6-f0f2fab846e3"
                }
                gamInterstitialController.gamAdUnitId = "/21808260008/prebid_oxb_320x480_html_interstitial_static"
                adapterVC.setup(adapter: gamInterstitialController)
                        
                setupCustomParams(for: gamInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Display Interstitial Multisize (GAM) [OK, AppEvent]",
                     tags: [.interstitial, .gam, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamInterstitialController = PrebidGAMInterstitialController(rootController: adapterVC)
                gamInterstitialController.prebidConfigId = "mock-display-interstitial-multisize"
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
                gamInterstitialController.prebidConfigId = "5a4b8dcf-f984-4b04-9448-6529908d6cb6"
                gamInterstitialController.gamAdUnitId = "/21808260008/prebid_html_interstitial"
                adapterVC.setup(adapter: gamInterstitialController)
                        
                setupCustomParams(for: gamInterstitialController.prebidConfigId)
            }),
            
            // MARK: ---- Interstitial (MoPub) ----
            
            TestCase(title: "Display Interstitial 320x480 (MoPub) [OK, OXB Adapter]",
                     tags: [.interstitial, .mopub, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let mopubInterstitialController = PrebidMoPubInterstitialController(rootController: adapterVC)
                mopubInterstitialController.moPubAdUnitId = "e979c52714434796909993e21c8fc8da"
                        
                if AppConfiguration.shared.useMockServer {
                    mopubInterstitialController.prebidConfigId = "mock-display-interstitial-320-480"
                } else {
                    mopubInterstitialController.prebidConfigId = "5a4b8dcf-f984-4b04-9448-6529908d6cb6"
                }
                 
                adapterVC.setup(adapter: mopubInterstitialController)
                        
                setupCustomParams(for: mopubInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Display Interstitial 320x480 (MoPub) [OK, Random]",
                     tags: [.interstitial, .mopub, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let mopubInterstitialController = PrebidMoPubInterstitialController(rootController: adapterVC)
                mopubInterstitialController.prebidConfigId = "mock-display-interstitial-320-480"
                mopubInterstitialController.moPubAdUnitId = "2c241851044c429f9f4df6ec19b847b6"
                adapterVC.setup(adapter: mopubInterstitialController)
                        
                setupCustomParams(for: mopubInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Display Interstitial 320x480 (MoPub) [noBids, MoPub Ad]",
                     tags: [.interstitial, .mopub, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let mopubInterstitialController = PrebidMoPubInterstitialController(rootController: adapterVC)
                if AppConfiguration.shared.useMockServer {
                    mopubInterstitialController.prebidConfigId = "mock-no-bids"
                } else {
                    PrebidRenderingConfig.shared.accountID = "1768035c-74d3-4786-b056-13bd41f34bde"
                    mopubInterstitialController.prebidConfigId = "28259226-68de-49f8-88d6-f0f2fab846e3"
                }
                mopubInterstitialController.moPubAdUnitId = "caa0c9304d6145da86bdc0e4d79e966b"
                adapterVC.setup(adapter: mopubInterstitialController)
                        
                setupCustomParams(for: mopubInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Display Interstitial Multisize (MoPub)",
                     tags: [.interstitial, .mopub, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let mopubInterstitialController = PrebidMoPubInterstitialController(rootController: adapterVC)
                mopubInterstitialController.prebidConfigId = "mock-display-interstitial-multisize"
                mopubInterstitialController.moPubAdUnitId = "e979c52714434796909993e21c8fc8da"
                adapterVC.setup(adapter: mopubInterstitialController)
                        
                setupCustomParams(for: mopubInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Display Interstitial 320x480 (MoPub) [Vanilla Prebid Order]",
                     tags: [.interstitial, .mopub, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let mopubInterstitialController = PrebidMoPubInterstitialController(rootController: adapterVC)
                mopubInterstitialController.prebidConfigId = "5a4b8dcf-f984-4b04-9448-6529908d6cb6"
                mopubInterstitialController.moPubAdUnitId = "b586a04a99f94bf683f8003d462ec02a"
                adapterVC.setup(adapter: mopubInterstitialController)
                        
                setupCustomParams(for: mopubInterstitialController.prebidConfigId)
            }),
            
            // MARK: ---- Video Interstitial (In-App) ----
            
            TestCase(title: "Video Interstitial 320x480 (In-App)",
                     tags: [.video, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "mock-video-interstitial-320-480"
                interstitialController.adFormat = .video
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),

            TestCase(title: "Video Interstitial 320x480 (In-App) [noBids]",
                     tags: [.video, .inapp, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                if AppConfiguration.shared.useMockServer {
                    interstitialController.prebidConfigId = "mock-no-bids"
                } else {
                    PrebidRenderingConfig.shared.accountID = "1768035c-74d3-4786-b056-13bd41f34bde"
                    interstitialController.prebidConfigId = "28259226-68de-49f8-88d6-f0f2fab846e3"
                }
                interstitialController.adFormat = .video
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial 320x480 with End Card (In-App)",
                     tags: [.video, .inapp, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                if AppConfiguration.shared.useMockServer {
                    interstitialController.prebidConfigId = "mock-video-interstitial-320-480-with-end-card"
                } else {
                    interstitialController.prebidConfigId = "12f58bc2-b664-4672-8d19-638bcc96fd5c"
                }
                interstitialController.adFormat = .video
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial Vertical (In-App)",
                     tags: [.video, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "mock-video-interstitial-vertical"
                interstitialController.adFormat = .video
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial 320x480 DeepLink+ (In-App)",
                     tags: [.video, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "mock-video-interstitial-320-480-deeplink"
                interstitialController.adFormat = .video
                
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial 320x480 SkipOffset (In-App)",
                     tags: [.video, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "mock-video-interstitial-320-480-skip-offset"
                interstitialController.adFormat = .video
                
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial 320x480 .mp4 (In-App)",
                     tags: [.video, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "mock-video-interstitial-mp4"
                interstitialController.adFormat = .video
                
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial 320x480 .m4v (In-App)",
                     tags: [.video, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "mock-video-interstitial-m4v"
                interstitialController.adFormat = .video
                
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial 320x480 .mov (In-App)",
                     tags: [.video, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "mock-video-interstitial-mov"
                interstitialController.adFormat = .video
                
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial 320x480 with MRAID End Card (In-App)",
                     tags: [.video, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "mock-video-interstitial-mraid-end-card"
                interstitialController.adFormat = .video
                
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),

            TestCase(title: "Video Interstitial 320x480 (In-App) [SKAdN]",
                     tags: [.video, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "mock-video-interstitial-320-480-skadn"
                interstitialController.adFormat = .video
                
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            // MARK: ---- Video Interstitial (GAM) ----
            
            TestCase(title: "Video Interstitial 320x480 (GAM) [OK, AppEvent]",
                     tags: [.video, .gam, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamInterstitialController = PrebidGAMInterstitialController(rootController: adapterVC)
                if AppConfiguration.shared.useMockServer {
                    gamInterstitialController.prebidConfigId = "mock-video-interstitial-320-480-with-end-card"
                } else {
                    gamInterstitialController.prebidConfigId = "12f58bc2-b664-4672-8d19-638bcc96fd5c"
                }
                gamInterstitialController.adFormat = .video
                gamInterstitialController.gamAdUnitId = "/21808260008/prebid_oxb_interstitial_video"
                adapterVC.setup(adapter: gamInterstitialController)
                        
                setupCustomParams(for: gamInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial 320x480 (GAM) [OK, Random]",
                     tags: [.video, .gam, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamInterstitialController = PrebidGAMInterstitialController(rootController: adapterVC)
                gamInterstitialController.prebidConfigId = "mock-video-interstitial-320-480"
                gamInterstitialController.adFormat = .video
                gamInterstitialController.gamAdUnitId = "/21808260008/prebid_oxb_320x480_interstitial_video_random"
                adapterVC.setup(adapter: gamInterstitialController)
                        
                setupCustomParams(for: gamInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial 320x480 (GAM) [noBids, GAM Ad]",
                     tags: [.video, .gam, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamInterstitialController = PrebidGAMInterstitialController(rootController: adapterVC)
                if AppConfiguration.shared.useMockServer {
                    gamInterstitialController.prebidConfigId = "mock-no-bids"
                } else {
                    PrebidRenderingConfig.shared.accountID = "1768035c-74d3-4786-b056-13bd41f34bde"
                    gamInterstitialController.prebidConfigId = "28259226-68de-49f8-88d6-f0f2fab846e3"
                }
                gamInterstitialController.adFormat = .video
                gamInterstitialController.gamAdUnitId = "/21808260008/prebid_oxb_320x480_interstitial_video_static"
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
                gamInterstitialController.prebidConfigId = "12f58bc2-b664-4672-8d19-638bcc96fd5c"
                gamInterstitialController.adFormat = .video
               
                gamInterstitialController.gamAdUnitId = "/21808260008/prebid_interstitial_video"
                adapterVC.setup(adapter: gamInterstitialController)
                        
                setupCustomParams(for: gamInterstitialController.prebidConfigId)
            }),
            
            // MARK: ---- Video Interstitial (MoPub) ----
            
            TestCase(title: "Video Interstitial 320x480 (MoPub) [OK, OXB Adapter]",
                     tags: [.video, .mopub, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let mopubInterstitialController = PrebidMoPubInterstitialController(rootController: adapterVC)
                if AppConfiguration.shared.useMockServer {
                    mopubInterstitialController.prebidConfigId = "mock-video-interstitial-320-480-with-end-card"
                } else {
                    mopubInterstitialController.prebidConfigId = "12f58bc2-b664-4672-8d19-638bcc96fd5c"
                }
                mopubInterstitialController.adFormat = .video
                mopubInterstitialController.moPubAdUnitId = "7e3146fc0c744afebc8547a4567da895"
                adapterVC.setup(adapter: mopubInterstitialController)
                        
                setupCustomParams(for: mopubInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial 320x480 (MoPub) [OK, Random]",
                     tags: [.video, .mopub, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let mopubInterstitialController = PrebidMoPubInterstitialController(rootController: adapterVC)
                mopubInterstitialController.prebidConfigId = "mock-video-interstitial-320-480"
                mopubInterstitialController.adFormat = .video
                mopubInterstitialController.moPubAdUnitId = "106bea23b1f744e794646b4b577028a0"
                adapterVC.setup(adapter: mopubInterstitialController)
                        
                setupCustomParams(for: mopubInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial 320x480 (MoPub) [noBids, MoPub Ad]",
                     tags: [.video, .mopub, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let mopubInterstitialController = PrebidMoPubInterstitialController(rootController: adapterVC)
                if AppConfiguration.shared.useMockServer {
                    mopubInterstitialController.prebidConfigId = "mock-no-bids"
                } else {
                    PrebidRenderingConfig.shared.accountID = "1768035c-74d3-4786-b056-13bd41f34bde"
                    mopubInterstitialController.prebidConfigId = "28259226-68de-49f8-88d6-f0f2fab846e3"
                }
                mopubInterstitialController.adFormat = .video
                mopubInterstitialController.moPubAdUnitId = "d9757eb3f9364aafa1eb8d7d702be36b"
                adapterVC.setup(adapter: mopubInterstitialController)
                        
                setupCustomParams(for: mopubInterstitialController.prebidConfigId)
            }),
            
            TestCase(title: "Video Interstitial 320x480 (MoPub) [Vanilla Prebid Order]",
                     tags: [.video, .mopub, .server],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let mopubInterstitialController = PrebidMoPubInterstitialController(rootController: adapterVC)
                mopubInterstitialController.prebidConfigId = "12f58bc2-b664-4672-8d19-638bcc96fd5c"
                mopubInterstitialController.adFormat = .video
                
                mopubInterstitialController.moPubAdUnitId = "7c97bc24de78482e9f53d8d073b3a2e4"
                adapterVC.setup(adapter: mopubInterstitialController)
                        
                setupCustomParams(for: mopubInterstitialController.prebidConfigId)
            }),
            
            // MARK: ---- Video (In-App) ----
            
            TestCase(title: "Video Outstream (In-App)",
                     tags: [.video, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "mock-video-outstream"
                bannerController.adSizes = [CGSize(width: 300, height: 250)]
                bannerController.adFormat = .video
                        
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Video Outstream (In-App) [noBids]",
                     tags: [.video, .inapp, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let bannerController = PrebidBannerController(rootController: adapterVC)
                if AppConfiguration.shared.useMockServer {
                    bannerController.prebidConfigId = "mock-no-bids"
                } else {
                    PrebidRenderingConfig.shared.accountID = "1768035c-74d3-4786-b056-13bd41f34bde"
                    bannerController.prebidConfigId = "28259226-68de-49f8-88d6-f0f2fab846e3"
                }
                bannerController.adSizes = [CGSize(width: 300, height: 250)]
                bannerController.adFormat = .video
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Video Outstream with End Card (In-App)",
                     tags: [.video, .inapp, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let bannerController = PrebidBannerController(rootController: adapterVC)
                
                bannerController.adSizes = [CGSize(width: 300, height: 250)]
                bannerController.adFormat = .video
                        
                if AppConfiguration.shared.useMockServer {
                    bannerController.prebidConfigId = "mock-video-outstream-with-end-card"
                } else {
                    bannerController.prebidConfigId = "9007b76d-c73c-49c6-b0a8-1c7890a84b33"
                }
                 
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "Video Outstream Feed (In-App)",
                     tags: [.video, .inapp, .mock],
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
                        
                        var prebidConfigId = "mock-video-outstream"
                        let adSize = CGSize(width: 300, height: 250)
                        let adBannerView = BannerView(frame: CGRect(origin: .zero, size: adSize),
                                                      configID: prebidConfigId,
                                                      adSize: adSize)
                        adBannerView.adFormat = .video
                        adBannerView.videoPlacementType = .inFeed
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
            
            TestCase(title: "Video Outstream (In-App) [SKAdN]",
                     tags: [.video, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "mock-video-outstream-skadn"
                bannerController.adSizes = [CGSize(width: 300, height: 250)]
                bannerController.adFormat = .video
                
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            // MARK: ---- Video (GAM) ----
            
            TestCase(title: "Video Outstream (GAM) [OK, AppEvent]",
                     tags: [.video, .gam, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
                gamBannerController.gamAdUnitId = "/21808260008/prebid_oxb_300x250_banner"
                gamBannerController.validAdSizes = [kGADAdSizeMediumRectangle]
                gamBannerController.adFormat = .video
                gamBannerController.prebidConfigId = "mock-video-outstream"
                 
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
                gamBannerController.validAdSizes = [kGADAdSizeMediumRectangle]
                gamBannerController.adFormat = .video
                gamBannerController.prebidConfigId = "9007b76d-c73c-49c6-b0a8-1c7890a84b33"
                 
                adapterVC.setup(adapter: gamBannerController)
                        
                setupCustomParams(for: gamBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Video Outstream (GAM) [OK, Random]",
                     tags: [.video, .gam, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
                gamBannerController.prebidConfigId = "mock-video-outstream"
                gamBannerController.gamAdUnitId = "/21808260008/prebid_oxb_outstream_video_reandom"
                gamBannerController.validAdSizes = [kGADAdSizeMediumRectangle]
                gamBannerController.adFormat = .video
                adapterVC.setup(adapter: gamBannerController)
                        
                setupCustomParams(for: gamBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Video Outstream (GAM) [noBids, GAM Ad]",
                     tags: [.video, .gam, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
                if AppConfiguration.shared.useMockServer {
                    gamBannerController.prebidConfigId = "mock-no-bids"
                } else {
                    PrebidRenderingConfig.shared.accountID = "1768035c-74d3-4786-b056-13bd41f34bde"
                    gamBannerController.prebidConfigId = "28259226-68de-49f8-88d6-f0f2fab846e3"
                }
                gamBannerController.gamAdUnitId = "/21808260008/prebid_oxb_outsream_video"
                gamBannerController.validAdSizes = [kGADAdSizeMediumRectangle]
                gamBannerController.adFormat = .video
                
                adapterVC.setup(adapter: gamBannerController)
                        
                setupCustomParams(for: gamBannerController.prebidConfigId)
            }),
            
            TestCase(title: "Video Outstream Feed (GAM)",
                     tags: [.video, .gam, .mock],
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
                        
                        var prebidConfigId = "mock-video-outstream"
                        let gamAdUnitId = "/21808260008/prebid_oxb_outstream_video_reandom"
                        let validAdSize = kGADAdSizeMediumRectangle
                        let adSize = validAdSize.size
                        let adEventHandler = GAMBannerEventHandler(adUnitID: gamAdUnitId, validGADAdSizes: [NSValueFromGADAdSize(validAdSize)])
                        let adBannerView = BannerView(configID: prebidConfigId,
                                                      eventHandler: adEventHandler)
                        adBannerView.adFormat = .video
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
            
            // MARK: ---- Video Rewarded (In-App) ----
            
            TestCase(title: "Video Rewarded 320x480 (In-App)",
                     tags: [.video, .inapp, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let rewardedAdController = PrebidRewardedController(rootController: adapterVC)
                
                if AppConfiguration.shared.useMockServer {
                    rewardedAdController.prebidConfigId = "mock-video-rewarded-320-480"
                } else {
                    rewardedAdController.prebidConfigId = "12f58bc2-b664-4672-8d19-638bcc96fd5c"
                }
                 
                adapterVC.setup(adapter: rewardedAdController)
                        
                setupCustomParams(for: rewardedAdController.prebidConfigId)
            }),

            TestCase(title: "Video Rewarded 320x480 (In-App) [noBids]",
                     tags: [.video, .inapp, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController", configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let rewardedAdController = PrebidRewardedController(rootController: adapterVC)
                if AppConfiguration.shared.useMockServer {
                    rewardedAdController.prebidConfigId = "mock-no-bids"
                } else {
                    PrebidRenderingConfig.shared.accountID = "1768035c-74d3-4786-b056-13bd41f34bde"
                    rewardedAdController.prebidConfigId = "28259226-68de-49f8-88d6-f0f2fab846e3"
                }
                adapterVC.setup(adapter: rewardedAdController)
                        
                setupCustomParams(for: rewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "Video Rewarded 320x480 without End Card (In-App)",
                     tags: [.video, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let rewardedAdController = PrebidRewardedController(rootController: adapterVC)
                rewardedAdController.prebidConfigId = "mock-video-rewarded-320-480-without-end-card"
                adapterVC.setup(adapter: rewardedAdController)
                        
                setupCustomParams(for: rewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "Video Rewarded 480x320 (In-App)",
                     tags: [.video, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let rewardedAdController = PrebidRewardedController(rootController: adapterVC)
                rewardedAdController.prebidConfigId = "mock-video-rewarded-320-480"
                adapterVC.setup(adapter: rewardedAdController)
                        
                setupCustomParams(for: rewardedAdController.prebidConfigId)
            }),
            
            // MARK: ---- Video Rewarded (GAM) ----
            
            TestCase(title: "Video Rewarded 320x480 (GAM) [OK, Metadata]",
                     tags: [.video, .gam, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamRewardedAdController = PrebidGAMRewardedController(rootController: adapterVC)
                gamRewardedAdController.gamAdUnitId = "/21808260008/prebid_oxb_rewarded_video_test"
                        
                if AppConfiguration.shared.useMockServer {
                    gamRewardedAdController.prebidConfigId = "mock-video-rewarded-320-480"
                } else {
                    gamRewardedAdController.prebidConfigId = "12f58bc2-b664-4672-8d19-638bcc96fd5c"
                }
                 
                adapterVC.setup(adapter: gamRewardedAdController)
                        
                setupCustomParams(for: gamRewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "Video Rewarded 320x480 (GAM) [OK, Random]",
                     tags: [.video, .gam, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamRewardedAdController = PrebidGAMRewardedController(rootController: adapterVC)
                gamRewardedAdController.prebidConfigId = "mock-video-rewarded-320-480"
                gamRewardedAdController.gamAdUnitId = "/21808260008/prebid_oxb_rewarded_video_random"
                adapterVC.setup(adapter: gamRewardedAdController)
                        
                setupCustomParams(for: gamRewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "Video Rewarded 320x480 (GAM) [noBids, GAM Ad]",
                     tags: [.video, .gam, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamRewardedAdController = PrebidGAMRewardedController(rootController: adapterVC)
                if AppConfiguration.shared.useMockServer {
                    gamRewardedAdController.prebidConfigId = "mock-no-bids"
                } else {
                    PrebidRenderingConfig.shared.accountID = "1768035c-74d3-4786-b056-13bd41f34bde"
                    gamRewardedAdController.prebidConfigId = "28259226-68de-49f8-88d6-f0f2fab846e3"
                }
                gamRewardedAdController.gamAdUnitId = "/21808260008/prebid_oxb_rewarded_video_static"
                adapterVC.setup(adapter: gamRewardedAdController)
                        
                setupCustomParams(for: gamRewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "Video Rewarded 320x480 without End Card (GAM) [OK, Metadata]",
                     tags: [.video, .gam, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamRewardedAdController = PrebidGAMRewardedController(rootController: adapterVC)
                gamRewardedAdController.prebidConfigId = "mock-video-rewarded-320-480-without-end-card"
                gamRewardedAdController.gamAdUnitId = "/21808260008/prebid_oxb_rewarded_video_test"
                adapterVC.setup(adapter: gamRewardedAdController)
                        
                setupCustomParams(for: gamRewardedAdController.prebidConfigId)
            }),
            
            // MARK: ---- Video Rewarded (MoPub) ----
            
            TestCase(title: "Video Rewarded 320x480 (MoPub) [OK, OXB Adapter]",
                     tags: [.video, .mopub, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let mopubRewardedAdController = PrebidMoPubRewardedAdController(rootController: adapterVC)
                mopubRewardedAdController.moPubAdUnitId = "7538cc74d2984c348bc14caafa3e3395"
                        
                if AppConfiguration.shared.useMockServer {
                    mopubRewardedAdController.prebidConfigId = "mock-video-rewarded-320-480"
                } else {
                    mopubRewardedAdController.prebidConfigId = "12f58bc2-b664-4672-8d19-638bcc96fd5c"
                }
                 
                adapterVC.setup(adapter: mopubRewardedAdController)
                        
                setupCustomParams(for: mopubRewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "Video Rewarded 320x480 (MoPub) [OK, Random]",
                     tags: [.video, .mopub, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let mopubRewardedAdController = PrebidMoPubRewardedAdController(rootController: adapterVC)
                mopubRewardedAdController.prebidConfigId = "mock-video-rewarded-320-480"
                mopubRewardedAdController.moPubAdUnitId = "39ed12ae7c8f4cceafb55b698401a15d"
                adapterVC.setup(adapter: mopubRewardedAdController)
                        
                setupCustomParams(for: mopubRewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "Video Rewarded 320x480 (MoPub) [noBids, MoPub Ad]",
                     tags: [.video, .mopub, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let mopubRewardedAdController = PrebidMoPubRewardedAdController(rootController: adapterVC)
                if AppConfiguration.shared.useMockServer {
                    mopubRewardedAdController.prebidConfigId = "mock-no-bids"
                } else {
                    PrebidRenderingConfig.shared.accountID = "1768035c-74d3-4786-b056-13bd41f34bde"
                    mopubRewardedAdController.prebidConfigId = "28259226-68de-49f8-88d6-f0f2fab846e3"
                }
                mopubRewardedAdController.moPubAdUnitId = "cf3f015774b148ea9979d27da8c4f8ed"
                adapterVC.setup(adapter: mopubRewardedAdController)
                        
                setupCustomParams(for: mopubRewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "Video Rewarded 320x480 without End Card (MoPub) [OK, OXB Adapter]",
                     tags: [.video, .mopub, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let mopubRewardedAdController = PrebidMoPubRewardedAdController(rootController: adapterVC)
                mopubRewardedAdController.prebidConfigId = "mock-video-rewarded-320-480-without-end-card"
                mopubRewardedAdController.moPubAdUnitId = "7538cc74d2984c348bc14caafa3e3395"
                adapterVC.setup(adapter: mopubRewardedAdController)
                        
                setupCustomParams(for: mopubRewardedAdController.prebidConfigId)
            }),
            
            // MARK: ---- Video Rewarded (MoPub) [Deprecated API]----
            
            TestCase(title: "[Deprecated API] Video Rewarded 320x480 (MoPub) [OK, OXB Adapter]",
                     tags: [.video, .mopub, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let mopubRewardedAdController = PrebidMoPubRewardedVideoController(rootController: adapterVC)
                mopubRewardedAdController.moPubAdUnitId = "7538cc74d2984c348bc14caafa3e3395"
                        
                if AppConfiguration.shared.useMockServer {
                    mopubRewardedAdController.prebidConfigId = "mock-video-rewarded-320-480"
                } else {
                    mopubRewardedAdController.prebidConfigId = "12f58bc2-b664-4672-8d19-638bcc96fd5c"
                }
                 
                adapterVC.setup(adapter: mopubRewardedAdController)
                        
                setupCustomParams(for: mopubRewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "[Deprecated API] Video Rewarded 320x480 (MoPub) [OK, Random]",
                     tags: [.video, .mopub, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let mopubRewardedAdController = PrebidMoPubRewardedVideoController(rootController: adapterVC)
                mopubRewardedAdController.prebidConfigId = "mock-video-rewarded-320-480"
                mopubRewardedAdController.moPubAdUnitId = "39ed12ae7c8f4cceafb55b698401a15d"
                adapterVC.setup(adapter: mopubRewardedAdController)
                        
                setupCustomParams(for: mopubRewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "[Deprecated API] Video Rewarded 320x480 (MoPub) [noBids, MoPub Ad]",
                     tags: [.video, .mopub, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let mopubRewardedAdController = PrebidMoPubRewardedVideoController(rootController: adapterVC)
                if AppConfiguration.shared.useMockServer {
                    mopubRewardedAdController.prebidConfigId = "mock-no-bids"
                } else {
                    PrebidRenderingConfig.shared.accountID = "1768035c-74d3-4786-b056-13bd41f34bde"
                    mopubRewardedAdController.prebidConfigId = "28259226-68de-49f8-88d6-f0f2fab846e3"
                }
                mopubRewardedAdController.moPubAdUnitId = "cf3f015774b148ea9979d27da8c4f8ed"
                adapterVC.setup(adapter: mopubRewardedAdController)
                        
                setupCustomParams(for: mopubRewardedAdController.prebidConfigId)
            }),
            
            TestCase(title: "[Deprecated API] Video Rewarded 320x480 without End Card (MoPub) [OK, OXB Adapter]",
                     tags: [.video, .mopub, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let mopubRewardedAdController = PrebidMoPubRewardedVideoController(rootController: adapterVC)
                mopubRewardedAdController.prebidConfigId = "mock-video-rewarded-320-480-without-end-card"
                mopubRewardedAdController.moPubAdUnitId = "7538cc74d2984c348bc14caafa3e3395"
                adapterVC.setup(adapter: mopubRewardedAdController)
                        
                setupCustomParams(for: mopubRewardedAdController.prebidConfigId)
            }),
            
            // MARK: ---- MRAID (In-App) ----
            
            TestCase(title: "MRAID 2.0: Expand - 1 Part (In-App)",
                     tags: [.mraid, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "mock-mraid-expand-1-part"
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "MRAID 2.0: Expand - 2 Part (In-App)",
                     tags: [.mraid, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "mock-mraid-expand-2-part"
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                 
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "MRAID 2.0: Resize (In-App)",
                     tags: [.mraid, .inapp, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let bannerController = PrebidBannerController(rootController: adapterVC)
                
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                        
                if AppConfiguration.shared.useMockServer {
                    bannerController.prebidConfigId = "mock-mraid-resize"
                } else {
                    bannerController.prebidConfigId = "758bef6c-a811-497e-8234-9a583daf92e0"
                }
                 
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "MRAID 2.0: Resize with Errors (In-App)",
                     tags: [.mraid, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "mock-mraid-resize-with-errors"
                bannerController.adSizes = [CGSize(width: 300, height: 250)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "MRAID 2.0: Fullscreen (In-App)",
                     tags: [.mraid, .inapp, .mock],
                     exampleVCStoryboardID: "ScrollableAdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "mock-mraid-fullscreen"
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),

            TestCase(title: "MRAID 2.0: Video Interstitial (In-App)",
                     tags: [.mraid, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let interstitialController = PrebidInterstitialController(rootController: adapterVC)
                interstitialController.prebidConfigId = "mock-mraid-video-interstitial"
                adapterVC.setup(adapter: interstitialController)
                        
                setupCustomParams(for: interstitialController.prebidConfigId)
            }),
            
            TestCase(title: "MRAID 3.0: Viewability Compliance (In-App)",
                     tags: [.mraid, .inapp, .mock],
                     exampleVCStoryboardID: "ScrollableAdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "mock-mraid-viewability-compliance"
                bannerController.adSizes = [CGSize(width: 300, height: 250)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "MRAID 3.0: Resize Negative Test (In-App)",
                     tags: [.mraid, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                        
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "mock-mraid-resize-negative-test"
                bannerController.adSizes = [CGSize(width: 300, height: 250)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "MRAID 3.0: Load And Events (In-App)",
                     tags: [.mraid, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "mock-mraid-load-and-events"
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "MRAID OX: Test Properties 3.0 (In-App)",
                     tags: [.mraid, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "mock-mraid-test-properties-3"
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "MRAID OX: Test Methods 3.0 (In-App)",
                     tags: [.mraid, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "mock-mraid-test-methods-3"
                bannerController.adSizes = [CGSize(width: 320, height: 50)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "MRAID OX: Resize (Expandable) (In-App)",
                     tags: [.mraid, .inapp, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                        
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "mock-mraid-resize-expandable"
                bannerController.adSizes = [CGSize(width: 300, height: 50)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            TestCase(title: "MRAID OX: Resize (With Scroll) (In-App)",
                     tags: [.mraid, .inapp, .mock],
                     exampleVCStoryboardID: "ScrollableAdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                        
                let bannerController = PrebidBannerController(rootController: adapterVC)
                bannerController.prebidConfigId = "mock-mraid-resize"
                bannerController.adSizes = [CGSize(width: 300, height: 50)]
                adapterVC.setup(adapter: bannerController)
                        
                setupCustomParams(for: bannerController.prebidConfigId)
            }),
            
            // MARK: ---- MRAID (GAM) ----
            
            TestCase(title: "MRAID 2.0: Expand - 1 Part (GAM)",
                     tags: [.mraid, .gam, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
                gamBannerController.prebidConfigId = "mock-mraid-expand-1-part"
                gamBannerController.gamAdUnitId = "/21808260008/prebid_oxb_320x50_banner"
                gamBannerController.validAdSizes = [kGADAdSizeBanner]
                adapterVC.setup(adapter: gamBannerController)
                        
                setupCustomParams(for: gamBannerController.prebidConfigId)
            }),
            
            
            TestCase(title: "MRAID 2.0: Resize (GAM)",
                     tags: [.mraid, .gam, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
                if AppConfiguration.shared.useMockServer {
                    gamBannerController.prebidConfigId = "mock-mraid-resize"
                } else {
                    gamBannerController.prebidConfigId = "758bef6c-a811-497e-8234-9a583daf92e0"
                }
                gamBannerController.gamAdUnitId = "/21808260008/prebid_oxb_320x50_banner"
                gamBannerController.validAdSizes = [kGADAdSizeBanner]
                adapterVC.setup(adapter: gamBannerController)
                        
                setupCustomParams(for: gamBannerController.prebidConfigId)
            }),
            
            TestCase(title: "MRAID 2.0: Video Interstitial (GAM)",
                     tags: [.mraid, .gam, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let gamInterstitialController = PrebidGAMInterstitialController(rootController: adapterVC)
                gamInterstitialController.prebidConfigId = "mock-mraid-video-interstitial"
                gamInterstitialController.gamAdUnitId = "/21808260008/prebid_oxb_html_interstitial"
                adapterVC.setup(adapter: gamInterstitialController)
                        
                setupCustomParams(for: gamInterstitialController.prebidConfigId)
            }),
            
            // MARK: ---- MRAID (MoPub) ----
            
            TestCase(title: "MRAID 2.0: Expand - 1 Part (MoPub)",
                     tags: [.mraid, .mopub, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let mopubBannerController = PrebidMoPubBannerController(rootController: adapterVC)
                mopubBannerController.prebidConfigId = "mock-mraid-expand-1-part"
                mopubBannerController.moPubAdUnitId = "0df35635801e4110b65e762a62437698"
                mopubBannerController.adUnitSize = CGSize(width: 320, height: 50);
                adapterVC.setup(adapter: mopubBannerController)
                        
                setupCustomParams(for: mopubBannerController.prebidConfigId)
            }),
            
            TestCase(title: "MRAID 2.0: Resize (MoPub)",
                     tags: [.mraid, .mopub, .server, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let mopubBannerController = PrebidMoPubBannerController(rootController: adapterVC)
                if AppConfiguration.shared.useMockServer {
                    mopubBannerController.prebidConfigId = "mock-mraid-resize"
                } else {
                    mopubBannerController.prebidConfigId = "758bef6c-a811-497e-8234-9a583daf92e0"
                }
                mopubBannerController.moPubAdUnitId = "0df35635801e4110b65e762a62437698"
                mopubBannerController.adUnitSize = CGSize(width: 320, height: 50);
                adapterVC.setup(adapter: mopubBannerController)
                        
                setupCustomParams(for: mopubBannerController.prebidConfigId)
            }),
            
            TestCase(title: "MRAID 2.0: Video Interstitial (MoPub)",
                     tags: [.mraid, .mopub, .mock],
                     exampleVCStoryboardID: "AdapterViewController",
                     configurationClosure: { vc in
                guard let adapterVC = vc as? AdapterViewController else {
                    return
                }
                let mopubInterstitialController = PrebidMoPubInterstitialController(rootController: adapterVC)
                mopubInterstitialController.prebidConfigId = "mock-mraid-video-interstitial"
                mopubInterstitialController.moPubAdUnitId = "e979c52714434796909993e21c8fc8da" // TODO: Create for iOS
                adapterVC.setup(adapter: mopubInterstitialController)
                        
                setupCustomParams(for: mopubInterstitialController.prebidConfigId)
            }),
            
            // MARK: ---- Native Styles (In-App) ----
            
//            TestCase(title: "Banner Native Styles (In-App) [MAP]",
//                     tags: [.native, .inapp, .server, .mock],
//                     exampleVCStoryboardID: "AdapterViewController",
//                     configurationClosure: { vc in
//                guard let adapterVC = vc as? AdapterViewController else {
//                    return
//                }
//                let bannerController = PrebidBannerController(rootController: adapterVC)
//                bannerController.adSizes = [CGSize(width: 320, height: 240)]
//
//                if AppConfiguration.shared.useMockServer {
//                    bannerController.prebidConfigId = "mock-banner-native-styles"
//                } else {
//                    bannerController.prebidConfigId = "621da6c1-6ab6-464d-a955-b4e447eaedcb"
//                }
//
//                let nativeAdConfig = NativeAdConfiguration(testConfigWithAssets: .defaultNativeRequestAssets)
//                nativeAdConfig.nativeStylesCreative = nativeStylesCreative
//                bannerController.nativeAdConfig = nativeAdConfig
//
//                adapterVC.setup(adapter: bannerController)
//
//                setupCustomParams(for: bannerController.prebidConfigId)
//            }),
//
//            TestCase(title: "Banner Native Styles (In-App) [KEYS]",
//                     tags: [.native, .inapp, .mock],
//                     exampleVCStoryboardID: "AdapterViewController",
//                     configurationClosure: { vc in
//                guard let adapterVC = vc as? AdapterViewController else {
//                    return
//                }
//                let bannerController = PrebidBannerController(rootController: adapterVC)
//
//                bannerController.prebidConfigId = "mock-banner-native-styles"
//                bannerController.adSizes = [CGSize(width: 320, height: 240)]
//
//                let nativeAdConfig = NativeAdConfiguration(testConfigWithAssets: .defaultNativeRequestAssets)
//                nativeAdConfig.nativeStylesCreative = nativeStylesCreativeKeys
//                bannerController.nativeAdConfig = nativeAdConfig
//
//                adapterVC.setup(adapter: bannerController)
//
//                setupCustomParams(for: bannerController.prebidConfigId)
//            }),
//
//            TestCase(title: "Banner Native Styles No Assets (In-App)",
//                     tags: [.native, .inapp, .mock],
//                     exampleVCStoryboardID: "AdapterViewController",
//                     configurationClosure: { vc in
//                guard let adapterVC = vc as? AdapterViewController else {
//                    return
//                }
//                let bannerController = PrebidBannerController(rootController: adapterVC)
//
//                bannerController.prebidConfigId = "mock-banner-native-styles"
//                bannerController.adSizes = [CGSize(width: 320, height: 240)]
//
//                let nativeAdConfig = NativeAdConfiguration(assets: [])
//                nativeAdConfig.nativeStylesCreative = nativeStylesCreativeKeys
//                bannerController.nativeAdConfig = nativeAdConfig
//
//                adapterVC.setup(adapter: bannerController)
//
//                setupCustomParams(for: bannerController.prebidConfigId)
//            }),
//
//            TestCase(title: "Banner Native Styles No Creative (In-App)",
//                     tags: [.native, .inapp, .mock],
//                     exampleVCStoryboardID: "AdapterViewController",
//                     configurationClosure: { vc in
//                guard let adapterVC = vc as? AdapterViewController else {
//                    return
//                }
//                let bannerController = PrebidBannerController(rootController: adapterVC)
//                bannerController.prebidConfigId = "mock-banner-native-styles"
//                bannerController.adSizes = [CGSize(width: 320, height: 240)]
//
//                let nativeAdConfig = NativeAdConfiguration(testConfigWithAssets: .defaultNativeRequestAssets)
//                //NOTE: there is no `nativeStylesCreative` in the nativeConfig
//                bannerController.nativeAdConfig = nativeAdConfig
//
//                adapterVC.setup(adapter: bannerController)
//
//                setupCustomParams(for: bannerController.prebidConfigId)
//            }),
            
            // MARK: ---- Native Styles (GAM) ----
            
//            TestCase(title: "Banner Native Styles (GAM) [MRect]",
//                     tags: [.native, .gam, .server, .mock],
//                     exampleVCStoryboardID: "AdapterViewController",
//                     configurationClosure: { vc in
//                guard let adapterVC = vc as? AdapterViewController else {
//                    return
//                }
//                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
//
//                if AppConfiguration.shared.useMockServer {
//                    gamBannerController.prebidConfigId = "mock-banner-native-styles"
//                } else {
//                    gamBannerController.prebidConfigId = "621da6c1-6ab6-464d-a955-b4e447eaedcb"
//                }
//
//                gamBannerController.gamAdUnitId = "/21808260008/prebid_native_fixed"
//                gamBannerController.validAdSizes = [kGADAdSizeMediumRectangle]
//                gamBannerController.nativeAdConfig = NativeAdConfiguration(testConfigWithAssets: .defaultNativeRequestAssets)
//
//                adapterVC.setup(adapter: gamBannerController)
//
//                setupCustomParams(for: gamBannerController.prebidConfigId)
//            }),
//
//            TestCase(title: "Banner Native Styles No Assets (GAM) [MRect]",
//                     tags: [.native, .gam, .mock],
//                     exampleVCStoryboardID: "AdapterViewController",
//                     configurationClosure: { vc in
//                guard let adapterVC = vc as? AdapterViewController else {
//                    return
//                }
//                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
//
//                gamBannerController.prebidConfigId = "mock-banner-native-styles"
//                gamBannerController.gamAdUnitId = "/21808260008/prebid_native_fixed"
//                gamBannerController.validAdSizes = [kGADAdSizeMediumRectangle]
//                gamBannerController.nativeAdConfig = NativeAdConfiguration(assets: [])
//
//                adapterVC.setup(adapter: gamBannerController)
//
//                setupCustomParams(for: gamBannerController.prebidConfigId)
//            }),
//
//            TestCase(title: "Banner Native Styles (GAM) [Fluid]",
//                     tags: [.native, .gam, .mock],
//                     exampleVCStoryboardID: "AdapterViewController",
//                     configurationClosure: { vc in
//                guard let adapterVC = vc as? AdapterViewController else {
//                    return
//                }
//                let gamBannerController = PrebidGAMBannerController(rootController: adapterVC)
//
//                gamBannerController.prebidConfigId = "mock-banner-native-styles"
//                gamBannerController.gamAdUnitId = "/21808260008/prebid_native"
//                gamBannerController.validAdSizes = [kGADAdSizeFluid]
//                gamBannerController.nativeAdConfig = NativeAdConfiguration(testConfigWithAssets: .defaultNativeRequestAssets)
//
//                adapterVC.setup(adapter: gamBannerController)
//
//                setupCustomParams(for: gamBannerController.prebidConfigId)
//            }),
//
//            // MARK: ---- Native Styles (MoPub) ----
//
//            TestCase(title: "Banner Native Styles (MoPub)",
//                     tags: [.native, .mopub, .server, .mock],
//                     exampleVCStoryboardID: "AdapterViewController",
//                     configurationClosure: { vc in
//                guard let adapterVC = vc as? AdapterViewController else {
//                    return
//                }
//                let mopubBannerController = PrebidMoPubBannerController(rootController: adapterVC)
//
//                if AppConfiguration.shared.useMockServer {
//                    mopubBannerController.prebidConfigId = "mock-banner-native-styles"
//                } else {
//                    mopubBannerController.prebidConfigId = "621da6c1-6ab6-464d-a955-b4e447eaedcb"
//                }
//
//
//                mopubBannerController.moPubAdUnitId = "76936a9fe0cb4801b193e4f263511ca4"
//                mopubBannerController.adUnitSize = CGSize(width: 300, height: 250);
//                mopubBannerController.nativeAdConfig = NativeAdConfiguration(testConfigWithAssets: .defaultNativeRequestAssets)
//
//                adapterVC.setup(adapter: mopubBannerController)
//
//                setupCustomParams(for: mopubBannerController.prebidConfigId)
//            }),
//
//            TestCase(title: "Banner Native Styles No Assets (MoPub)",
//                     tags: [.native, .mopub, .mock],
//                     exampleVCStoryboardID: "AdapterViewController",
//                     configurationClosure: { vc in
//                guard let adapterVC = vc as? AdapterViewController else {
//                    return
//                }
//                let mopubBannerController = PrebidMoPubBannerController(rootController: adapterVC)
//
//                mopubBannerController.prebidConfigId = "mock-banner-native-styles"
//                mopubBannerController.moPubAdUnitId = "76936a9fe0cb4801b193e4f263511ca4"
//                mopubBannerController.adUnitSize = CGSize(width: 300, height: 250);
//                mopubBannerController.nativeAdConfig = NativeAdConfiguration(assets: [])
//
//                adapterVC.setup(adapter: mopubBannerController)
//
//                setupCustomParams(for: mopubBannerController.prebidConfigId)
//            }),
            
            // MARK: ---- Native (In-App) ----
            
//            TestCase(title: "Native Ad (In-App)",
//                     tags: [.native, .inapp, .server, .mock],
//                     exampleVCStoryboardID: "AdapterViewController",
//                     configurationClosure: { vc in
//                guard let adapterVC = vc as? AdapterViewController else {
//                    return
//                }
//                let nativeAdController = PrebidNativeAdController(rootController: adapterVC)
//                nativeAdController.setupNativeAdView(NativeAdViewBox())
//
//                if AppConfiguration.shared.useMockServer {
//                    nativeAdController.prebidConfigId = "mock-banner-native-styles"
//                } else {
//                    // FIXME: Switch the example from QA to the Prod server
//                    try! PrebidRenderingConfig.shared.setCustomPrebidServer(url: "https://prebid.qa.openx.net/openrtb2/auction")
//                    PrebidRenderingConfig.shared.accountID = "08efa38c-b6b4-48c4-adc0-bcb791caa791"
//                    nativeAdController.prebidConfigId = "51fe68ba-aff2-401e-9e15-f3ed89d5c036"
//                }
//
//                let nativeAdConfig = NativeAdConfiguration(testConfigWithAssets: .defaultNativeRequestAssets)
//                nativeAdConfig.nativeStylesCreative = nativeStylesCreative
//                nativeAdController.nativeAdConfig = nativeAdConfig
//
//                adapterVC.setup(adapter: nativeAdController)
//
//                setupCustomParams(for: nativeAdController.prebidConfigId)
//            }),
//
//            TestCase(title: "Native Ad Links (In-App)",
//                     tags: [.native, .inapp, .mock],
//                     exampleVCStoryboardID: "AdapterViewController",
//                     configurationClosure: { vc in
//                guard let adapterVC = vc as? AdapterViewController else {
//                    return
//                }
//                let nativeAdController = PrebidNativeAdController(rootController: adapterVC)
//                nativeAdController.setupNativeAdView(NativeAdViewBoxLinks())
//
//                nativeAdController.prebidConfigId = "mock-native-links"
//
//                let nativeAdConfig = NativeAdConfiguration(testConfigWithAssets: .defaultNativeRequestAssets)
//                nativeAdConfig.nativeStylesCreative = nativeStylesCreative
//                nativeAdController.nativeAdConfig = nativeAdConfig
//
//                adapterVC.setup(adapter: nativeAdController)
//
//                setupCustomParams(for: nativeAdController.prebidConfigId)
//            }),
//
//            TestCase(title: "Native Ad Feed (In-App)",
//                     tags: [.native, .inapp, .mock],
//                     exampleVCStoryboardID: "PrebidFeedTableViewController",
//                     configurationClosure: { vc in
//
//                guard let feedVC = vc as? PrebidFeedTableViewController else {
//                    return
//                }
//
//                let nativeAdFeedController = PrebidNativeAdFeedController(rootTableViewController: feedVC)
//
//                nativeAdFeedController.prebidConfigId = "mock-banner-native-styles"
//
//                let nativeAdConfig = NativeAdConfiguration(testConfigWithAssets: .defaultNativeRequestAssets)
//                nativeAdConfig.nativeStylesCreative = nativeStylesCreative
//                nativeAdFeedController.nativeAdConfig = nativeAdConfig
//
//                feedVC.adapter = nativeAdFeedController
//                feedVC.loadAdClosure = nativeAdFeedController.allowLoadingAd
//
//                nativeAdFeedController.createCells()
//
//                setupCustomParams(for: nativeAdFeedController.prebidConfigId)
//            }),
//
//            TestCase(title: "Native Ad - Video with End Card (In-App)",
//                     tags: [.native, .inapp, .mock],
//                     exampleVCStoryboardID: "AdapterViewController",
//                     configurationClosure: { vc in
//                guard let adapterVC = vc as? AdapterViewController else {
//                    return
//                }
//                let nativeAdController = PrebidNativeAdController(rootController: adapterVC)
//                nativeAdController.setupNativeAdView(NativeAdViewBox())
//                nativeAdController.showOnlyMediaView = true
//
//                nativeAdController.prebidConfigId = "mock-native-video-with-end-card"
//
//                let nativeAdConfig = NativeAdConfiguration(testConfigWithAssets: .defaultNativeRequestAssets)
//                nativeAdConfig.nativeStylesCreative = nativeStylesCreative
//                nativeAdController.nativeAdConfig = nativeAdConfig
//
//                adapterVC.setup(adapter: nativeAdController)
//
//                setupCustomParams(for: nativeAdController.prebidConfigId)
//            }),
//
//            TestCase(title: "Native Ad Feed - Video with End Card (In-App)",
//                     tags: [.native, .inapp, .mock],
//                     exampleVCStoryboardID: "PrebidFeedTableViewController",
//                     configurationClosure: { vc in
//
//                guard let feedVC = vc as? PrebidFeedTableViewController else {
//                    return
//                }
//
//                let nativeAdFeedController = PrebidNativeAdFeedController(rootTableViewController: feedVC)
//                nativeAdFeedController.showOnlyMediaView = true
//
//                nativeAdFeedController.prebidConfigId = "mock-native-video-with-end-card"
//
//                let nativeAdConfig = NativeAdConfiguration(testConfigWithAssets: .defaultNativeRequestAssets)
//                nativeAdConfig.nativeStylesCreative = nativeStylesCreative
//                nativeAdFeedController.nativeAdConfig = nativeAdConfig
//
//                feedVC.adapter = nativeAdFeedController
//                feedVC.loadAdClosure = nativeAdFeedController.allowLoadingAd
//
//                nativeAdFeedController.createCells()
//
//                setupCustomParams(for: nativeAdFeedController.prebidConfigId)
//            }),
//
//            TestCase(title: "Native Ad - All Assets with End Card (In-App)",
//                     tags: [.native, .inapp, .mock],
//                     exampleVCStoryboardID: "AdapterViewController",
//                     configurationClosure: { vc in
//                guard let adapterVC = vc as? AdapterViewController else {
//                    return
//                }
//                let nativeAdController = PrebidNativeAdController(rootController: adapterVC)
//                nativeAdController.setupNativeAdView(NativeAdViewBox())
//
//                nativeAdController.prebidConfigId = "mock-native-video-with-end-card"
//
//                let nativeAdConfig = NativeAdConfiguration(testConfigWithAssets: .defaultNativeRequestAssets)
//                nativeAdConfig.nativeStylesCreative = nativeStylesCreative
//                nativeAdController.nativeAdConfig = nativeAdConfig
//
//                adapterVC.setup(adapter: nativeAdController)
//
//                setupCustomParams(for: nativeAdController.prebidConfigId)
//            }),

            // MARK: ---- Native (MoPub) ----
            
//            TestCase(title: "Native Ad (MoPub) [OK, PBM Native AdAdapter]",
//                     tags: [.native, .mopub, .server, .mock],
//                     exampleVCStoryboardID: "AdapterViewController",
//                     configurationClosure: { vc in
//                guard let adapterVC = vc as? AdapterViewController else {
//                    return
//                }
//                let mopubNativeAdController = PrebidMoPubNativeAdController(rootController: adapterVC)
//
//                if AppConfiguration.shared.useMockServer {
//                    mopubNativeAdController.prebidConfigId = "mock-banner-native-styles"
//                } else {
//                    // FIXME: Switch the example from QA to the Prod server
//                    try! PrebidRenderingConfig.shared.setCustomPrebidServer(url: "https://prebid.qa.openx.net/openrtb2/auction")
//                    PrebidRenderingConfig.shared.accountID = "08efa38c-b6b4-48c4-adc0-bcb791caa791"
//                    mopubNativeAdController.prebidConfigId = "51fe68ba-aff2-401e-9e15-f3ed89d5c036"
//                }
//                mopubNativeAdController.moPubAdUnitId = "dc125bad5c124b0b896ef1407b9dfd86"
//                mopubNativeAdController.adRenderingViewClass = MoPubNativeAdView.self
//
//                let nativeAdConfig = NativeAdConfiguration(testConfigWithAssets: .defaultNativeRequestAssets)
//                mopubNativeAdController.nativeAdConfig = nativeAdConfig
//
//                adapterVC.setup(adapter: mopubNativeAdController)
//
//                setupCustomParams(for: mopubNativeAdController.prebidConfigId)
//            }),
//
//            TestCase(title: "Native Ad (MoPub) [OK, PBM Native AdAdapter, Nib]",
//                     tags: [.native, .mopub, .mock],
//                     exampleVCStoryboardID: "AdapterViewController",
//                     configurationClosure: { vc in
//                guard let adapterVC = vc as? AdapterViewController else {
//                    return
//                }
//
//                let mopubNativeAdController = PrebidMoPubNativeAdController(rootController: adapterVC)
//                mopubNativeAdController.prebidConfigId = "mock-banner-native-styles"
//                mopubNativeAdController.moPubAdUnitId = "dc125bad5c124b0b896ef1407b9dfd86"
//                mopubNativeAdController.adRenderingViewClass = MoPubNativeAdViewWithNib.self
//
//                let nativeAdConfig = NativeAdConfiguration(testConfigWithAssets: .defaultNativeRequestAssets)
//                mopubNativeAdController.nativeAdConfig = nativeAdConfig
//
//                adapterVC.setup(adapter: mopubNativeAdController)
//
//                setupCustomParams(for: mopubNativeAdController.prebidConfigId)
//            }),
//
//            TestCase(title: "Native Ad Feed (MoPub) [OK, PBM Native AdAdapter]",
//                     tags: [.native, .mopub, .mock],
//                     exampleVCStoryboardID: "PrebidFeedTableViewController",
//                     configurationClosure: { vc in
//
//                guard let feedVC = vc as? PrebidFeedTableViewController else {
//                    return
//                }
//                let mopubNativeAdFeedController = PrebidMoPubNativeAdFeedController(rootTableViewController: feedVC)
//                mopubNativeAdFeedController.prebidConfigId = "mock-banner-native-styles"
//                mopubNativeAdFeedController.moPubAdUnitId = "dc125bad5c124b0b896ef1407b9dfd86"
//                mopubNativeAdFeedController.adRenderingViewClass = MoPubNativeAdView.self
//
//                let nativeAdConfig = NativeAdConfiguration(testConfigWithAssets: .defaultNativeRequestAssets)
//                mopubNativeAdFeedController.nativeAdConfig = nativeAdConfig
//
//                feedVC.adapter = mopubNativeAdFeedController
//                feedVC.loadAdClosure = mopubNativeAdFeedController.allowLoadingAd
//
//                mopubNativeAdFeedController.createCells()
//
//                setupCustomParams(for: mopubNativeAdFeedController.prebidConfigId)
//            }),
//
//            TestCase(title: "Native Ad (MoPub) [OK, MPNativeAd]",
//                     tags: [.native, .mopub, .mock],
//                     exampleVCStoryboardID: "AdapterViewController",
//                     configurationClosure: { vc in
//                guard let adapterVC = vc as? AdapterViewController else {
//                    return
//                }
//                let mopubNativeAdController = PrebidMoPubNativeAdController(rootController: adapterVC)
//                mopubNativeAdController.prebidConfigId = "mock-banner-native-styles"
//                mopubNativeAdController.moPubAdUnitId = "fcd2188bcce74b63859b663ed1334763"
//                mopubNativeAdController.adRenderingViewClass = MoPubNativeAdView.self
//
//                let nativeAdConfig = NativeAdConfiguration(testConfigWithAssets: .defaultNativeRequestAssets)
//                mopubNativeAdController.nativeAdConfig = nativeAdConfig
//
//                adapterVC.setup(adapter: mopubNativeAdController)
//
//                setupCustomParams(for: mopubNativeAdController.prebidConfigId)
//            }),
//
//            TestCase(title: "Native Ad (MoPub) [noBids, MPNativeAd]",
//                     tags: [.native, .mopub, .server, .mock],
//                     exampleVCStoryboardID: "AdapterViewController",
//                     configurationClosure: { vc in
//                guard let adapterVC = vc as? AdapterViewController else {
//                    return
//                }
//                let mopubNativeAdController = PrebidMoPubNativeAdController(rootController: adapterVC)
//
//                if AppConfiguration.shared.useMockServer {
//                    mopubNativeAdController.prebidConfigId = "mock-no-bids"
//                } else {
//                    PrebidRenderingConfig.shared.accountID = "1768035c-74d3-4786-b056-13bd41f34bde"
//                    mopubNativeAdController.prebidConfigId = "28259226-68de-49f8-88d6-f0f2fab846e3"
//                }
//
//                mopubNativeAdController.moPubAdUnitId = "3c7add479268476394a1aeae88ee426f"
//                mopubNativeAdController.adRenderingViewClass = MoPubNativeAdView.self
//
//                let nativeAdConfig = NativeAdConfiguration(testConfigWithAssets: .defaultNativeRequestAssets)
//                mopubNativeAdController.nativeAdConfig = nativeAdConfig
//
//                adapterVC.setup(adapter: mopubNativeAdController)
//
//                setupCustomParams(for: mopubNativeAdController.prebidConfigId)
//            }),
//
//            TestCase(title: "Native Ad Feed (MoPub) [noBids, MPNativeAd]",
//                     tags: [.native, .mopub, .mock],
//                     exampleVCStoryboardID: "PrebidFeedTableViewController",
//                     configurationClosure: { vc in
//
//                guard let feedVC = vc as? PrebidFeedTableViewController else {
//                    return
//                }
//                let mopubNativeAdFeedController = PrebidMoPubNativeAdFeedController(rootTableViewController: feedVC)
//                mopubNativeAdFeedController.prebidConfigId = "mock-no-bids"
//                mopubNativeAdFeedController.moPubAdUnitId = "3c7add479268476394a1aeae88ee426f"
//                mopubNativeAdFeedController.adRenderingViewClass = MoPubNativeAdView.self
//
//                let nativeAdConfig = NativeAdConfiguration(testConfigWithAssets: .defaultNativeRequestAssets)
//                mopubNativeAdFeedController.nativeAdConfig = nativeAdConfig
//
//                feedVC.adapter = mopubNativeAdFeedController
//                feedVC.loadAdClosure = mopubNativeAdFeedController.allowLoadingAd
//
//                mopubNativeAdFeedController.createCells()
//
//                setupCustomParams(for: mopubNativeAdFeedController.prebidConfigId)
//            }),
//
//            TestCase(title: "Native Ad Video (MoPub) [OK, PBM Native AdAdapter]",
//                     tags: [.native, .mopub, .mock],
//                     exampleVCStoryboardID: "AdapterViewController",
//                     configurationClosure: { vc in
//                guard let adapterVC = vc as? AdapterViewController else {
//                    return
//                }
//                let mopubNativeAdController = PrebidMoPubNativeAdController(rootController: adapterVC)
//                mopubNativeAdController.prebidConfigId = "mock-native-video-with-end-card"
//                mopubNativeAdController.moPubAdUnitId = "dc125bad5c124b0b896ef1407b9dfd86"
//                mopubNativeAdController.adRenderingViewClass = MoPubNativeVideoAdView.self
//
//                let nativeAdConfig = NativeAdConfiguration(testConfigWithAssets: .defaultNativeRequestAssets)
//                mopubNativeAdController.nativeAdConfig = nativeAdConfig
//
//                adapterVC.setup(adapter: mopubNativeAdController)
//
//                setupCustomParams(for: mopubNativeAdController.prebidConfigId)
//            }),
            
            // MARK: ---- Native (GAM, CustomTemplate) ----

//            TestCase(title: "Native Ad (GAM) [OK, PBMNativeAd]",
//                     tags: [.native, .gam, .mock, .server],
//                     exampleVCStoryboardID: "AdapterViewController",
//                     configurationClosure: { vc in
//                guard let adapterVC = vc as? AdapterViewController else {
//                    return
//                }
//                let gamNativeAdController = PrebidGAMNativeAdController(rootController: adapterVC)
//
//                if AppConfiguration.shared.useMockServer {
//                    gamNativeAdController.prebidConfigId = "mock-banner-native-styles"
//                } else {
//                    // FIXME: Switch the example from QA to the Prod server
//                    try! PrebidRenderingConfig.shared.setCustomPrebidServer(url: "https://prebid.qa.openx.net/openrtb2/auction")
//                    PrebidRenderingConfig.shared.accountID = "08efa38c-b6b4-48c4-adc0-bcb791caa791"
//                    gamNativeAdController.prebidConfigId = "51fe68ba-aff2-401e-9e15-f3ed89d5c036"
//                }
//                gamNativeAdController.gamAdUnitId = "/21808260008/apollo_custom_template_native_ad_unit"
//                gamNativeAdController.adTypes = [.customNative]
//                gamNativeAdController.gamCustomTemplateIDs = ["11934135"]
//
//                let nativeAdConfig = NativeAdConfiguration(testConfigWithAssets: .defaultNativeRequestAssets)
//                nativeAdConfig.nativeStylesCreative = nativeStylesCreative
//                gamNativeAdController.nativeAdConfig = nativeAdConfig
//
//                adapterVC.setup(adapter: gamNativeAdController)
//
//                setupCustomParams(for: gamNativeAdController.prebidConfigId)
//            }),
//
//            TestCase(title: "Native Ad (GAM) [OK, GADNativeCustomTemplateAd]",
//                     tags: [.native, .gam, .mock],
//                     exampleVCStoryboardID: "AdapterViewController",
//                     configurationClosure: { vc in
//                guard let adapterVC = vc as? AdapterViewController else {
//                    return
//                }
//                let gamNativeAdController = PrebidGAMNativeAdController(rootController: adapterVC)
//
//                gamNativeAdController.prebidConfigId = "mock-banner-native-styles"
//                gamNativeAdController.gamAdUnitId = "/21808260008/apollo_custom_template_native_ad_unit"
//                gamNativeAdController.adTypes = [.customNative]
//                gamNativeAdController.gamCustomTemplateIDs = ["11982639"]
//
//                let nativeAdConfig = NativeAdConfiguration(testConfigWithAssets: .defaultNativeRequestAssets)
//                nativeAdConfig.nativeStylesCreative = nativeStylesCreative
//                gamNativeAdController.nativeAdConfig = nativeAdConfig
//
//                adapterVC.setup(adapter: gamNativeAdController)
//
//                setupCustomParams(for: gamNativeAdController.prebidConfigId)
//            }),
//
//            TestCase(title: "Native Ad (GAM) [noBids, GADNativeCustomTemplateAd]",
//                     tags: [.native, .gam, .mock],
//                     exampleVCStoryboardID: "AdapterViewController",
//                     configurationClosure: { vc in
//                guard let adapterVC = vc as? AdapterViewController else {
//                    return
//                }
//                let gamNativeAdController = PrebidGAMNativeAdController(rootController: adapterVC)
//
//                gamNativeAdController.prebidConfigId = "mock-native-video-with-end-card--dummy"
//                gamNativeAdController.gamAdUnitId = "/21808260008/apollo_custom_template_native_ad_unit"
//                gamNativeAdController.adTypes = [.customNative]
//                gamNativeAdController.gamCustomTemplateIDs = ["11982639"]
//
//                let nativeAdConfig = NativeAdConfiguration(testConfigWithAssets: .defaultNativeRequestAssets)
//                nativeAdConfig.nativeStylesCreative = nativeStylesCreative
//                gamNativeAdController.nativeAdConfig = nativeAdConfig
//
//                adapterVC.setup(adapter: gamNativeAdController)
//
//                setupCustomParams(for: gamNativeAdController.prebidConfigId)
//            }),
//
//            TestCase(title: "Native Ad Feed (GAM) [OK, PBMNativeAd]",
//                     tags: [.native, .gam, .mock],
//                     exampleVCStoryboardID: "PrebidFeedTableViewController",
//                     configurationClosure: { vc in
//
//                guard let feedVC = vc as? PrebidFeedTableViewController else {
//                    return
//                }
//                let gamNativeAdController = PrebidGAMNativeAdFeedController(rootTableViewController: feedVC)
//
//                gamNativeAdController.prebidConfigId = "mock-banner-native-styles"
//                gamNativeAdController.gamAdUnitId = "/21808260008/apollo_custom_template_native_ad_unit"
//                gamNativeAdController.adTypes = [.customNative]
//                gamNativeAdController.gamCustomTemplateIDs = ["11934135"]
//
//                let nativeAdConfig = NativeAdConfiguration(testConfigWithAssets: .defaultNativeRequestAssets)
//                nativeAdConfig.nativeStylesCreative = nativeStylesCreative
//                gamNativeAdController.nativeAdConfig = nativeAdConfig
//
//                feedVC.adapter = gamNativeAdController
//                feedVC.loadAdClosure = gamNativeAdController.allowLoadingAd
//
//                gamNativeAdController.createCells()
//
//                setupCustomParams(for: gamNativeAdController.prebidConfigId)
//            }),
            
            // MARK: ---- Native (GAM, Unified) ----

//            TestCase(title: "Native Ad (GAM) [OK, PBMNativeAd]",
//                     tags: [.native, .gam, .mock, .server],
//                     exampleVCStoryboardID: "AdapterViewController",
//                     configurationClosure: { vc in
//                guard let adapterVC = vc as? AdapterViewController else {
//                    return
//                }
//                let gamNativeAdController = PrebidGAMNativeAdController(rootController: adapterVC)
//                           
//                if AppConfiguration.shared.useMockServer {
//                    gamNativeAdController.prebidConfigId = "mock-banner-native-styles"
//                } else {
//                    // FIXME: Switch the example from QA to the Prod server
//                    try! PrebidRenderingConfig.shared.setCustomPrebidServer(url: "https://prebid.qa.openx.net/openrtb2/auction")
//                    PrebidRenderingConfig.shared.accountID = "08efa38c-b6b4-48c4-adc0-bcb791caa791"
//                    gamNativeAdController.prebidConfigId = "51fe68ba-aff2-401e-9e15-f3ed89d5c036"
//                }
//                gamNativeAdController.gamAdUnitId = "/21808260008/unified_native_ad_unit"
//                gamNativeAdController.adTypes = [.native]
//                        
//                let nativeAdConfig = NativeAdConfiguration(testConfigWithAssets: .defaultNativeRequestAssets)
//                nativeAdConfig.nativeStylesCreative = nativeStylesCreative
//                gamNativeAdController.nativeAdConfig = nativeAdConfig
//                        
//                adapterVC.setup(adapter: gamNativeAdController)
//                        
//                setupCustomParams(for: gamNativeAdController.prebidConfigId)
//            }),
//            
//            TestCase(title: "Native Ad (GAM) [OK, GADUnifiedNativeAd]",
//                     tags: [.native, .gam, .mock],
//                     exampleVCStoryboardID: "AdapterViewController",
//                     configurationClosure: { vc in
//                guard let adapterVC = vc as? AdapterViewController else {
//                    return
//                }
//                let gamNativeAdController = PrebidGAMNativeAdController(rootController: adapterVC)
//                        
//                gamNativeAdController.prebidConfigId = "mock-banner-native-styles"
//                gamNativeAdController.gamAdUnitId = "/21808260008/unified_native_ad_unit_static"
//                gamNativeAdController.adTypes = [.native]
//                        
//                let nativeAdConfig = NativeAdConfiguration(testConfigWithAssets: .defaultNativeRequestAssets)
//                nativeAdConfig.nativeStylesCreative = nativeStylesCreative
//                gamNativeAdController.nativeAdConfig = nativeAdConfig
//                        
//                adapterVC.setup(adapter: gamNativeAdController)
//                        
//                setupCustomParams(for: gamNativeAdController.prebidConfigId)
//            }),
//            
//            TestCase(title: "Native Ad (GAM) [noBids, GADUnifiedNativeAd]",
//                     tags: [.native, .gam, .mock],
//                     exampleVCStoryboardID: "AdapterViewController",
//                     configurationClosure: { vc in
//                guard let adapterVC = vc as? AdapterViewController else {
//                    return
//                }
//                let gamNativeAdController = PrebidGAMNativeAdController(rootController: adapterVC)
//                        
//                gamNativeAdController.prebidConfigId = "mock-native-video-with-end-card--dummy"
//                gamNativeAdController.gamAdUnitId = "/21808260008/unified_native_ad_unit_static"
//                gamNativeAdController.adTypes = [.native]
//                        
//                let nativeAdConfig = NativeAdConfiguration(testConfigWithAssets: .defaultNativeRequestAssets)
//                nativeAdConfig.nativeStylesCreative = nativeStylesCreative
//                gamNativeAdController.nativeAdConfig = nativeAdConfig
//                        
//                adapterVC.setup(adapter: gamNativeAdController)
//                        
//                setupCustomParams(for: gamNativeAdController.prebidConfigId)
//            }),
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
    private static func strToGender(_ gender: String) -> PBRGender {
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
