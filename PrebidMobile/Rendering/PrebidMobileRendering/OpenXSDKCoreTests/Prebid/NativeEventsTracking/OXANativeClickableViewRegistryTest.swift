//
//  OXANativeClickableViewRegistryTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2021 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class OXANativeClickableViewRegistryTest: XCTestCase {
    private class MockClickHandlersDic {
        private let clickHandlers = NSMutableDictionary()
        private let keyForView: (UIView) -> NSString = { NSString(format: "%p", $0) }
        
        subscript(index: UIView) -> OXMVoidBlock? {
            get { return clickHandlers[keyForView(index)] as? OXMVoidBlock }
            set { clickHandlers[keyForView(index)] = newValue }
        }
    }
    
    func testRegisterLink() {
        testRegisterSimpleRegistration(registerMethod: OXANativeClickableViewRegistry.register)
    }
    func testRegisterParentLink() {
        testRegisterSimpleRegistration(registerMethod: OXANativeClickableViewRegistry.registerParentLink)
    }
    
    typealias RegisterMethodType = (OXANativeClickableViewRegistry)->(OXANativeAdMarkupLink, UIView)->()
    
    // only one method called
    func testRegisterSimpleRegistration(registerMethod: RegisterMethodType) {
        let clickHandlers = MockClickHandlersDic()
        
        let onBindClickHandler = NSMutableArray(object: { XCTFail() })
        let onDetachClickHandler = NSMutableArray(object: { XCTFail() })
        let unexpectedClick: OXANativeViewClickHandlerBlock = { _, _, _, _ in XCTFail() }
        let onClick = NSMutableArray(object: unexpectedClick)
        
        var registry: OXANativeClickableViewRegistry? = .init { (view) -> OXANativeClickTrackerBinderBlock? in
            return { handler in
                clickHandlers[view] = handler
                (onBindClickHandler[0] as! ()->())()
                return {
                    clickHandlers[view] = nil
                    (onDetachClickHandler[0] as! ()->())()
                }
            }
        } clickHandler: { (url, fallback, clicktrackers, onClickthroughExit) in
            (onClick[0] as! OXANativeViewClickHandlerBlock)(url, fallback, clicktrackers, onClickthroughExit)
        }

        let testView = UIView()
        let testURL = "test URL"
        let link = OXANativeAdMarkupLink(url: testURL)
        link.fallback = "http://fallback"
        link.clicktrackers = ["q", "r://z.b.t"]
        
        let testViewClickBound = expectation(description: "click handler bound to test view")
        onBindClickHandler[0] = { testViewClickBound.fulfill() }
        
        autoreleasepool { // ensures OXANativeClickTrackingEntry will be destroyed with parent registry
            registerMethod(registry!)(link, testView)
        }
        waitForExpectations(timeout: 1)
        XCTAssertNotNil(clickHandlers[testView])
        
        let clickReported = expectation(description: "click reported")
        let expectedClick: OXANativeViewClickHandlerBlock = { url, fallback, clicktrackers, onClickthroughExit in
            clickReported.fulfill()
            XCTAssertEqual(url, link.url)
            XCTAssertEqual(fallback, link.fallback)
            XCTAssertEqual(clicktrackers, link.clicktrackers)
        }
        onClick[0] = expectedClick
        
        clickHandlers[testView]!()
        waitForExpectations(timeout: 1)
        
        let clickHandlerDetached = expectation(description: "click handler detached")
        onDetachClickHandler[0] = { clickHandlerDetached.fulfill() }
        registry = nil // release
        waitForExpectations(timeout: 1)
        XCTAssertNil(clickHandlers[testView])
    }
    
    // 'registerParentLink' called after nil-URL 'registerLink'
    func testRegisterDoubleRegistration() {
        let clickHandlers = MockClickHandlersDic()
        
        let unexpectedClick: OXANativeViewClickHandlerBlock = { _, _, _, _ in XCTFail() }
        let onClick = NSMutableArray(object: unexpectedClick)
        
        let registry: OXANativeClickableViewRegistry? = .init { (view) -> OXANativeClickTrackerBinderBlock? in
            return { handler in
                clickHandlers[view] = handler
                return {
                    clickHandlers[view] = nil
                }
            }
        } clickHandler: { (url, fallback, clicktrackers, onClickthroughExit) in
            (onClick[0] as! OXANativeViewClickHandlerBlock)(url, fallback, clicktrackers, onClickthroughExit)
        }

        let testView = UIView()
        
        let firstLink = OXANativeAdMarkupLink()
        firstLink.clicktrackers = ["q", "r://z.b.t"]
        
        let parentLink = OXANativeAdMarkupLink(url: "url://parent")
        parentLink.fallback = "https://parent.fallback"
        parentLink.clicktrackers = ["y"]
        
        registry!.register(firstLink, for: testView)
        registry!.registerParentLink(parentLink, for: testView)
        
        let clickReported = expectation(description: "click reported")
        let expectedClick: OXANativeViewClickHandlerBlock = { url, fallback, clicktrackers, onClickthroughExit in
            clickReported.fulfill()
            XCTAssertEqual(url, parentLink.url)
            XCTAssertEqual(fallback, parentLink.fallback)
            XCTAssertEqual(clicktrackers, firstLink.clicktrackers! + parentLink.clicktrackers!)
        }
        onClick[0] = expectedClick
        
        clickHandlers[testView]!()
        waitForExpectations(timeout: 1)
    }
    
    // 'registerParentLink' called after non-nil-URL 'registerLink'; followed by another 'registerLink'
    func testRegisterTripleRegistration() {
        let clickHandlers = MockClickHandlersDic()
        
        let unexpectedClick: OXANativeViewClickHandlerBlock = { _, _, _, _ in XCTFail() }
        let onClick = NSMutableArray(object: unexpectedClick)
        
        let registry: OXANativeClickableViewRegistry? = .init { (view) -> OXANativeClickTrackerBinderBlock? in
            return { handler in
                clickHandlers[view] = handler
                return {
                    clickHandlers[view] = nil
                }
            }
        } clickHandler: { (url, fallback, clicktrackers, onClickthroughExit) in
            (onClick[0] as! OXANativeViewClickHandlerBlock)(url, fallback, clicktrackers, onClickthroughExit)
        }

        let testView = UIView()
        
        let firstLink = OXANativeAdMarkupLink(url: "first URL")
        firstLink.fallback = "http://fallback"
        firstLink.clicktrackers = ["q", "r://z.b.t"]
        
        let parentLink = OXANativeAdMarkupLink(url: "url://parent")
        parentLink.fallback = "https://parent.fallback"
        parentLink.clicktrackers = ["y"]
        
        registry!.register(firstLink, for: testView)
        registry!.registerParentLink(parentLink, for: testView)
        
        let clickReported1 = expectation(description: "click reported")
        let expectedClick1: OXANativeViewClickHandlerBlock = { url, fallback, clicktrackers, onClickthroughExit in
            clickReported1.fulfill()
            XCTAssertEqual(url, firstLink.url)
            XCTAssertEqual(fallback, firstLink.fallback)
            XCTAssertEqual(clicktrackers, firstLink.clicktrackers! + parentLink.clicktrackers!)
        }
        onClick[0] = expectedClick1
        
        clickHandlers[testView]!()
        waitForExpectations(timeout: 1)
        
        let secondLink = OXANativeAdMarkupLink(url: "<second URL>")
        secondLink.fallback = "ftp://q?k=g"
        secondLink.clicktrackers = ["b!", "mlp!"]
        
        registry!.register(secondLink, for: testView)
        
        let clickReported2 = expectation(description: "click reported")
        let expectedClick2: OXANativeViewClickHandlerBlock = { url, fallback, clicktrackers, onClickthroughExit in
            clickReported2.fulfill()
            XCTAssertEqual(url, secondLink.url)
            XCTAssertEqual(fallback, secondLink.fallback)
            XCTAssertEqual(clicktrackers, firstLink.clicktrackers! + parentLink.clicktrackers! + secondLink.clicktrackers!)
        }
        onClick[0] = expectedClick2
        
        clickHandlers[testView]!()
        waitForExpectations(timeout: 1)
    }
}
