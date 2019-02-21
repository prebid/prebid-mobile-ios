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
import GoogleMobileAds
import MoPub

class PBViewTool: NSObject {

    class func checkMPAdViewContainsPBMAd(_ view: MPAdView?, withCompletionHandler completionHandler: @escaping (_ result: Bool) -> Void) {
        var checked = false
        for view in view!.subviews {
            if (view is MPClosableView) {
                if(view.isKind(of: MPClosableView.self)){
                    let wv = view as! MPClosableView
                    
                    for innerView in (wv.subviews) {
                        if (innerView != nil) {
                            if(innerView.isKind(of: MPWebView.self)){
                                let wv = innerView as! MPWebView
                                
                                wv.evaluateJavaScript("document.body.innerHTML", completionHandler: { result, error in
                                    let content = result as? String
                                    if content?.contains("prebid/pbm.js") ?? false || content?.contains("creative.js") ?? false {
                                        completionHandler(true)
                                    } else {
                                        completionHandler(false)
                                    }
                                })
                                checked = true
                                break
                            }
                            
                        }
                    }
                }
                
            }
        }
        if !checked {
            completionHandler(false)
        }
    }
    
    class func checkMPInterstitialContainsPBMAd(_ viewController: UIViewController, withCompletionHandler completionHandler: @escaping (_ result: Bool) -> Void) {
        var checked = false
        let mainView = viewController.view
        for view in mainView!.subviews {
            if (view is MPClosableView) {
                if(view.isKind(of: MPClosableView.self)){
                    let wv = view as! MPClosableView
                    
                    for innerView in (wv.subviews) {
                        if (innerView != nil) {
                            if(innerView.isKind(of: MPWebView.self)){
                                let wv = innerView as! MPWebView
                                
                                wv.evaluateJavaScript("document.body.innerHTML", completionHandler: { result, error in
                                    let content = result as? String
                                    if content?.contains("prebid/pbm.js") ?? false || content?.contains("creative.js") ?? false {
                                        completionHandler(true)
                                    } else {
                                        completionHandler(false)
                                    }
                                })
                                checked = true
                                break
                            }
                            
                        }
                    }
                }
                
            }
        }
        if !checked {
            completionHandler(false)
        }
    }
    
    class func checkDFPInterstitialAdViewContainsPBMAd(_ viewController: UIViewController) -> Bool {
        let view:UIView = viewController.view
        let subviews = view.subviews
        
        for view in subviews {
            let name:String = String(describing: type(of: view))
            if(name == "GADNWebAdView" || name == "GADOAdView"){
                let views  = view.subviews
                for innerView in views{
                    let nameInner:String = String(describing: type(of: innerView))
                    if(innerView.isKind(of: UIWebView.self)){
                      return PBViewTool.checkJSExistInWebView(webView: innerView as! UIWebView)
                    }
                    else if(nameInner == "GADOUIKitWebView"){
                        let deepInnerView  = innerView.subviews
                        for innerView2 in deepInnerView{
                            if(innerView2.isKind(of: UIWebView.self)){
                                return PBViewTool.checkJSExistInWebView(webView: innerView2 as! UIWebView)
                            }
                        }
                    }
                }
            }
        }
        return false
    }
    
    class func checkDFPAdViewContainsPBMAd(_ view: GADBannerView?) -> Bool {
        for level1: UIView? in (view?.subviews)! {
            let level2s = level1?.subviews
            for level2: UIView? in level2s ?? [] {
                for level3: UIView? in level2?.subviews ?? [] {
                    for level4: UIView? in level3?.subviews ?? [] {
                        for level5: UIView? in level4?.subviews ?? [] {
                            for level6: UIView? in level5?.subviews ?? [] {
                                if (level6 is UIWebView) {
                                    return PBViewTool.checkJSExistInWebView(webView: level6 as! UIWebView)
                                }
                                else if level5 == nil
                                {
                                    return false
                                }
                            }
                        }
                    }
                }
            }
        }
        return false
    }
    
    class func checkJSExistInWebView(webView:UIWebView)->Bool
    {
        let content:String = webView.stringByEvaluatingJavaScript(from: "document.body.innerHTML")!
        if content.contains("prebid/pbm.js") || content.contains("creative.js") {
            return true
        } else {
            return false
        }
    }
}
