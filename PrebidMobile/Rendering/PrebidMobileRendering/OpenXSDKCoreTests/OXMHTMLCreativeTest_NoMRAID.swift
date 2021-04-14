//
//  OXMHTMLCreativeNoMRAID.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import Foundation
import XCTest
@testable import PrebidMobileRendering

class OXMHTMLCreativeTest_NoMRAID : OXMHTMLCreativeTest_Base {
    
    private var logToFile: LogToFileLock?
    
    override func tearDown() {
        logToFile = nil
        super.tearDown()
    }
    
    func testNoMRAID() {
        logToFile = .init()
        
        let sdkConfiguration = OXASDKConfiguration()
        
        
        let serverConnection = OXMServerConnection(userAgentService: MockUserAgentService())
        serverConnection.protocolClasses.add(MockServerURLProtocol.self)

        let mockWebView = MockOXMWebView()
        let oxmHTMLCreative = OXMHTMLCreative(
            creativeModel: MockOXMCreativeModel(),
            transaction:UtilitiesForTesting.createEmptyTransaction(),
            webView: mockWebView,
               sdkConfiguration:sdkConfiguration
        )
        let mockMRAIDController = OXMMRAIDController(creative:oxmHTMLCreative,
                                                     viewControllerForPresenting:UIViewController(),
                                                     webView:mockWebView,
                                                     creativeViewDelegate:self,
                                                     downloadBlock:createLoader(connection: serverConnection),
                                                     deviceAccessManagerClass: MockOXMDeviceAccessManager.self,
                                                        sdkConfiguration: sdkConfiguration)
        oxmHTMLCreative.mraidController = mockMRAIDController
        oxmHTMLCreative.view = mockWebView
        
        //non-mraid command
        oxmHTMLCreative.webView(mockWebView, receivedMRAIDLink:URL(string: "mraid:non_cmd")!)
        let log = OXMLog.singleton.getLogFileAsString()
        XCTAssert(log.contains("Unrecognized MRAID command non_cmd"))
    }
}
