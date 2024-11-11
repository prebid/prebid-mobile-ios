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

import Foundation
import WebKit

@objcMembers
public final class AdViewUtils: NSObject {
    
    private static let innerHtmlScript = "document.body.innerHTML"
    
    // hb_size
    private static let sizeValueRegexExpression = "[0-9]+x[0-9]+"
    private static let sizeObjectRegexExpression = "hb_size\\W+\(sizeValueRegexExpression)"
    
    // hb_cache_id
    private static let cacheIDValueRegexExpression = "[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}"
    private static let cacheIDObjectRegexExpression = "hb_cache_id\\W+\(cacheIDValueRegexExpression)"
    
    private override init() {}
    
    public static func findPrebidCreativeSize(
        _ adView: UIView,
        success: @escaping (CGSize) -> Void,
        failure: @escaping (Error) -> Void
    ) {
        guard let webView = adView.allSubViewsOf(type: WKWebView.self).first else {
            let error = PbWebViewSearchErrorFactory.noWKWebView
            Log.warn(error.localizedDescription)
            failure(error)
            return
        }
        
        getInnerHTML(from: webView) { result in
            switch result {
            case .success(let innerHTML):
                switch findSizeInHtml(body: innerHTML) {
                case .success(let size):
                    success(size)
                case .failure(let error):
                    failure(error)
                }
            case .failure(let error):
                failure(error)
            }
        }
    }
    
    static func findPrebidCreativeCacheID(
        _ adView: UIView,
        completion: ((Result<String, Error>) -> Void)? = nil
    ) {
        guard let webView = adView.allSubViewsOf(type: WKWebView.self).first else {
            let error = PbWebViewSearchErrorFactory.noWKWebView
            Log.warn(error.localizedDescription)
            completion?(.failure(error))
            return
        }
        
        getInnerHTML(from: webView) { result in
            switch result {
            case .success(let innerHTML):
                completion?(findCacheIDInHtml(body: innerHTML))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
    
    private static func findSizeInHtml(body: String) -> Result<CGSize, PbWebViewSearchError> {
        guard let hbSizeObject = body.matchAndCheck(regex: AdViewUtils.sizeObjectRegexExpression) else {
            return .failure(PbWebViewSearchErrorFactory.noSizeObject)
        }
        
        guard let hbSizeValue = hbSizeObject.matchAndCheck(regex: AdViewUtils.sizeValueRegexExpression) else {
            return .failure(PbWebViewSearchErrorFactory.noSizeValue)
        }
        
        if let size = hbSizeValue.toCGSize() {
            return .success(size)
        } else {
            return .failure(PbWebViewSearchErrorFactory.sizeUnparsed)
        }
    }
    
    private static func findCacheIDInHtml(body: String) -> Result<String, Error> {
        guard let hbCacheIDObject = body.matchAndCheck(regex: AdViewUtils.cacheIDObjectRegexExpression) else {
            return .failure(PbWebViewSearchErrorFactory.noCacheIDObject)
        }
        
        guard let hbCacheIDValue = hbCacheIDObject.matchAndCheck(regex: AdViewUtils.cacheIDValueRegexExpression) else {
            return .failure(PbWebViewSearchErrorFactory.noCacheIDValue)
        }
        
        return .success(hbCacheIDValue)
    }
    
    private static func getInnerHTML(
        from wkWebView: WKWebView,
        completion: @escaping (Result<String, PbWebViewSearchError>) -> Void
    ) {
        wkWebView.evaluateJavaScript(
            AdViewUtils.innerHtmlScript,
            completionHandler: { (value: Any!, error: Error!) -> Void in
                guard error == nil else {
                    let findError = PbWebViewSearchErrorFactory.getWkWebViewFailedError(message: error.localizedDescription)
                    Log.warn(findError.localizedDescription)
                    completion(.failure(findError))
                    return
                }
                
                guard let innerHTML = value as? String, !innerHTML.isEmpty else {
                    let findError = PbWebViewSearchErrorFactory.noHtml
                    completion(.failure(findError))
                    return
                }
                
                completion(.success(innerHTML))
            })
    }
}

//It is not possible to use Enum because of compatibility with Objective-C
final class PbWebViewSearchErrorFactory {
    
    private init() {}
    
    // MARK: - Platform's errors
    static let unspecifiedCode = 101
    
    // MARK: - common errors
    static let noWKWebViewCode = 111
    static let wkWebViewFailedCode = 126
    static let noHtmlCode = 130
    static let noSizeObjectCode = 140
    static let noSizeValueCode = 150
    static let sizeUnparsedCode = 160
    static let noCacheIDObjectCode = 170
    static let noCacheIDValueCode = 180
    
    //MARK: - fileprivate and private zone
    fileprivate static let unspecified = getUnspecifiedError()
    fileprivate static let noWKWebView = getNoWKWebViewError()
    fileprivate static let noHtml = getNoHtmlError()
    fileprivate static let noSizeObject = getNoSizeObjectError()
    fileprivate static let noSizeValue = getNoSizeValueError()
    fileprivate static let noCacheIDObject = getNoCacheIDObjectError()
    fileprivate static let noCacheIDValue = getNoCacheIDValueError()
    fileprivate static let sizeUnparsed = getSizeUnparsedError()
    
    private static func getUnspecifiedError() -> PbWebViewSearchError{
        return getError(code: unspecifiedCode, description: "Unspecified error")
    }
    
    private static func getNoWKWebViewError() -> PbWebViewSearchError {
        return getError(code: noWKWebViewCode, description: "The view doesn't include WKWebView")
    }
    
    fileprivate static func getWkWebViewFailedError(message: String) -> PbWebViewSearchError {
        return getError(code: wkWebViewFailedCode, description: "WKWebView error:\(message)")
    }
    
    private static func getNoHtmlError() -> PbWebViewSearchError {
        return getError(code: noHtmlCode, description: "The WebView doesn't have HTML")
    }
    
    private static func getNoSizeObjectError() -> PbWebViewSearchError {
        return getError(code: noSizeObjectCode, description: "The HTML doesn't contain a size object")
    }
    
    private static func getNoSizeValueError() -> PbWebViewSearchError {
        return getError(code: noSizeValueCode, description: "The size object doesn't contain a value")
    }
    
    private static func getNoCacheIDObjectError() -> PbWebViewSearchError {
        return getError(code: noCacheIDObjectCode, description: "The HTML doesn't contain a cache ID object")
    }
    
    private static func getNoCacheIDValueError() -> PbWebViewSearchError {
        return getError(code: noCacheIDValueCode, description: "The cache ID object doesn't contain a value")
    }
    
    private static func getSizeUnparsedError() -> PbWebViewSearchError {
        return getError(code: sizeUnparsedCode, description: "The size value has a wrong format")
    }
    
    private static func getError(code: Int, description: String) -> PbWebViewSearchError {
        return PbWebViewSearchError(domain: "com.prebidmobile.ios", code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
}
