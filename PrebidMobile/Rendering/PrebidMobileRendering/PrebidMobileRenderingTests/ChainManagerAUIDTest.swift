//
//  ChainManagerAUIDTest.swift
//  OpenXSDKCore
//
//  Copyright © 2017 OpenX. All rights reserved.
//
import XCTest

@testable import OpenXSDKCore

/*
 Tests are broken up into different subclass classes so that each would have its own delegates called.
 */

class ChainManagerAUIDTestCaseBase: XCTestCase {
    weak var expectation:XCTestExpectation?
    
    func initAdConfigRequest() -> AdConfiguration {
        let adConfiguration = AdConfiguration()
        adConfiguration.auid = "12345"
        adConfiguration.domain = "mocked.server.connection"
        return adConfiguration
    }
    
    /*
    Initialize the Server connection with a Mock.
     */
    func initServerConnection() -> PBMServerConnection { 
        MockServer.singleton().reset()
        let rule = MockServerRule(urlNeedle: "mockserver.com", mimeType: MockServerMimeType.JSON.rawValue, fileName: "ACJSingleAdWithoutSDKParams.json")
        MockServer.singleton().add(rule)
        
        let ret = PBMServerConnection()
        ret.protocolClasses.add(MockServerURLProtocol.self)
        
        return ret
    }
}

class ChainManagerAUIDTestCreativesLoaded: ChainManagerAUIDTestCaseBase, PBMChainManagerDelegate {

    /*
     Test for success.  If the creativeLoaded() delegate is called, then the test succeeds.
     if the creativesFailedToLoad() delegate is called then the test fails.
     */
    func testChainManagerAUIDCreativesLoaded() {

        self.expectation = self.expectation(description: "Expected a delegate function to fire")
        
        let adConfiguration = AdConfiguration()
        adConfiguration.oxmAdUnitIdentifierType = .auid
        adConfiguration.domain = "mockserver.com"
        adConfiguration.auid = "12345"
        
        let chainManager = PBMChainManager(oxmServerConnection:self.initServerConnection(), modalManager:PBMModalManager())
        
        chainManager.chainManagerDelegate = self
        
        chainManager.loadAdChain(adConfiguration)
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func chainManagerLoaded(creative:PBMAbstractCreative, chainInfo:PBMChainInfo?) {
        expectation?.fulfill()
    }
    
    func chainManagerFailedToLoad(error:Error) {
        XCTFail("Error: \(error)")
        expectation!.fulfill()
    }
    
}


class ChainManagerAUIDTestCreative_NoDomain_Error: ChainManagerAUIDTestCaseBase, PBMChainManagerDelegate {
    /*
     This test verifies that the PBMChainManager generates an error if NO Domain is defined before calling loadAdChain().
     If the creativesLoaded() delegate is called then the PBMChainManager did not generated the expected error.
     if the creativesFailedToLoad() delegate is called then the PBMChainManager generated the expected error.
    */
    func testChainManagerAUIDCreative_NoDomain_Error() {
        
        self.expectation = self.expectation(description: "Expected a delegate function to fire")
        
        let adConfiguration = AdConfiguration()
        adConfiguration.auid = "12345"

        let chainManager = PBMChainManager(oxmServerConnection:self.initServerConnection(), modalManager:PBMModalManager())
        chainManager.chainManagerDelegate = self
        chainManager.loadAdChain(adConfiguration)
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func chainManagerLoaded(creative:PBMAbstractCreative, chainInfo:PBMChainInfo?) {
        // should not succeed.
        XCTFail("Failed")
        expectation?.fulfill()
    }
    
    func chainManagerFailedToLoad(error:Error) {
        // test should correctly generate a failure.
        expectation!.fulfill()
    }
    
}
    
class ChainManagerAUIDTestCreative_NoAUID_Error: ChainManagerAUIDTestCaseBase, PBMChainManagerDelegate {
    /*
     This test verifies the error handling when NO AUID is assiged.
     If the creativesLoaded() delegate is called then the expected error has not been generated.
     If the creativeFailedToLoad() delegate is called then the expected error has been generated.
     */

    func testChainManagerAUIDCreative_NoAUID_Error() {
        
        self.expectation = self.expectation(description: "Expected a delegate function to fire")
        
        let adConfiguration = AdConfiguration()
        adConfiguration.domain = "fake_domain"
        
        let oxmServerConnection = self.initServerConnection()
        
        let chainManager = PBMChainManager(oxmServerConnection:oxmServerConnection, modalManager:PBMModalManager())
        chainManager.chainManagerDelegate = self
        
        chainManager.loadAdChain(adConfiguration)
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func chainManagerLoaded(creative:PBMAbstractCreative, chainInfo:PBMChainInfo?) {
        // should not succeed.
        XCTFail("Failed")
        expectation?.fulfill()
    }
    
    func chainManagerFailedToLoad(error:Error) {
        expectation?.fulfill()
    }
}
