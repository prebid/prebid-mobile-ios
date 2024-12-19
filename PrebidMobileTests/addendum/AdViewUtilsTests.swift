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

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRegexMatches() {
        var result = regexMatcherHelper(for: "^a", in: "aaa aaa")
        XCTAssert(result.count == 1)
        XCTAssert(result[0] == "a")
        
        result = regexMatcherHelper(for: "^b", in: "aaa aaa")
        XCTAssert(result.count == 0)
        
        result = regexMatcherHelper(for: "aaa aaa", in: "^a")
        XCTAssert(result.count == 0)
        
        result = regexMatcherHelper(for: "[0-9]+x[0-9]+", in: "{ \n adManagerResponse:\"hb_size\":[\"728x90\"],\"hb_size_rubicon\":[\"1x1\"],moPubResponse:\"hb_size:300x250\" \n }")
        XCTAssert(result.count == 3)
        XCTAssert(result[0] == "728x90")
        XCTAssert(result[1] == "1x1")
        XCTAssert(result[2] == "300x250")
        
        result = regexMatcherHelper(for: "hb_size\\W+[0-9]+x[0-9]+", in: "{ \n adManagerResponse:\"hb_size\":[\"728x90\"],\"hb_size_rubicon\":[\"1x1\"],moPubResponse:\"hb_size:300x250\" \n }")
        XCTAssert(result.count == 2)
        XCTAssert(result[0] == "hb_size\":[\"728x90")
        XCTAssert(result[1] == "hb_size:300x250")
    }
    
    func regexMatcherHelper(for regex: String, in text: String) -> [String] {
        return AdViewUtils.matches(for: regex, in: text)
    }
    
    func testRegexMatchAndCheck() {
        var result = AdViewUtils.matchAndCheck(regex: "^a", text: "aaa aaa")
        
        XCTAssertNotNil(result)
        XCTAssert(result == "a")
        
        result = AdViewUtils.matchAndCheck(regex: "^b", text: "aaa aaa")
        XCTAssertNil(result)
    }
    
    func testFindHbSizeValue() {
        let result = AdViewUtils.findHbSizeValue(in: "{ \n adManagerResponse:\"hb_size\":[\"728x90\"],\"hb_size_rubicon\":[\"728x90\"],moPubResponse:\"hb_size:300x250\" \n }")
        XCTAssertNotNil(result)
        XCTAssert(result == "728x90")
    }
    
    func testFindHbSizeKeyValue() {
        let result = AdViewUtils.findHbSizeObject(in: "{ \n adManagerResponse:\"hb_size\":[\"728x90\"],\"hb_size_rubicon\":[\"728x90\"],moPubResponse:\"hb_size:300x250\" \n }")
        XCTAssertNotNil(result)
        XCTAssert(result == "hb_size\":[\"728x90")
    }
    
    func testStringToCGSize() {
        var result = AdViewUtils.stringToCGSize("300x250")
        XCTAssertNotNil(result)
        XCTAssert(result == CGSize(width: 300, height: 250))
        
        result = AdViewUtils.stringToCGSize("300x250x1")
        XCTAssertNil(result)
        
        result = AdViewUtils.stringToCGSize("ERROR")
        XCTAssertNil(result)
        
        result = AdViewUtils.stringToCGSize("300x250ERROR")
        XCTAssertNil(result)
    }
    
    func testFailureFindASizeInNilHtmlCode() {
        findSizeInHtmlFailureHelper(body: nil, expectedErrorCode: PbFindSizeErrorFactory.noHtmlCode)
    }
    
    func testFailureFindASizeIfItIsNotPresent() {
        findSizeInHtmlFailureHelper(body: "<script> \n </script>", expectedErrorCode: PbFindSizeErrorFactory.noSizeObjectCode)
    }
    
    func testFailureFindASizeIfItHasTheWrongType() {
        findSizeInHtmlFailureHelper(body: "<script> \n \"hb_size\":\"1ERROR1\" \n </script>", expectedErrorCode: PbFindSizeErrorFactory.noSizeObjectCode)
    }
    
    func testSuccessFindASizeIfProperlyFormatted() {
        findSizeInHtmlSuccessHelper(body: "<script> \n \"hb_size\":[\"728x90\"] \n </script>", expectedSize: CGSize(width: 728, height: 90 ))
    }
    
    func findSizeInHtmlFailureHelper(body: String?, expectedErrorCode: Int) {
        // given
        var size: CGSize? = nil
        var error: PbFindSizeError? = nil
        
        // when
        let result = AdViewUtils.findSizeInHtml(body: body)
        size = result.size
        error = result.error
        
        // then
        XCTAssertNil(size)
        XCTAssertNotNil(error)
        XCTAssertEqual(expectedErrorCode, error?.code)
    }
    
    func findSizeInHtmlSuccessHelper(body: String?, expectedSize: CGSize) {
        // given
        var size: CGSize? = nil
        var error: PbFindSizeError? = nil
        
        // when
        let result = AdViewUtils.findSizeInHtml(body: body)
        size = result.size
        error = result.error
        
        // then
        XCTAssertNotNil(size)
        XCTAssertEqual(expectedSize, size)
        XCTAssertNil(error)
    }
    
    func testFailureFindSizeInViewIfThereIsNoWebView() {
        
        let uiView = UIView()
        
        findSizeInViewFailureHelper(uiView, expectedErrorCode: PbFindSizeErrorFactory.noWKWebViewCode)
    }
    
    func testFailureFindSizeInViewIfWkWebViewWithoutHTML() {
        
        let wkWebView = WKWebView()
        
        findSizeInViewFailureHelper(wkWebView, expectedErrorCode: PbFindSizeErrorFactory.noHtmlCode)
    }
    
    func testFailureFindSizeInUIView() {
        
        let uiView = UIView()
        
        findSizeInViewFailureHelper(uiView, expectedErrorCode: PbFindSizeErrorFactory.noWKWebViewCode)
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
