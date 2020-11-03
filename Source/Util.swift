//
//  Util.swift
//  iOSTestNativeNative
//
//  Created by Wei Zhang on 11/6/19.
//  Copyright © 2019 AppNexus. All rights reserved.
//

import Foundation
import WebKit

public  class Util :NSObject{
    public static let shared = Util()
    
    private override init(){
        super.init()
    }
    
    private let DFP_BANNER_VIEW_CLASSNAME = "DFPBannerView"
    private let DFP_WEBADVIEW_CLASSNAME = "GADWebAdView"
    private let MOPUB_NATIVE_AD_CLASSNAME = "MPNativeAd"
    private let DFP_CUSTOM_TEMPLATE_AD_CLASSNAME = "GADNativeCustomTemplateAd"
    private let INNNER_HTML_SCRIPT = "document.body.innerHTML"
    
    public func findNative(adObject: AnyObject, listener: PrebidNativeAdListener){
        if (self.isObjectFromClass(adObject, DFP_BANNER_VIEW_CLASSNAME)) {
            let dfpBannerView = adObject as! UIView
            findNativeForDFPBannerAdView(dfpBannerView, listener)
        } else if(self.isObjectFromClass(adObject, MOPUB_NATIVE_AD_CLASSNAME)){
            findNativeForMoPubNativeAd(adObject, listener)
        }else if(self.isObjectFromClass(adObject, DFP_CUSTOM_TEMPLATE_AD_CLASSNAME)){

            findNativeForDFPCustomTemplateAd(adObject, listener )
        } else {
            listener.onPrebidNativeNotFound()
        }
    }
    
    private func findNativeForDFPCustomTemplateAd(_ dfpCustomAd: AnyObject, _ listener: PrebidNativeAdListener){
            let isPrebid = dfpCustomAd.string?(forKey: "isPrebid")
            if("1" == isPrebid) {
                let hb_cache_id = dfpCustomAd.string?(forKey: "hb_cache_id") as! String
                let ad = PrebidNativeAd.create(cacheId: hb_cache_id)
                if (ad != nil) {
                    listener.onPrebidNativeLoaded(ad: ad!)
                    return
                } else {
                    listener.onPrebidNativeNotValid()
                    return
                }
            }
        
        listener.onPrebidNativeNotFound()
    }
    private func findNativeForMoPubNativeAd(_ mopub: AnyObject, _ listener: PrebidNativeAdListener){
        let mopubObject:AnyObject = mopub as! NSObject
        let properties = mopubObject.value(forKey: "properties") as! Dictionary<String, AnyObject>
        let isPrebid = properties["isPrebid"] as? Bool
        if (isPrebid != nil && isPrebid!) {
            let hb_cache_id = properties["hb_cache_id"] as! String
            let ad = PrebidNativeAd.create(cacheId: hb_cache_id)
            if (ad != nil){
                listener.onPrebidNativeLoaded(ad: ad!)
            } else {
                listener.onPrebidNativeNotValid()
            }
        } else {
            listener.onPrebidNativeNotFound()
        }
    }
    private func isObjectFromClass(_ object: AnyObject, _ className: String) -> Bool{
        let objectClassName:String = String(describing: type(of: object))
        if objectClassName == className {
            return true
        }
        return false
    }
    private func findNativeForDFPBannerAdView(_ view:UIView, _ listener: PrebidNativeAdListener){
        var array = [UIView]()
        recursivelyFindWebViewList(view, &array)
        if array.count == 0 {
            listener.onPrebidNativeNotFound()
        } else {
            self.iterateWebViewListAsync(array, array.count - 1, listener)
        }
        
    }
    
    private func iterateWebViewListAsync(_ array: [UIView], _ index: Int, _ listener: PrebidNativeAdListener){
        let processNextWebView:(Int)->Void = {(i) in
            if i > 0 {
                self.iterateWebViewListAsync(array, i - 1, listener)
            } else {
                listener.onPrebidNativeNotFound()
            }
        }
        let processHTMLContent:(String)->Void = {(html) in
            let cacheId = self.getCacheIdFromBody(html)
            if cacheId != nil {
                let ad = PrebidNativeAd.create(cacheId: cacheId!)
                if ad != nil {
                    listener.onPrebidNativeLoaded(ad: ad!)
                } else {
                    listener.onPrebidNativeNotValid()
                }
            } else {
                processNextWebView(index)
            }
        }
        let gadWebAdView = array[index]
        let controller = gadWebAdView.value(forKey: "webViewController")
        let someController = controller as! NSObject
        let webView = someController.value(forKey: "webView") as! UIView
        if webView is WKWebView {
            let wk = webView as! WKWebView
            wk.evaluateJavaScript(self.INNNER_HTML_SCRIPT, completionHandler: { (value: Any!, error: Error!) -> Void in

                if error != nil {
                    return
                }

                let html = value as! String
                processHTMLContent(html)
            })
        } else if webView is UIWebView {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1){
                let ui = webView as! UIWebView
                let html = ui.stringByEvaluatingJavaScript(from: self.INNNER_HTML_SCRIPT)
                processHTMLContent(html!)
            }
        } else {
            processNextWebView(index)
        }
    }
    
    private func getCacheIdFromBody(_ body: String) -> String? {
        let regex = "\\%\\%Prebid\\%\\%.*\\%\\%Prebid\\%\\%"
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: body, range: NSRange(body.startIndex..., in: body))
            let matched = results.map {
                String(body[Range($0.range, in: body)!])
            }
            if matched.isEmpty {
                return nil
            }
            let firstResult = matched[0]
            
            return firstResult
        } catch {
            return nil
        }
    }
    
    private func recursivelyFindWebViewList(_ view:UIView, _ webViewArray:inout [UIView]){
        if(self.isObjectFromClass(view, self.DFP_WEBADVIEW_CLASSNAME)){
                webViewArray.append(view)
            } else {
                for subview in view.subviews {
                    recursivelyFindWebViewList(subview, &webViewArray)
            }
        }
    }
}
