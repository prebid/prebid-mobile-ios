//
//  NativeAdUnit.swift
//  PrebidMobile
//
//  Created by Wei Zhang on 9/20/19.
//  Copyright © 2019 AppNexus. All rights reserved.
//

import Foundation

@objcMembers public class NativeAdUnit: AdUnit {
    public init(configId: String) {
        super.init(configId: configId, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    }
    
    enum NATIVE_REQUEST_ASSET {
        case TITLE
        case IMAGE
        case DATA
    }
    let VERSION = "ver";
    let SUPPORTED_VERSION = "1.2";
    let CONTEXT = "context";
    let CONTEXT_SUB_TYPE = "contextsubtype";
    let PLACEMENT_TYPE = "plcmttype";
    let PLACEMENT_COUNT = "plcmtcnt";
    let SEQ = "seq";
    let ASSETS = "assets";
    let A_URL_SUPPORT = "aurlsupport";
    let D_URL_SUPPORT = "durlsupport";
    let EVENT_TRACKERS = "eventtrackers";
    let PRIVACY = "privacy";
    let EXT = "ext";
    let EVENT = "event";
    let METHODS = "methods";
    let LENGTH = "len";
    let REQUIRED = "required";
    let ASSETS_EXT = "assetExt";
    let WIDTH_MIN = "wmin";
    let HEIGHT_MIN = "hmin";
    let WIDTH = "W";
    let HEIGHT = "h";
    let TYPE = "type";
    let MIMES = "mimes";
    let TITLE = "title";
    let IMAGE = "img";
    let DATA = "data";
    let NATIVE = "native";
    let REQUEST = "request";
    
    var reguestConfig: [String: Any] = [:]
    
    enum CONTEXT_TYPE: Int {
        case CONTENT_CENTRIC = 1
        case SOCIAL_CENTRIC = 2
        case PRODUCT = 3
        case CUSTOM = 500
    }
    
    
}
