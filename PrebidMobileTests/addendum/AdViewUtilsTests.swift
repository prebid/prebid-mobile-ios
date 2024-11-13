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

import XCTest
import WebKit
@testable import PrebidMobile

class AdViewUtilsTests: XCTestCase {
    
    func testFindHbSizeValue() {
        let body = "{ \n adManagerResponse:\"hb_size\":[\"728x90\"],\"hb_size_rubicon\":[\"728x90\"],moPubResponse:\"hb_size:300x250\" \n }"
        
        let result = AdViewUtils.findValueInHtml(
            body: body,
            objectRegex: AdViewUtils.sizeObjectRegexExpression,
            valueRegex: AdViewUtils.sizeValueRegexExpression,
            parseResult: { .success($0) }
        )
        
        switch result {
        case .success(let size):
            XCTAssert(size == "728x90")
        case .failure(let error):
            XCTFail("AdViewUtils unexpectedly failed with error: \(error.localizedDescription)")
        }
    }
    
    func testFailureFindASizeInNilHtmlCode() {
        let exp = expectation(description: "findPrebidCreativeSize should fail")
        
        AdViewUtils.findPrebidCreativeSize(WKWebView()) { size in
            XCTFail("Expected to fail but found creative size.")
        } failure: { error in
            exp.fulfill()
            XCTAssert((error as NSError).code == PbWebViewSearchErrorFactory.noHtmlCode)
        }
        
        wait(for: [exp], timeout: 15)
    }
    
    func testFailureFindASizeIfItIsNotPresent() {
        findSizeInHtmlFailureHelper(
            body: "<script> \n </script>",
            expectedErrorCode: PbWebViewSearchErrorFactory.noObjectCode
        )
    }
    
    func testFailureFindASizeIfItHasTheWrongType() {
        findSizeInHtmlFailureHelper(
            body: "<script> \n \"hb_size\":\"1ERROR1\" \n </script>",
            expectedErrorCode: PbWebViewSearchErrorFactory.noObjectCode
        )
    }
    
    func testSuccessFindASizeIfProperlyFormatted() {
        findSizeInHtmlSuccessHelper(
            body: "<script> \n \"hb_size\":[\"728x90\"] \n </script>",
            expectedSize: CGSize(width: 728, height: 90)
        )
    }
    
    func findSizeInHtmlFailureHelper(body: String, expectedErrorCode: Int) {
        // when
        let result = AdViewUtils.findValueInHtml(
            body: body,
            objectRegex: AdViewUtils.sizeObjectRegexExpression,
            valueRegex: AdViewUtils.sizeValueRegexExpression,
            parseResult:  {
                if let cgSize = $0.toCGSize() {
                    return .success(cgSize)
                } else {
                    return .failure(NSError(
                        domain: "com.prebid.tests",
                        code: PbWebViewSearchErrorFactory.valueUnparsedCode
                    ))
                }
            }
        )
        
        // then
        switch result {
        case .success(_):
            XCTFail("Expected failure")
        case .failure(let error as NSError):
            XCTAssertEqual(expectedErrorCode, error.code)
        }
    }
    
    func findSizeInHtmlSuccessHelper(body: String, expectedSize: CGSize) {
        // when
        let result = AdViewUtils.findValueInHtml(
            body: body,
            objectRegex: AdViewUtils.sizeObjectRegexExpression,
            valueRegex: AdViewUtils.sizeValueRegexExpression,
            parseResult:  {
                if let cgSize = $0.toCGSize() {
                    return .success(cgSize)
                } else {
                    return .failure(NSError(
                        domain: "com.prebid.tests",
                        code: PbWebViewSearchErrorFactory.valueUnparsedCode
                    ))
                }
            }
        )
        
        // then
        switch result {
        case .success(let size):
            XCTAssert(expectedSize == size)
        case .failure(_):
            XCTFail("Expected success")
        }
    }
    
