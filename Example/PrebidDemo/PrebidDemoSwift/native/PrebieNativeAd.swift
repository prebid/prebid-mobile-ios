//
//  PrebieNativeAd.swift
//  iOSTestNativeNative
//
//  Created by Wei Zhang on 11/6/19.
//  Copyright © 2019 AppNexus. All rights reserved.
//

import Foundation
import UIKit

class PrebidNativeAd:NSObject {
    public static func  create(cacheId:String)-> PrebidNativeAd? {
        let ad: PrebidNativeAd = PrebidNativeAd()
        ad.title = "Hello World"
        ad.text = "This is a Prebid Native Ad. For more information please check prebid.org."
        ad.callToAction = "Learn More"
        ad.iconUrl = "https://dummyimage.com/40x40/000/fff"
        ad.imageUrl = "https://dummyimage.com/600x400/000/fff"
        ad.clickUrl = "https://prebig.org"
        if ad.isValid() {
            return ad
        } else {
            return nil
        }
    }
    private override init() {
        super.init()
    }
    private func isValid() -> Bool{
        return !(title ?? "").isEmpty
        && !(text ?? "").isEmpty
        && !(callToAction ?? "").isEmpty
        && canOpenString(string: iconUrl!)
        && canOpenString(string: imageUrl!)
        && canOpenString(string: clickUrl!)
    }
    
    private func canOpenString(string:String) -> Bool {
        guard let url = URL(string: string) else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }
    
    var title:String?
    var text:String?
    var iconUrl:String?
    var imageUrl:String?
    var callToAction:String?
    var clickUrl:String?
    
}
