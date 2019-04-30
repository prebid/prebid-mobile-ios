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

    class func checkMPAdViewContainsPBMAd(_ adView: MPAdView, withCompletionHandler completionHandler: @escaping (_ result: Bool) -> Void) {
        
        let view = findInView(adView) { (subView) -> Bool in
            return subView is MPWebView
        }
        guard let mpWebView = view as? MPWebView else {
            completionHandler(false)
            return;
        }

        mpWebView.evaluateJavaScript("document.body.innerHTML", completionHandler: { (result, error) in
            
            if error == nil, let content = result as? String, content.contains("prebid/pbm.js") || content.contains("creative.js") {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
            
        })
    }

    class func checkMPInterstitialContainsPBMAd(_ adView: UIView, withCompletionHandler completionHandler: @escaping (_ result: Bool) -> Void) {
        
        let view = findInView(adView) { (subView) -> Bool in
            return subView is MPWebView
        }
        guard let mpWebView = view as? MPWebView else {
            completionHandler(false)
            return;
        }
        
        mpWebView.evaluateJavaScript("document.body.innerHTML", completionHandler: { (result, error) in
            
            if error == nil, let content = result as? String, content.contains("prebid/pbm.js") || content.contains("creative.js") {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
            
        })
    }

    class func checkDFPInterstitialAdViewContainsPBMAd(_ viewController: UIViewController) -> Bool {
        let adView: UIView = viewController.view
        
        let view = findInView(adView) { (subView) -> Bool in
            return subView is WKWebView || subView is UIWebView
        }
        
        if let wkWebView = view as? WKWebView  {
            let wkResult = PBViewTool.checkJSExistInWebView(wkWebView: wkWebView)
            return wkResult
        } else if let uiWebView = view as? UIWebView {
            let uiResult = PBViewTool.checkJSExistInWebView(uiWebView: uiWebView)
            return uiResult
        }
        
        return false;
        
        
    }

    class func checkDFPAdViewContainsPBMAd(_ adView: GADBannerView) -> Bool {
        
        let view = findInView(adView) { (subView) -> Bool in
            return subView is WKWebView || subView is UIWebView
        }
        
        if let wkWebView = view as? WKWebView  {
            let wkResult = PBViewTool.checkJSExistInWebView(wkWebView: wkWebView) && checkWebViewSize(webView: wkWebView)
            return wkResult
        } else if let uiWebView = view as? UIWebView {
            let uiResult = PBViewTool.checkJSExistInWebView(uiWebView: uiWebView) && checkWebViewSize(webView: uiWebView)
            return uiResult
        }
        
        return false;
    }
    
    class func findInView(_ view: UIView, closure:(UIView) -> Bool) -> UIView? {
        for subview in view.subviews {
            
            if closure(subview)  {
                return subview
            }
            
            if let result = findInView(subview, closure: closure) {
                return result
            }
            
        }
        
        return nil
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
    //Silumator uses UIWebView
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
    class func checkWebViewSize(webView: UIView) -> Bool {
        
        let webviewWidth = webView.frame.size.width
        let webviewHeight = webView.frame.size.height

        return webviewWidth > 1 && webviewHeight >= 1
    }
}