    func testFailureFindSizeInViewIfThereIsNoWebView() {
        let uiView = UIView()
        findSizeInViewFailureHelper(uiView, expectedErrorCode: PbWebViewSearchErrorFactory.noWKWebViewCode)
    }
    
    func testFailureFindSizeInViewIfWkWebViewWithoutHTML() {
        let wkWebView = WKWebView()
        findSizeInViewFailureHelper(wkWebView, expectedErrorCode: PbWebViewSearchErrorFactory.noHtmlCode)
    }
    
    func testFailureFindSizeInUIView() {
        let uiView = UIView()
        findSizeInViewFailureHelper(uiView, expectedErrorCode: PbWebViewSearchErrorFactory.noWKWebViewCode)
    }
    
    func testFindPrebidCacheIDSuccess() {
        let webView = WKWebView()
        setHtmlIntoWkWebView(successHtmlWithSize728x90, webView)
        
        let adView = UIView()
        adView.addSubview(webView)
        
        let expectation = expectation(description: "Expected to find a cache ID successfully")
        
        AdViewUtils.findPrebidCacheID(adView) { result in
            switch result {
            case .success(let cacheID):
                XCTAssertEqual(cacheID, "376f6334-2bba-4f58-a76b-feeb419f513a")
            case .failure:
                XCTFail("Expected to find cache ID, but failed")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFindPrebidCacheIDFailureNoCacheID() {
        let html = "<div>No cache ID here</div>"
        let webView = WKWebView()
        setHtmlIntoWkWebView(html, webView)
        
        let adView = UIView()
        adView.addSubview(webView)
        
        let expectation = expectation(description: "Expected to fail due to missing cache ID")
        
        AdViewUtils.findPrebidCacheID(adView) { result in
            switch result {
            case .success:
                XCTFail("Expected to fail, but found a cache ID")
            case .failure(let error):
                XCTAssertEqual((error as? PbWebViewSearchError)?.code, PbWebViewSearchErrorFactory.noObjectCode)
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    class TestingWKNavigationDelegate: NSObject, WKNavigationDelegate {
        let loadSuccesfulException: XCTestExpectation
        
        init(_ loadSuccesfulException: XCTestExpectation) {
            self.loadSuccesfulException = loadSuccesfulException
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.body.innerHTML") { innerHTML, error in
                
                if error != nil {
                    XCTFail("TestingWKNavigationDelegate error: \(error?.localizedDescription ?? "some error")")
                }
                self.loadSuccesfulException.fulfill()
            }
        }
    }
    
    let successHtmlWithSize728x90 = """
                <html><body leftMargin="0" topMargin="0" marginwidth="0" marginheight="0"><script src = "https://ads.rubiconproject.com/prebid/creative.js"></script>
                <script>
                  var ucTagData = {};
                  ucTagData.adServerDomain = "";
                  ucTagData.pubUrl = "0.1.0.iphone.com.Prebid.PrebidDemo.adsenseformobileapps.com";
                  ucTagData.targetingMap = {"bidder":["rubicon"],"bidid":["ee34715d-336c-4e77-b651-ba62f9d4e026"],"hb_bidder":["rubicon"],"hb_bidder_rubicon":["rubicon"],"hb_cache_host":["prebid-cache-europe.rubiconproject.com"],"hb_cache_host_rubicon":["prebid-cache-europe.rubiconproject.com"],"hb_cache_id":["376f6334-2bba-4f58-a76b-feeb419f513a"],"hb_cache_id_rubicon":["376f6334-2bba-4f58-a76b-feeb419f513a"],"hb_cache_path":["/cache"],"hb_cache_path_rubicon":["/cache"],"hb_env":["mobile-app"],"hb_env_rubicon":["mobile-app"],"hb_pb":["1.40"],"hb_pb_rubicon":["1.40"],"hb_size":["728x90"],"hb_size_rubicon":["728x90"]};
                
                  try {
                    ucTag.renderAd(document, ucTagData);
                  } catch (e) {
                    console.log(e);
                  }
                </script></div><div style="bottom:0;right:0;width:100px;height:100px;background:initial !important;position:absolute !important;max-width:100% !important;max-height:100% !important;pointer-events:none !important;image-rendering:pixelated !important;background-repeat:no-repeat !important;z-index:2147483647;background-image:url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGQAAABkBAMAAACCzIhnAAAABlBMVEUAAAD+AciWmZzWAAAAAnRSTlMAApidrBQAAAEZSURBVFjD7VRJksQwCIMf8P/XjgMS4OXSh7nhdKXawbEsoUjk96ExZF1aM4sh6zLhjMX19BuGP5hpbOc/3NbdgCLA8AJn3+6O4cswY7GqDnRU/bDHRoWiTxR7oyQHs4vLp8jFpRQLjFOxwNgUy2FxirsH72dEEHKxpkZ0RoxLpYTsjFLzjVEsVRDYqPhrRQbElCdBBc4ADDaBiQCTSzXezlPQRlbdJSUtxdEZI0gpxxZvyuXxNcEkvQupIMzt5GDC07L7quWAw8lSLmwekzLsy8nsiW2fBPvQ6DYna+nRnGxp1svJJvVhppNV6sN8OLnZozm5Oel28iTMJMwkzCTMJMwkzCTMJMwkzCTMJMwkzCTMJMwkzL8nzB8ivkq1hG7lNQAAAABJRU5ErkJggg==') !important;"></div><script src="https://pagead2.googlesyndication.com/omsdk/releases/live/omid_session_bin.js"></script><script type="text/javascript">(function() {var omidSession = new OmidCreativeSession([]);})();</script></body></html>
                """
    
    func testSuccessFindSizeInWkWebView() {
        let wkWebView = WKWebView()
        
        setHtmlIntoWkWebView(successHtmlWithSize728x90, wkWebView)
        findSizeInViewSuccessHelper(wkWebView, expectedSize: CGSize(width: 728, height: 90))
    }
    
    func setHtmlIntoWkWebView(_ html: String, _ wkWebView: WKWebView) {
        let loadSuccesfulException = expectation(description: "\(#function)")
        
        let testingWKNavigationDelegate = TestingWKNavigationDelegate(loadSuccesfulException)
        wkWebView.navigationDelegate = testingWKNavigationDelegate
        
        wkWebView.loadHTMLString(html, baseURL: nil)
        
        waitForExpectations(timeout: 30, handler: nil)
        wkWebView.navigationDelegate = nil
    }
    
    func findSizeInViewFailureHelper(_ view: UIView, expectedErrorCode: Int) {
        let loadSuccesfulException = expectation(description: "\(#function)")
        
        // given
        var size: CGSize? = nil
        var error: Error? = nil
        let success: (CGSize) -> Void = { s in
            size = s
            loadSuccesfulException.fulfill()
        }
        
        let failure: (Error) -> Void = { err in
            error = err
            loadSuccesfulException.fulfill()
        }
        
        // when
        AdViewUtils.findPrebidCreativeSize(view, success: success, failure: failure)
        waitForExpectations(timeout: 30, handler: nil)
        
        // then
        XCTAssertNil(size)
        XCTAssertNotNil(error)
        XCTAssertEqual(expectedErrorCode, error?._code)
        
    }
    
    func findSizeInViewSuccessHelper(_ view: UIView, expectedSize: CGSize) {
        let loadSuccesfulException = expectation(description: "\(#function)")
        
        // given
        var result: CGSize? = nil
        var error: Error? = nil
        let success: (CGSize) -> Void = { size in
            result = size
            loadSuccesfulException.fulfill()
        }
        
        let failure: (Error) -> Void = { err in
            error = err
            loadSuccesfulException.fulfill()
        }
        
        // when
        AdViewUtils.findPrebidCreativeSize(view, success: success, failure: failure)
        waitForExpectations(timeout: 30, handler: nil)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(expectedSize, result)
        XCTAssertNil(error)
    }
}
