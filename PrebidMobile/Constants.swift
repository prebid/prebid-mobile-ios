/*   Copyright 2018-2019 Prebid.org, Inc.

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

public let PrebidLocalCacheIdKey = "hb_cache_id_local"

extension String {

    static let EMPTY_String = ""

    static let kIFASentinelValue = "00000000-0000-0000-0000-000000000000"

    //TODO: Improvement - use a set
    static let DFP_Object_Name = "DFPRequest"
    
    static let DFP_N_Object_Name = "DFPNRequest"

    static let DFP_O_Object_Name = "DFPORequest"

    static let GAD_Object_Name = "GADRequest"

    static let GAD_N_Object_Name = "GADNRequest"
    
    static let GAM_Object_Name = "GAMRequest"
    
    static let GAD_Object_Custom_Native_Name = "GADCustomNativeAd"

    static let MoPub_Object_Name = "MPAdView"

    static let MoPub_Interstitial_Name = "MPInterstitialAdController"
    
    static let MoPub_Request_Name = "MPNativeAdRequest"
}

extension Int {

    static let PB_Request_Timeout = 2000
}

extension UIDevice {

    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
    var screenSize: CGSize {
        UIScreen.main.bounds.size
    }

}

@objcMembers
public class PrebidConstants: NSObject {
    private override init() { super.init() }
    
    public static var supportedRenderingBannerAPISignals: [Signals.Api] {
        return [.MRAID_1, .MRAID_2, .MRAID_3, .OMID_1]
    }
    
    public static var companionHTMLTemplate: String {
        """
        <html>
            <body>
                <div id="ad" align="center">
                    <a href="%@">
                        <img src="%@" align="center" style="max-width:100%vw; width:auto; max-height:100%vh">
                            </a>
                </div>
            </body>
        </html>
        """
    }
    
    public static let PREBID_VERSION                                                        = "3.0.2"
    public static let SDK_NAME                                                              = "prebid-mobile-sdk"
    
    public static let DOMAIN_KEY                                                            = "domain"
    public static let PBM_TRANSACTION_STATE_KEY                                             = "ts"
    public static let PBM_TRACKING_URL_TEMPLATE                                             = "record_tmpl"
    public static let PBM_ORIGINAL_ADUNIT_KEY                                               = "OriginalAdUnitID"
    public static let PBM_PRECACHE_CONFIGURATION_KEY                                        = "precache_configuration"
    public static let FETCH_DEMAND_RESULT_KEY                                               = "PrebidResultCodeKey"
    
    public static let AD_PREFETCH_TIME: TimeInterval = 3
    
    public static let LOCATION_SOURCE_GPS                                                   = 1
    public static let LOCATION_SOURCE_IPAddress                                             = 2
    public static let LOCATION_SOURCE_USER_REGISTRATION                                     = 3
    
    public static let BUTTON_AREA_DEFAULT: NSNumber                                         = 0.1
    public static let SKIP_DELAY_DEFAULT: NSNumber                                          = 10
    public static let BUTTON_CONSTRAINT: NSNumber                                           = 15

    public static let APP_STORE_URL_SCHEME                                                  = "url"
    public static let OPEN_RTB_SCHEME                                                       = "openrtb"

    public static let AUTO_REFRESH_DELAY_DEFAULT: TimeInterval                              = 60
    public static let AUTO_REFRESH_DELAY_MIN: TimeInterval                                  = 15
    public static let AUTO_REFRESH_DELAY_MAX: TimeInterval                                  = 125

    public static let VAST_LOADER_TIMEOUT: TimeInterval                                     = 3
    public static let AD_CLICKED_ALLOWED_INTERVAL: TimeInterval                             = 5
    public static let CONNECTION_TIMEOUT_DEFAULT: TimeInterval                              = 3
    public static let CLOSE_DELAY_MIN: TimeInterval                                         = 2
    public static let CLOSE_DELAY_MAX: TimeInterval                                         = 30
    public static let FIRE_AND_FORGET_TIMEOUT: TimeInterval                                 = 3

    public static let VIDEO_TIMESCALE: Int                                                  = 1000
    public static let DISTANCE_FILTER: Double                                               = 50.0

    public static let SERVER_ENDPOINTS_STATUS                                               = "/status/"

    public static let ACCESSIBILITY_CLOSE_BUTTON_IDENTIFIER                                 = "PBMCloseButton"
    public static let ACCESSIBILITY_CLOSE_BUTTON_LABEL                                      = "PBMCloseButton"
    public static let ACCESSIBILITY_CLOSE_BUTTON_CLICK_THROUGH_BROWSER_IDENTIFIER           = "PBMCloseButtonClickThroughBrowser"
    public static let ACCESSIBILITY_CLOSE_BUTTON_CLICK_THROUGH_BROWSER_LABEL                = "PBMCloseButtonClickThroughBrowser"
    public static let ACCESSIBILITY_WEB_VIEW_LABEL                                          = "PBMWebView"
    public static let ACCESSIBILITY_VIDEO_AD_VIEW                                           = "PBMVideoAdView"
    public static let ACCESSIBILITY_BANNER_VIEW                                             = "PrebidBannerView"
    
    public static let TRACKING_PATTERN_RI                                                   = "/ma/1.0/ri"
    public static let TRACKING_PATTERN_RC                                                   = "/ma/1.0/rc"
    public static let TRACKING_PATTERN_RDF                                                  = "/ma/1.0/rdf"
    public static let TRACKING_PATTERN_RR                                                   = "/ma/1.0/rr"
    public static let TRACKING_PATTERN_BO                                                   = "/ma/1.0/bo"

    public static let SUPPORTED_VIDEO_MIME_TYPES = [
        "video/mp4", "video/quicktime", "video/x-m4v", "video/3gpp", "video/3gpp2"
    ]

    public static let URL_SCHEMES_FOR_APP_STORE_AND_ITUNES = [
        "itms", "itmss", "itms-apps", "itms-appss"
    ]

    public static let URL_SCHEMES_NOT_SUPPORTED_ON_SIMULATOR = [
        "tel", "itms", "itmss", "itms-apps", "itms-appss"
    ]

    public static let URL_SCHEMES_NOT_SUPPORTED_ON_CLICKTHROUGH_BROWSER = [
        "sms", "tel", "itms", "itmss", "itms-apps", "itms-appss"
    ]
}
