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

/// `AdViewUtils` provides utility methods for working with ad views, including finding creative sizes.
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
    
    /// Finds the creative size for a given ad view by searching for the `hb_size` attribute in the ad's HTML content.
    ///
    /// - Parameters:
    ///   - adView: The ad view from which to extract the creative size.
    ///   - success: Closure called with the `CGSize` of the ad creative if found successfully.
    ///   - failure: Closure called with an `Error` if the size could not be determined.
    public static func findPrebidCreativeSize(
        _ adView: UIView,
        success: @escaping (CGSize) -> Void,
        failure: @escaping (Error) -> Void
    ) {
        findValueInCreative(
            adView,
            objectRegex: AdViewUtils.sizeObjectRegexExpression,
            valueRegex: AdViewUtils.sizeValueRegexExpression,
            parseResult: {
                if let cgSize = $0.toCGSize() {
                    return .success(cgSize)
                } else {
                    return .failure(PbWebViewSearchErrorFactory.valueUnparsed)
                }
            }, completion: { result in
                switch result {
                case .success(let size):
                    success(size)
                case .failure(let error):
                    failure(error)
                }
            }
        )
    }
    
    static func findPrebidCacheID(
        _ adView: UIView,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        findValueInCreative(
            adView,
            objectRegex: AdViewUtils.cacheIDObjectRegexExpression,
            valueRegex: AdViewUtils.cacheIDValueRegexExpression,
            parseResult: { .success($0) },
            completion: completion
        )
    }
    
    static func findValueInCreative<T>(
        _ adView: UIView,
        objectRegex: String,
        valueRegex: String,
        parseResult: @escaping (String) -> (Result<T, Error>),
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let webView = adView.allSubViewsOf(type: WKWebView.self).first else {
            let error = PbWebViewSearchErrorFactory.noWKWebView
            Log.warn(error.localizedDescription)
            completion(.failure(error))
            return
        }
        
        getInnerHTML(from: webView) { result in
            switch result {
            case .success(let innerHTML):
                let result = findValueInHtml(
                    body: innerHTML,
                    objectRegex: objectRegex,
                    valueRegex: valueRegex,
                    parseResult: parseResult
                )
                
                completion(result)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private static func findValueInHtml<T>(
        body: String,
        objectRegex: String,
        valueRegex: String,
        parseResult: (String) -> (Result<T, Error>)
    ) -> Result<T, Error> {
        guard let objectMatch = body.matchAndCheck(regex: objectRegex) else {
            return .failure(PbWebViewSearchErrorFactory.noObject)
        }
        
        guard let valueMatch = objectMatch.matchAndCheck(regex: valueRegex) else {
            return .failure(PbWebViewSearchErrorFactory.noValue)
        }
        
        return parseResult(valueMatch)
    }
    
    private static func getInnerHTML(
        from wkWebView: WKWebView,
        completion: @escaping (Result<String, PbWebViewSearchError>) -> Void
    ) {
        wkWebView.evaluateJavaScript(
            AdViewUtils.innerHtmlScript,
            completionHandler: { (value: Any!, error: Error!) -> Void in
                guard error == nil else {
                    let findError = PbWebViewSearchErrorFactory
                        .getWkWebViewFailedError(message: error.localizedDescription)
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
            }
        )
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
    static let noObjectCode = 140
    static let noValueCode = 150
    static let valueUnparsedCode = 160
    
    //MARK: - fileprivate and private zone
    fileprivate static let unspecified = getUnspecifiedError()
    fileprivate static let noWKWebView = getNoWKWebViewError()
    fileprivate static let noHtml = getNoHtmlError()
    fileprivate static let noObject = getNoObjectError()
    fileprivate static let noValue = getNoSizeValueError()
    fileprivate static let valueUnparsed = getValueUnparsedError()
    
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
    
    private static func getNoObjectError() -> PbWebViewSearchError {
        return getError(code: noObjectCode, description: "The HTML doesn't contain a required object")
    }
    
    private static func getNoSizeValueError() -> PbWebViewSearchError {
        return getError(code: noValueCode, description: "The search object doesn't contain a value")
    }
    
    private static func getValueUnparsedError() -> PbWebViewSearchError {
        return getError(code: valueUnparsedCode, description: "The value has a wrong format")
    }
    
    private static func getError(code: Int, description: String) -> PbWebViewSearchError {
        return PbWebViewSearchError(domain: "com.prebidmobile.ios", code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
}
