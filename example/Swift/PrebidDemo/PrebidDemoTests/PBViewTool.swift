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
import WebKit
import GoogleMobileAds
import MoPub

class PBViewTool: NSObject {

    class func checkMPAdViewContainsPBMAd(_ view: MPAdView?, withCompletionHandler completionHandler: @escaping (_ result: Bool) -> Void) {
        var checked = false
        for view in view!.subviews where (view is MPClosableView) {
            if (view.isKind(of: MPClosableView.self)) {
                let wv = view as! MPClosableView

                for innerView in (wv.subviews) where (innerView != nil) {
                    if (innerView.isKind(of: MPWebView.self)) {
                        let wv = innerView as! MPWebView

                        wv.evaluateJavaScript("document.body.innerHTML", completionHandler: { result, _ in
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

        if !checked {
            completionHandler(false)
        }
    }

    class func checkMPInterstitialContainsPBMAd(_ viewController: UIViewController, withCompletionHandler completionHandler: @escaping (_ result: Bool) -> Void) {
        var checked = false
        let mainView = viewController.view
        for view in mainView!.subviews where (view is MPClosableView) {
            if (view.isKind(of: MPClosableView.self)) {
                let wv = view as! MPClosableView

                for innerView in (wv.subviews) where (innerView != nil) {
                    if (innerView.isKind(of: MPWebView.self)) {
                        let wv = innerView as! MPWebView

                        wv.evaluateJavaScript("document.body.innerHTML", completionHandler: { result, _ in
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

        if !checked {
            completionHandler(false)
        }
    }

    class func checkDFPInterstitialAdViewContainsPBMAd(_ viewController: UIViewController) -> Bool {
        let view: UIView = viewController.view
        let subviews = view.subviews

        for view in subviews {
            let name: String = String(describing: type(of: view))
            if (name == "GADNWebAdView" || name == "GADOAdView" || name == "GADWebAdView") {
                let views  = view.subviews
                for innerView in views {
                    let nameInner: String = String(describing: type(of: innerView))
                    if (innerView.isKind(of: WKWebView.self)) {
                      return PBViewTool.checkJSExistInWebView(wkWebView: innerView as! WKWebView)
                    } else if (innerView.isKind(of: UIWebView.self)) {
                        return PBViewTool.checkJSExistInWebView(uiWebView: innerView as! UIWebView)
                    } else if (nameInner == "GADOUIKitWebView") {
                        let deepInnerView  = innerView.subviews
                        for innerView2 in deepInnerView {
                            if (innerView2.isKind(of: WKWebView.self)) {
                                return PBViewTool.checkJSExistInWebView(wkWebView: innerView2 as! WKWebView)
                            } else if (innerView.isKind(of: UIWebView.self)) {
                                return PBViewTool.checkJSExistInWebView(uiWebView: innerView2 as! UIWebView)
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
                                    let uiWebView = level6 as! UIWebView;
                                    return PBViewTool.checkJSExistInWebView(uiWebView: uiWebView) && checkWebViewSize(adManagerBanner: view!, webView: uiWebView)
                                } else if (level6 is WKWebView) {
                                    let wkWebView = level6 as! WKWebView;
                                    return PBViewTool.checkJSExistInWebView(wkWebView: wkWebView) && checkWebViewSize(adManagerBanner: view!, webView: wkWebView)
                                } else if level5 == nil {
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

    class func checkJSExistInWebView(wkWebView: WKWebView) -> Bool {
        let sema = DispatchSemaphore(value: 0)
        var content: String?
        DispatchQueue.global().async {
            // Background thread
            wkWebView.evaluateJavaScript("document.body.innerHTML", completionHandler: { (value: Any!, _: Error!) -> Void in
                if let contentHtml = value as? String {
                    content = contentHtml
                } else {
                }
                sema.signal()
            })
        }
        sema.wait()

        if ((content?.contains("prebid/pbm.js"))!) || (content?.contains("creative.js"))! {
            return true
        } else {
            return false

        }
    }
    
    // MARK: - UIWebView deprecated
    //At least AdManager v7.42.2 uses UIWebView
    class func checkJSExistInWebView(uiWebView: UIWebView) -> Bool {
        let content = uiWebView.stringByEvaluatingJavaScript(from: "document.body.innerHTML")

        if ((content?.contains("prebid/pbm.js"))!) || (content?.contains("creative.js"))! {
            return true
        } else {
            return false
        }
    }
    
    /// It is possible that AdManager response for Banner contains all necessary data but an ad is not being rendered.
    /// Check if the ad is not 1x1
    class func checkWebViewSize(adManagerBanner: GADBannerView, webView: UIView) -> Bool {
        
        let webviewWidth = webView.frame.size.width
        let webviewHeight = webView.frame.size.height

        return webviewWidth > 1 && webviewHeight >= 1
    }
}
