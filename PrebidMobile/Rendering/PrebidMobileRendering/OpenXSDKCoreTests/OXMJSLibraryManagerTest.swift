//
//  OXMJSLibraryManagerTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2019 OpenX. All rights reserved.
//

import XCTest
@testable import PrebidMobileRendering

class OXMJSLibraryManagerTest: XCTestCase {
    private let connection = UtilitiesForTesting.createConnectionForMockedTest()
    private let libraryManager = OXMJSLibraryManager.shared()
    
    override func setUp() {
        super.setUp()
        MockServer.singleton().reset()
    }
    
    override func tearDown() {
        super.tearDown()
        MockServer.singleton().reset()
        libraryManager.clearData()
    }
    
    func testInitializationValues() {
        XCTAssertNil(libraryManager.cachedLibraries.object(forKey: "mraid.jslib"))
        XCTAssertNil(libraryManager.cachedLibraries.object(forKey: "omsdk.jslib"))
        XCTAssertNil(libraryManager.remoteMRAIDLibrary)
        XCTAssertNil(libraryManager.remoteOMSDKLibrary)
        XCTAssertFalse(libraryManager.getMRAIDLibrary()!.isEmpty)
        XCTAssertFalse(libraryManager.getOMSDKLibrary()!.isEmpty)
    }
    
    func testDiskSavingLoadingAndCache() {
        let fileName = "mraid.jslib"
        
        //saving file
        let jsLibrary = OXMJSLibrary()
        jsLibrary.contentsString = "test mraid"
        jsLibrary.version = "1.0.0"
        libraryManager.saveLibrary(withName: fileName, jsLibrary: jsLibrary)
        
        //loading saved file
        let loadedLibrary = libraryManager.getLibrayFromDisk(withFileName: fileName)
        XCTAssertNotNil(loadedLibrary)
        XCTAssertEqual(loadedLibrary.version, "1.0.0")
        XCTAssertEqual(loadedLibrary.contentsString, "test mraid")
        
        let cachedMRAIDString = libraryManager.getMRAIDLibrary()
        XCTAssertEqual(cachedMRAIDString, "test mraid")
    }
    
    func testLoadingFromBundle() {
        let fileNameMRAID = "mraid"
        let fileNameOMSDK = "omsdk"
        
        let mraidString = libraryManager.getLibraryContentsFromBundle(withName: fileNameMRAID)
        XCTAssertFalse(mraidString.isEmpty)
        XCTAssertTrue(mraidString.hasSuffix("mraid.js\");\r\n"))
        
        let omsdkString = libraryManager.getLibraryContentsFromBundle(withName: fileNameOMSDK)
        XCTAssertFalse(omsdkString.isEmpty)
        XCTAssertTrue(omsdkString.hasPrefix(";(function(omidGlobal)"))
    }
    
    func testUpdateMRAIDFromServer() {
        let expectationFailToLoad = expectation(description: "expectationFailToLoad")
        expectationFailToLoad.isInverted = true
        let expectationLoadLibrary = expectation(description: "expectationDownloadLibrary")
        let jsFileURL = "http://mockserver.com/mraid.js"
        let localJSFileName = "mraid.js"
        
        let rule = MockServerRule(urlNeedle: jsFileURL, mimeType: MockServerMimeType.JS.rawValue, connectionID: connection.internalID, fileName: localJSFileName)
        rule.mockServerReceivedRequestHandler = { (urlRequest: URLRequest) in
            expectationFailToLoad.fulfill()
        }
        MockServer.singleton().resetRules([rule])

        //should fail to load (no remoteLibrary)
        libraryManager.updateJSLibrariesIfNeeded(withConnection: connection)
        
        let remoteJSLibrary = OXMJSLibrary()
        remoteJSLibrary.downloadURL = URL(string: jsFileURL)!
        remoteJSLibrary.version = "1.0"
        libraryManager.remoteMRAIDLibrary = remoteJSLibrary

        //should fail to load (remote version is less than hardcoded version)
        libraryManager.updateJSLibrariesIfNeeded(withConnection: connection)
        
        rule.mockServerReceivedRequestHandler = { (urlRequest: URLRequest) in
            expectationLoadLibrary.fulfill()
        }
        MockServer.singleton().resetRules([rule])

        remoteJSLibrary.version = "3.1"
        libraryManager.remoteMRAIDLibrary = remoteJSLibrary
        
        //should load
        libraryManager.updateJSLibrariesIfNeeded(withConnection: connection)
        
        waitForExpectations(timeout: 2)
    }
    
    func testUpdateOMSDKFromServer() {
        let expectationFailToLoad = expectation(description: "expectationFailToLoad")
        expectationFailToLoad.isInverted = true
        let expectationLoadLibrary = expectation(description: "expectationDownloadLibrary")
        let jsFileURL = "http://mockserver.com/omsdk.js"
        let localJSFileName = "omsdk.js"
        
        let rule = MockServerRule(urlNeedle: jsFileURL, mimeType: MockServerMimeType.JS.rawValue, connectionID: connection.internalID, fileName: localJSFileName)
        rule.mockServerReceivedRequestHandler = { (urlRequest: URLRequest) in
            expectationFailToLoad.fulfill()
        }
        MockServer.singleton().resetRules([rule])
        
        //should fail to load (no remoteLibrary)
        libraryManager.updateJSLibrariesIfNeeded(withConnection: connection)
        
        let remoteJSLibrary = OXMJSLibrary()
        remoteJSLibrary.downloadURL = URL(string: jsFileURL)!
        remoteJSLibrary.version = "0.9.2"
        libraryManager.remoteOMSDKLibrary = remoteJSLibrary
        
        //should fail to load (remote version is less than hardcoded version)
        libraryManager.updateJSLibrariesIfNeeded(withConnection: connection)
        
        rule.mockServerReceivedRequestHandler = { (urlRequest: URLRequest) in
            expectationLoadLibrary.fulfill()
        }
        MockServer.singleton().resetRules([rule])
        
        remoteJSLibrary.version = "3.1.1"
        libraryManager.remoteOMSDKLibrary = remoteJSLibrary
        
        //should load
        libraryManager.updateJSLibrariesIfNeeded(withConnection: connection)
        
        waitForExpectations(timeout: 2)
    }
}
