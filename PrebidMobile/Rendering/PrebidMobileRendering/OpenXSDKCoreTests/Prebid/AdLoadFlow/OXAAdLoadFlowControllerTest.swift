//
//  OXAAdLoadFlowControllerTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation
import XCTest

@testable import PrebidMobileRendering

class OXAAdLoadFlowControllerTest: XCTestCase {
    private typealias CompositeMock = OXAAdLoadFlowControllerTest_CompositeMock
    
    func testNoImmediateCalls() {
        let compositeMock = CompositeMock(expectedCalls: [])
        let flowController = OXAAdLoadFlowController(bidRequesterFactory: compositeMock.mockRequesterFactory,
                                                     adLoader: compositeMock.mockAdLoader,
                                                     delegate: compositeMock.mockFlowControllerDelegate,
                                                     configValidationBlock: compositeMock.mockConfigValidator)
        let timeExp = expectation(description: "no event")
        timeExp.isInverted = true
        waitForExpectations(timeout: 1)
        XCTAssertEqual(flowController.flowState, .idle)
        compositeMock.checkIsFinished()
        XCTAssertFalse(flowController.hasFailedLoading)
    }
    
    func testPrimaryAd_happyPath_fromIdle() {
        testPrimaryAd_happyPath(preFailed: false)
    }
    
    func testPrimaryAd_happyPath_fromFailed() {
        testPrimaryAd_happyPath(preFailed: true)
    }
    
    func testPrimaryAd_happyPath(preFailed: Bool) {
        let adUnitConfig = OXAAdUnitConfig(configId: "configID")
        
        let flowControllerBox = NSMutableArray()
        let flowController: ()->OXAAdLoadFlowController = { flowControllerBox[0] as! OXAAdLoadFlowController }
        
        let fakeAdBox = NSMutableArray()
        let fakeAd: ()->NSObject? = { (fakeAdBox.count > 0) ? (fakeAdBox[0] as! NSObject) : nil }
        let fakeAdSizeBox = NSMutableArray()
        let fakeAdSize: ()->NSValue? = { (fakeAdSizeBox.count > 0) ? (fakeAdSizeBox[0] as! NSValue) : nil }
        
        let compositeMockBox = NSMutableArray()
        let compositeMock: ()->CompositeMock = { compositeMockBox[0] as! CompositeMock }
        
        let successReported = expectation(description: "success reported")
        
        compositeMockBox[0] = CompositeMock(expectedCalls: [
            .flowControllerDelegate(call: .adUnitConfig(provider: { adUnitConfig })),
            .configValidation(call: { (adConfig, renderWithApollo) in
                XCTAssertFalse(renderWithApollo)
                return true
            }),
            .flowControllerDelegate(call: .willSendBidRequest(handler: { loader in
                XCTAssertEqual(loader, flowController())
            })),
            .makeBidRequester(handler: { config, mockRequester in mockRequester }),
            .bidRequester(call: (requesterOffset: 0, { completion in
                let bidResponse = try! OXABidResponseTransformer.transform(OXABidResponseTransformer.someValidResponse)
                completion(bidResponse, nil)
            })),
            .flowControllerDelegate(call: .shouldContinue(handler: { loader in
                XCTAssertEqual(loader, flowController())
                return true
            })),
            .flowControllerDelegate(call: .willRequestPrimaryAd(handler: { loader in
                XCTAssertEqual(loader, flowController())
            })),
            .adLoader(call: .setFlowDelegate(handler: { delegate in
                XCTAssertEqual(delegate as? NSObject, flowController())
            })),
            .adLoader(call: .primaryAdRequester(provider: { compositeMock().mockPrimaryAdRequester })),
            .primaryAdRequester(call: { bidResponse in
                fakeAdBox[0] = NSObject()
                fakeAdSizeBox[0] = NSValue(cgSize: CGSize(width: 320, height: 480))
                flowController().adLoader(compositeMock().mockAdLoader,
                                          loadedPrimaryAd: fakeAd() as Any,
                                          adSize: fakeAdSize())
            }),
            .flowControllerDelegate(call: .shouldContinue(handler: { loader in
                XCTAssertEqual(loader, flowController())
                return true
            })),
            .adLoader(call: .reportSuccess(handler: { (ad, size) in
                XCTAssertEqual(ad as? NSObject, fakeAd())
                XCTAssertEqual(size, fakeAdSize())
                successReported.fulfill()
            })),
        ])
        
        flowControllerBox[0] = OXAAdLoadFlowController(bidRequesterFactory: compositeMock().mockRequesterFactory,
                                                       adLoader: compositeMock().mockAdLoader,
                                                       delegate: compositeMock().mockFlowControllerDelegate,
                                                       configValidationBlock: compositeMock().mockConfigValidator)
        
        if (preFailed) {
            flowController().flowState = .loadingFailed
        }
        
        flowController().refresh()
        waitForExpectations(timeout: 1)
        
        XCTAssertFalse(flowController().hasFailedLoading)
        XCTAssertEqual(flowController().flowState, .idle)
        compositeMock().checkIsFinished()
    }
    
    func testApolloAd_happyPath_fromIdle() {
        testApolloAd_happyPath(preFailed: false)
    }
    
    func testApolloAd_happyPath_fromFailed() {
        testApolloAd_happyPath(preFailed: true)
    }
    
    func testApolloAd_happyPath(preFailed: Bool) {
        let adUnitConfig = OXAAdUnitConfig(configId: "configID")
        
        let flowControllerBox = NSMutableArray()
        let flowController: ()->OXAAdLoadFlowController = { flowControllerBox[0] as! OXAAdLoadFlowController }
        
        let fakeAdBox = NSMutableArray()
        let fakeAd: ()->NSObject? = { (fakeAdBox.count > 0) ? (fakeAdBox[0] as! NSObject) : nil }
        let fakeAdSizeBox = NSMutableArray()
        let fakeAdSize: ()->NSValue? = { (fakeAdSizeBox.count > 0) ? (fakeAdSizeBox[0] as! NSValue) : nil }
        
        let compositeMockBox = NSMutableArray()
        let compositeMock: ()->CompositeMock = { compositeMockBox[0] as! CompositeMock }
        
        let successReported = expectation(description: "success reported")
        
        compositeMockBox[0] = CompositeMock(expectedCalls: [
            .flowControllerDelegate(call: .adUnitConfig(provider: { adUnitConfig })),
            .configValidation(call: { (adConfig, renderWithApollo) in
                XCTAssertFalse(renderWithApollo)
                return true
            }),
            .flowControllerDelegate(call: .willSendBidRequest(handler: { loader in
                XCTAssertEqual(loader, flowController())
            })),
            .makeBidRequester(handler: { config, mockRequester in mockRequester }),
            .bidRequester(call: (requesterOffset: 0, { completion in
                let bidResponse = try! OXABidResponseTransformer.transform(OXABidResponseTransformer.someValidResponse)
                completion(bidResponse, nil)
            })),
            .flowControllerDelegate(call: .shouldContinue(handler: { loader in
                XCTAssertEqual(loader, flowController())
                return true
            })),
            .flowControllerDelegate(call: .willRequestPrimaryAd(handler: { loader in
                XCTAssertEqual(loader, flowController())
            })),
            .adLoader(call: .setFlowDelegate(handler: { delegate in
                XCTAssertEqual(delegate as? NSObject, flowController())
            })),
            .adLoader(call: .primaryAdRequester(provider: { compositeMock().mockPrimaryAdRequester })),
            .primaryAdRequester(call: { bidResponse in
                flowController().adLoaderDidWinApollo(compositeMock().mockAdLoader)
            }),
            .configValidation(call: { (adConfig, renderWithApollo) in
                XCTAssertTrue(renderWithApollo)
                return true
            }),
            .adLoader(call: .createApolloAd(handler: { (bid, config, adSaver, adLoadHandler) in
                fakeAdBox[0] = NSObject()
                adSaver(fakeAd() as Any)
                adLoadHandler {
                    fakeAdSizeBox[0] = NSValue(cgSize: bid.size)
                    flowController().adLoaderLoadedApolloAd(compositeMock().mockAdLoader)
                }
            })),
            .flowControllerDelegate(call: .shouldContinue(handler: { loader in
                XCTAssertEqual(loader, flowController())
                return true
            })),
            .adLoader(call: .reportSuccess(handler: { (ad, size) in
                XCTAssertEqual(ad as? NSObject, fakeAd())
                XCTAssertEqual(size, fakeAdSize())
                successReported.fulfill()
            })),
        ])
        
        flowControllerBox[0] = OXAAdLoadFlowController(bidRequesterFactory: compositeMock().mockRequesterFactory,
                                                       adLoader: compositeMock().mockAdLoader,
                                                       delegate: compositeMock().mockFlowControllerDelegate,
                                                       configValidationBlock: compositeMock().mockConfigValidator)
        
        if (preFailed) {
            flowController().flowState = .loadingFailed
        }
        
        flowController().refresh()
        waitForExpectations(timeout: 1)
        
        XCTAssertFalse(flowController().hasFailedLoading)
        XCTAssertEqual(flowController().flowState, .idle)
        compositeMock().checkIsFinished()
    }
    
    func testPrimaryAd_noBids() {
        let adUnitConfig = OXAAdUnitConfig(configId: "configID")
        
        let flowControllerBox = NSMutableArray()
        let flowController: ()->OXAAdLoadFlowController = { flowControllerBox[0] as! OXAAdLoadFlowController }
        
        let fakeAdBox = NSMutableArray()
        let fakeAd: ()->NSObject? = { (fakeAdBox.count > 0) ? (fakeAdBox[0] as! NSObject) : nil }
        let fakeAdSizeBox = NSMutableArray()
        let fakeAdSize: ()->NSValue? = { (fakeAdSizeBox.count > 0) ? (fakeAdSizeBox[0] as! NSValue) : nil }
        
        let compositeMockBox = NSMutableArray()
        let compositeMock: ()->CompositeMock = { compositeMockBox[0] as! CompositeMock }
        
        let successReported = expectation(description: "success reported")
        
        compositeMockBox[0] = CompositeMock(expectedCalls: [
            .flowControllerDelegate(call: .adUnitConfig(provider: { adUnitConfig })),
            .configValidation(call: { (adConfig, renderWithApollo) in
                XCTAssertFalse(renderWithApollo)
                return true
            }),
            .flowControllerDelegate(call: .willSendBidRequest(handler: { loader in
                XCTAssertEqual(loader, flowController())
            })),
            .makeBidRequester(handler: { config, mockRequester in mockRequester }),
            .bidRequester(call: (requesterOffset: 0, { completion in
                let rawResponse = OXABidResponseTransformer.invalidAccountIDResponse(accountID: "some id")
                var bidResponse: OXABidResponse?
                do {
                    bidResponse = try OXABidResponseTransformer.transform(rawResponse)
                } catch {
                    completion(nil, error)
                    return
                }
                completion(bidResponse, nil)
            })),
            .flowControllerDelegate(call: .shouldContinue(handler: { loader in
                XCTAssertEqual(loader, flowController())
                return true
            })),
            .flowControllerDelegate(call: .willRequestPrimaryAd(handler: { loader in
                XCTAssertEqual(loader, flowController())
            })),
            .adLoader(call: .setFlowDelegate(handler: { delegate in
                XCTAssertEqual(delegate as? NSObject, flowController())
            })),
            .adLoader(call: .primaryAdRequester(provider: { compositeMock().mockPrimaryAdRequester })),
            .primaryAdRequester(call: { bidResponse in
                fakeAdBox[0] = NSObject()
                fakeAdSizeBox[0] = NSValue(cgSize: CGSize(width: 320, height: 480))
                flowController().adLoader(compositeMock().mockAdLoader,
                                          loadedPrimaryAd: fakeAd() as Any,
                                          adSize: fakeAdSize())
            }),
            .flowControllerDelegate(call: .shouldContinue(handler: { loader in
                XCTAssertEqual(loader, flowController())
                return true
            })),
            .adLoader(call: .reportSuccess(handler: { (ad, size) in
                XCTAssertEqual(ad as? NSObject, fakeAd())
                XCTAssertEqual(size, fakeAdSize())
                successReported.fulfill()
            })),
        ])
        
        flowControllerBox[0] = OXAAdLoadFlowController(bidRequesterFactory: compositeMock().mockRequesterFactory,
                                                       adLoader: compositeMock().mockAdLoader,
                                                       delegate: compositeMock().mockFlowControllerDelegate,
                                                       configValidationBlock: compositeMock().mockConfigValidator)
        
        flowController().refresh()
        waitForExpectations(timeout: 1)
        
        XCTAssertFalse(flowController().hasFailedLoading)
        XCTAssertEqual(flowController().flowState, .idle)
        compositeMock().checkIsFinished()
    }
    
    func testPrimaryAd_noBids_noPrimaryAd() {
        let adUnitConfig = OXAAdUnitConfig(configId: "configID")
        
        let flowControllerBox = NSMutableArray()
        let flowController: ()->OXAAdLoadFlowController = { flowControllerBox[0] as! OXAAdLoadFlowController }
        
        let fakeErrorBox = NSMutableArray()
        let fakeError: ()->Error? = { (fakeErrorBox.count > 0) ? (fakeErrorBox[0] as! Error) : nil }
        
        let compositeMockBox = NSMutableArray()
        let compositeMock: ()->CompositeMock = { compositeMockBox[0] as! CompositeMock }
        
        let failureReported = expectation(description: "failure reported")
        
        compositeMockBox[0] = CompositeMock(expectedCalls: [
            .flowControllerDelegate(call: .adUnitConfig(provider: { adUnitConfig })),
            .configValidation(call: { (adConfig, renderWithApollo) in
                XCTAssertFalse(renderWithApollo)
                return true
            }),
            .flowControllerDelegate(call: .willSendBidRequest(handler: { loader in
                XCTAssertEqual(loader, flowController())
            })),
            .makeBidRequester(handler: { config, mockRequester in mockRequester }),
            .bidRequester(call: (requesterOffset: 0, { completion in
                let rawResponse = OXABidResponseTransformer.invalidAccountIDResponse(accountID: "some id")
                var bidResponse: OXABidResponse?
                do {
                    bidResponse = try OXABidResponseTransformer.transform(rawResponse)
                } catch {
                    fakeErrorBox[0] = error
                    completion(nil, error)
                    return
                }
                completion(bidResponse, nil)
            })),
            .flowControllerDelegate(call: .shouldContinue(handler: { loader in
                XCTAssertEqual(loader, flowController())
                return true
            })),
            .flowControllerDelegate(call: .willRequestPrimaryAd(handler: { loader in
                XCTAssertEqual(loader, flowController())
            })),
            .adLoader(call: .setFlowDelegate(handler: { delegate in
                XCTAssertEqual(delegate as? NSObject, flowController())
            })),
            .adLoader(call: .primaryAdRequester(provider: { compositeMock().mockPrimaryAdRequester })),
            .primaryAdRequester(call: { bidResponse in
                flowController().adLoaderDidWinApollo(compositeMock().mockAdLoader)
            }),
            .flowControllerDelegate(call: .failedWithError(handler: { (loader, error) in
                XCTAssertEqual(loader, flowController())
                XCTAssertEqual(error as NSError?, fakeError() as NSError?)
                failureReported.fulfill()
            })),
        ])
        
        flowControllerBox[0] = OXAAdLoadFlowController(bidRequesterFactory: compositeMock().mockRequesterFactory,
                                                       adLoader: compositeMock().mockAdLoader,
                                                       delegate: compositeMock().mockFlowControllerDelegate,
                                                       configValidationBlock: compositeMock().mockConfigValidator)
        
        flowController().refresh()
        waitForExpectations(timeout: 1)
        
        XCTAssertTrue(flowController().hasFailedLoading)
        XCTAssertEqual(flowController().flowState, .loadingFailed)
        compositeMock().checkIsFinished()
    }
    
    func testApolloAd_didFail() {
        let adUnitConfig = OXAAdUnitConfig(configId: "configID")
        
        let flowControllerBox = NSMutableArray()
        let flowController: ()->OXAAdLoadFlowController = { flowControllerBox[0] as! OXAAdLoadFlowController }
        
        let fakeErrorBox = NSMutableArray()
        let fakeError: ()->Error? = { (fakeErrorBox.count > 0) ? (fakeErrorBox[0] as! Error) : nil }
        
        let compositeMockBox = NSMutableArray()
        let compositeMock: ()->CompositeMock = { compositeMockBox[0] as! CompositeMock }
        
        let failureReported = expectation(description: "failure reported")
        
        compositeMockBox[0] = CompositeMock(expectedCalls: [
            .flowControllerDelegate(call: .adUnitConfig(provider: { adUnitConfig })),
            .configValidation(call: { (adConfig, renderWithApollo) in
                XCTAssertFalse(renderWithApollo)
                return true
            }),
            .flowControllerDelegate(call: .willSendBidRequest(handler: { loader in
                XCTAssertEqual(loader, flowController())
            })),
            .makeBidRequester(handler: { config, mockRequester in mockRequester }),
            .bidRequester(call: (requesterOffset: 0, { completion in
                let bidResponse = try! OXABidResponseTransformer.transform(OXABidResponseTransformer.someValidResponse)
                completion(bidResponse, nil)
            })),
            .flowControllerDelegate(call: .shouldContinue(handler: { loader in
                XCTAssertEqual(loader, flowController())
                return true
            })),
            .flowControllerDelegate(call: .willRequestPrimaryAd(handler: { loader in
                XCTAssertEqual(loader, flowController())
            })),
            .adLoader(call: .setFlowDelegate(handler: { delegate in
                XCTAssertEqual(delegate as? NSObject, flowController())
            })),
            .adLoader(call: .primaryAdRequester(provider: { compositeMock().mockPrimaryAdRequester })),
            .primaryAdRequester(call: { bidResponse in
                flowController().adLoaderDidWinApollo(compositeMock().mockAdLoader)
            }),
            .configValidation(call: { (adConfig, renderWithApollo) in
                XCTAssertTrue(renderWithApollo)
                return true
            }),
            .adLoader(call: .createApolloAd(handler: { (bid, config, adSaver, adLoadHandler) in
                adSaver(NSObject() as Any)
                adLoadHandler {
                    enum FakeApolloError: Error { case someError }
                    fakeErrorBox[0] = FakeApolloError.someError
                    flowController().adLoader(compositeMock().mockAdLoader, failedWithApolloError: fakeError())
                }
            })),
            .flowControllerDelegate(call: .failedWithError(handler: { (loader, error) in
                XCTAssertEqual(loader, flowController())
                XCTAssertEqual(error as NSError?, fakeError() as NSError?)
                failureReported.fulfill()
            })),
        ])
        
        flowControllerBox[0] = OXAAdLoadFlowController(bidRequesterFactory: compositeMock().mockRequesterFactory,
                                                       adLoader: compositeMock().mockAdLoader,
                                                       delegate: compositeMock().mockFlowControllerDelegate,
                                                       configValidationBlock: compositeMock().mockConfigValidator)
        
        flowController().refresh()
        waitForExpectations(timeout: 1)
        
        XCTAssertTrue(flowController().hasFailedLoading)
        XCTAssertEqual(flowController().flowState, .loadingFailed)
        compositeMock().checkIsFinished()
    }
    
    func testPrimaryAdFail_withBids_fallbackToApollo() {
        let adUnitConfig = OXAAdUnitConfig(configId: "configID")
        
        let flowControllerBox = NSMutableArray()
        let flowController: ()->OXAAdLoadFlowController = { flowControllerBox[0] as! OXAAdLoadFlowController }
        
        let fakeAdBox = NSMutableArray()
        let fakeAd: ()->NSObject? = { (fakeAdBox.count > 0) ? (fakeAdBox[0] as! NSObject) : nil }
        let fakeAdSizeBox = NSMutableArray()
        let fakeAdSize: ()->NSValue? = { (fakeAdSizeBox.count > 0) ? (fakeAdSizeBox[0] as! NSValue) : nil }
        
        let compositeMockBox = NSMutableArray()
        let compositeMock: ()->CompositeMock = { compositeMockBox[0] as! CompositeMock }
        
        let successReported = expectation(description: "success reported")
        
        compositeMockBox[0] = CompositeMock(expectedCalls: [
            .flowControllerDelegate(call: .adUnitConfig(provider: { adUnitConfig })),
            .configValidation(call: { (adConfig, renderWithApollo) in
                XCTAssertFalse(renderWithApollo)
                return true
            }),
            .flowControllerDelegate(call: .willSendBidRequest(handler: { loader in
                XCTAssertEqual(loader, flowController())
            })),
            .makeBidRequester(handler: { config, mockRequester in mockRequester }),
            .bidRequester(call: (requesterOffset: 0, { completion in
                let bidResponse = try! OXABidResponseTransformer.transform(OXABidResponseTransformer.someValidResponse)
                completion(bidResponse, nil)
            })),
            .flowControllerDelegate(call: .shouldContinue(handler: { loader in
                XCTAssertEqual(loader, flowController())
                return true
            })),
            .flowControllerDelegate(call: .willRequestPrimaryAd(handler: { loader in
                XCTAssertEqual(loader, flowController())
            })),
            .adLoader(call: .setFlowDelegate(handler: { delegate in
                XCTAssertEqual(delegate as? NSObject, flowController())
            })),
            .adLoader(call: .primaryAdRequester(provider: { compositeMock().mockPrimaryAdRequester })),
            .primaryAdRequester(call: { bidResponse in
                enum FakePrimarySDKError: Error { case someError }
                flowController().adLoader(compositeMock().mockAdLoader,
                                          failedWithPrimarySDKError: FakePrimarySDKError.someError)
            }),
            .configValidation(call: { (adConfig, renderWithApollo) in
                XCTAssertTrue(renderWithApollo)
                return true
            }),
            .adLoader(call: .createApolloAd(handler: { (bid, config, adSaver, adLoadHandler) in
                fakeAdBox[0] = NSObject()
                adSaver(fakeAd() as Any)
                adLoadHandler {
                    fakeAdSizeBox[0] = NSValue(cgSize: bid.size)
                    flowController().adLoaderLoadedApolloAd(compositeMock().mockAdLoader)
                }
            })),
            .flowControllerDelegate(call: .shouldContinue(handler: { loader in
                XCTAssertEqual(loader, flowController())
                return true
            })),
            .adLoader(call: .reportSuccess(handler: { (ad, size) in
                XCTAssertEqual(ad as? NSObject, fakeAd())
                XCTAssertEqual(size, fakeAdSize())
                successReported.fulfill()
            })),
        ])
        
        flowControllerBox[0] = OXAAdLoadFlowController(bidRequesterFactory: compositeMock().mockRequesterFactory,
                                                       adLoader: compositeMock().mockAdLoader,
                                                       delegate: compositeMock().mockFlowControllerDelegate,
                                                       configValidationBlock: compositeMock().mockConfigValidator)
        
        flowController().refresh()
        waitForExpectations(timeout: 1)
        
        XCTAssertFalse(flowController().hasFailedLoading)
        XCTAssertEqual(flowController().flowState, .idle)
        compositeMock().checkIsFinished()
    }
    
    func testPrimaryAd_noBids_primarySDKError() {
        let adUnitConfig = OXAAdUnitConfig(configId: "configID")
        
        let flowControllerBox = NSMutableArray()
        let flowController: ()->OXAAdLoadFlowController = { flowControllerBox[0] as! OXAAdLoadFlowController }
        
        let fakePrebidErrorBox = NSMutableArray()
        //let fakePrebidError: ()->Error? = { (fakePrebidErrorBox.count > 0) ? (fakePrebidErrorBox[0] as! Error) : nil }
        let fakeSDKErrorBox = NSMutableArray()
        let fakeSDKError: ()->Error? = { (fakeSDKErrorBox.count > 0) ? (fakeSDKErrorBox[0] as! Error) : nil }
        
        let compositeMockBox = NSMutableArray()
        let compositeMock: ()->CompositeMock = { compositeMockBox[0] as! CompositeMock }
        
        let failureReported = expectation(description: "failure reported")
        
        compositeMockBox[0] = CompositeMock(expectedCalls: [
            .flowControllerDelegate(call: .adUnitConfig(provider: { adUnitConfig })),
            .configValidation(call: { (adConfig, renderWithApollo) in
                XCTAssertFalse(renderWithApollo)
                return true
            }),
            .flowControllerDelegate(call: .willSendBidRequest(handler: { loader in
                XCTAssertEqual(loader, flowController())
            })),
            .makeBidRequester(handler: { config, mockRequester in mockRequester }),
            .bidRequester(call: (requesterOffset: 0, { completion in
                let rawResponse = OXABidResponseTransformer.invalidAccountIDResponse(accountID: "some id")
                var bidResponse: OXABidResponse?
                do {
                    bidResponse = try OXABidResponseTransformer.transform(rawResponse)
                } catch {
                    fakePrebidErrorBox[0] = error
                    completion(nil, error)
                    return
                }
                completion(bidResponse, nil)
            })),
            .flowControllerDelegate(call: .shouldContinue(handler: { loader in
                XCTAssertEqual(loader, flowController())
                return true
            })),
            .flowControllerDelegate(call: .willRequestPrimaryAd(handler: { loader in
                XCTAssertEqual(loader, flowController())
            })),
            .adLoader(call: .setFlowDelegate(handler: { delegate in
                XCTAssertEqual(delegate as? NSObject, flowController())
            })),
            .adLoader(call: .primaryAdRequester(provider: { compositeMock().mockPrimaryAdRequester })),
            .primaryAdRequester(call: { bidResponse in
                enum FakePrimarySDKError: Error { case someError }
                fakeSDKErrorBox[0] = FakePrimarySDKError.someError
                flowController().adLoader(compositeMock().mockAdLoader,
                                          failedWithPrimarySDKError: fakeSDKError() as NSError?)
            }),
            .flowControllerDelegate(call: .failedWithError(handler: { (loader, error) in
                XCTAssertEqual(loader, flowController())
                XCTAssertEqual(error as NSError?, fakeSDKError() as NSError?)
                failureReported.fulfill()
            })),
        ])
        
        flowControllerBox[0] = OXAAdLoadFlowController(bidRequesterFactory: compositeMock().mockRequesterFactory,
                                                       adLoader: compositeMock().mockAdLoader,
                                                       delegate: compositeMock().mockFlowControllerDelegate,
                                                       configValidationBlock: compositeMock().mockConfigValidator)
        
        flowController().refresh()
        waitForExpectations(timeout: 1)
        
        XCTAssertTrue(flowController().hasFailedLoading)
        XCTAssertEqual(flowController().flowState, .loadingFailed)
        compositeMock().checkIsFinished()
    }
    
    func testConfigInvalid_forEventHandler() {
        let adUnitConfig = OXAAdUnitConfig(configId: "configID")
        
        let flowControllerBox = NSMutableArray()
        let flowController: ()->OXAAdLoadFlowController = { flowControllerBox[0] as! OXAAdLoadFlowController }
        
        let compositeMockBox = NSMutableArray()
        let compositeMock: ()->CompositeMock = { compositeMockBox[0] as! CompositeMock }
        
        let failureReported = expectation(description: "failure reported")
        
        compositeMockBox[0] = CompositeMock(expectedCalls: [
            .flowControllerDelegate(call: .adUnitConfig(provider: { adUnitConfig })),
            .configValidation(call: { (adConfig, renderWithApollo) in
                XCTAssertFalse(renderWithApollo)
                return false
            }),
            .flowControllerDelegate(call: .failedWithError(handler: { (loader, error) in
                XCTAssertEqual(loader, flowController())
                XCTAssertEqual(error as NSError?, OXAError.noNativeCreative as NSError)
                failureReported.fulfill()
            })),
        ])
        
        flowControllerBox[0] = OXAAdLoadFlowController(bidRequesterFactory: compositeMock().mockRequesterFactory,
                                                       adLoader: compositeMock().mockAdLoader,
                                                       delegate: compositeMock().mockFlowControllerDelegate,
                                                       configValidationBlock: compositeMock().mockConfigValidator)
        
        flowController().refresh()
        waitForExpectations(timeout: 1)
        
        XCTAssertTrue(flowController().hasFailedLoading)
        XCTAssertEqual(flowController().flowState, .loadingFailed)
        compositeMock().checkIsFinished()
    }
    
    func testConfigInvalid_forApollo() {
        let adUnitConfig = OXAAdUnitConfig(configId: "configID")
        
        let flowControllerBox = NSMutableArray()
        let flowController: ()->OXAAdLoadFlowController = { flowControllerBox[0] as! OXAAdLoadFlowController }
        
        let compositeMockBox = NSMutableArray()
        let compositeMock: ()->CompositeMock = { compositeMockBox[0] as! CompositeMock }
        
        let failureReported = expectation(description: "failure reported")
        
        compositeMockBox[0] = CompositeMock(expectedCalls: [
            .flowControllerDelegate(call: .adUnitConfig(provider: { adUnitConfig })),
            .configValidation(call: { (adConfig, renderWithApollo) in
                XCTAssertFalse(renderWithApollo)
                return true
            }),
            .flowControllerDelegate(call: .willSendBidRequest(handler: { loader in
                XCTAssertEqual(loader, flowController())
            })),
            .makeBidRequester(handler: { config, mockRequester in mockRequester }),
            .bidRequester(call: (requesterOffset: 0, { completion in
                let bidResponse = try! OXABidResponseTransformer.transform(OXABidResponseTransformer.someValidResponse)
                completion(bidResponse, nil)
            })),
            .flowControllerDelegate(call: .shouldContinue(handler: { loader in
                XCTAssertEqual(loader, flowController())
                return true
            })),
            .flowControllerDelegate(call: .willRequestPrimaryAd(handler: { loader in
                XCTAssertEqual(loader, flowController())
            })),
            .adLoader(call: .setFlowDelegate(handler: { delegate in
                XCTAssertEqual(delegate as? NSObject, flowController())
            })),
            .adLoader(call: .primaryAdRequester(provider: { compositeMock().mockPrimaryAdRequester })),
            .primaryAdRequester(call: { bidResponse in
                flowController().adLoaderDidWinApollo(compositeMock().mockAdLoader)
            }),
            .configValidation(call: { (adConfig, renderWithApollo) in
                XCTAssertTrue(renderWithApollo)
                return false
            }),
            .flowControllerDelegate(call: .failedWithError(handler: { (loader, error) in
                XCTAssertEqual(loader, flowController())
                XCTAssertEqual(error as NSError?, OXAError.noNativeCreative as NSError)
                failureReported.fulfill()
            })),
        ])
        
        flowControllerBox[0] = OXAAdLoadFlowController(bidRequesterFactory: compositeMock().mockRequesterFactory,
                                                       adLoader: compositeMock().mockAdLoader,
                                                       delegate: compositeMock().mockFlowControllerDelegate,
                                                       configValidationBlock: compositeMock().mockConfigValidator)
        
        flowController().refresh()
        waitForExpectations(timeout: 1)
        
        XCTAssertTrue(flowController().hasFailedLoading)
        XCTAssertEqual(flowController().flowState, .loadingFailed)
        compositeMock().checkIsFinished()
    }
    
    func testApolloWin_noWinningBidInBidResponse() {
        let adUnitConfig = OXAAdUnitConfig(configId: "configID")
        
        let flowControllerBox = NSMutableArray()
        let flowController: ()->OXAAdLoadFlowController = { flowControllerBox[0] as! OXAAdLoadFlowController }
        
        let compositeMockBox = NSMutableArray()
        let compositeMock: ()->CompositeMock = { compositeMockBox[0] as! CompositeMock }
        
        let failureReported = expectation(description: "failure reported")
        
        compositeMockBox[0] = CompositeMock(expectedCalls: [
            .flowControllerDelegate(call: .adUnitConfig(provider: { adUnitConfig })),
            .configValidation(call: { (adConfig, renderWithApollo) in
                XCTAssertFalse(renderWithApollo)
                return true
            }),
            .flowControllerDelegate(call: .willSendBidRequest(handler: { loader in
                XCTAssertEqual(loader, flowController())
            })),
            .makeBidRequester(handler: { config, mockRequester in mockRequester }),
            .bidRequester(call: (requesterOffset: 0, { completion in
                let bidResponse = try! OXABidResponseTransformer.transform(OXABidResponseTransformer
                                                                            .noWinningBidResponse)
                completion(bidResponse, nil)
            })),
            .flowControllerDelegate(call: .shouldContinue(handler: { loader in
                XCTAssertEqual(loader, flowController())
                return true
            })),
            .flowControllerDelegate(call: .willRequestPrimaryAd(handler: { loader in
                XCTAssertEqual(loader, flowController())
            })),
            .adLoader(call: .setFlowDelegate(handler: { delegate in
                XCTAssertEqual(delegate as? NSObject, flowController())
            })),
            .adLoader(call: .primaryAdRequester(provider: { compositeMock().mockPrimaryAdRequester })),
            .primaryAdRequester(call: { bidResponse in
                flowController().adLoaderDidWinApollo(compositeMock().mockAdLoader)
            }),
            .configValidation(call: { (adConfig, renderWithApollo) in
                XCTAssertTrue(renderWithApollo)
                return true
            }),
            .flowControllerDelegate(call: .failedWithError(handler: { (loader, error) in
                XCTAssertEqual(loader, flowController())
                XCTAssertEqual(error as NSError?, OXAError.noWinningBid as NSError)
                failureReported.fulfill()
            })),
        ])
        
        flowControllerBox[0] = OXAAdLoadFlowController(bidRequesterFactory: compositeMock().mockRequesterFactory,
                                                       adLoader: compositeMock().mockAdLoader,
                                                       delegate: compositeMock().mockFlowControllerDelegate,
                                                       configValidationBlock: compositeMock().mockConfigValidator)
        
        flowController().refresh()
        waitForExpectations(timeout: 1)
        
        XCTAssertTrue(flowController().hasFailedLoading)
        XCTAssertEqual(flowController().flowState, .loadingFailed)
        compositeMock().checkIsFinished()
    }
    
    func testApolloAd_happyPath_spamRefresh() {
        let adUnitConfig = OXAAdUnitConfig(configId: "configID")
        
        let flowControllerBox = NSMutableArray()
        let flowController: ()->OXAAdLoadFlowController = { flowControllerBox[0] as! OXAAdLoadFlowController }
        
        let fakeAdBox = NSMutableArray()
        let fakeAd: ()->NSObject? = { (fakeAdBox.count > 0) ? (fakeAdBox[0] as! NSObject) : nil }
        let fakeAdSizeBox = NSMutableArray()
        let fakeAdSize: ()->NSValue? = { (fakeAdSizeBox.count > 0) ? (fakeAdSizeBox[0] as! NSValue) : nil }
        
        let compositeMockBox = NSMutableArray()
        let compositeMock: ()->CompositeMock = { compositeMockBox[0] as! CompositeMock }
        
        let successReported = expectation(description: "success reported")
        
        compositeMockBox[0] = CompositeMock(expectedCalls: [
            .flowControllerDelegate(call: .adUnitConfig(provider: {
                flowController().refresh()
                return adUnitConfig
            })),
            .configValidation(call: { (adConfig, renderWithApollo) in
                flowController().refresh()
                return true
            }),
            .flowControllerDelegate(call: .willSendBidRequest(handler: { loader in
                flowController().refresh()
            })),
            .makeBidRequester(handler: { config, mockRequester in mockRequester }),
            .bidRequester(call: (requesterOffset: 0, { completion in
                flowController().refresh()
                let bidResponse = try! OXABidResponseTransformer.transform(OXABidResponseTransformer.someValidResponse)
                completion(bidResponse, nil)
            })),
            .flowControllerDelegate(call: .shouldContinue(handler: { loader in
                return true
            })),
            .flowControllerDelegate(call: .willRequestPrimaryAd(handler: { loader in
                flowController().refresh()
            })),
            .adLoader(call: .setFlowDelegate(handler: { delegate in
                flowController().refresh()
            })),
            .adLoader(call: .primaryAdRequester(provider: {
                flowController().refresh()
                return compositeMock().mockPrimaryAdRequester
            })),
            .primaryAdRequester(call: { bidResponse in
                flowController().refresh()
                flowController().adLoaderDidWinApollo(compositeMock().mockAdLoader)
            }),
            .configValidation(call: { (adConfig, renderWithApollo) in
                flowController().refresh()
                return true
            }),
            .adLoader(call: .createApolloAd(handler: { (bid, config, adSaver, adLoadHandler) in
                flowController().refresh()
                fakeAdBox[0] = NSObject()
                adSaver(fakeAd() as Any)
                adLoadHandler {
                    fakeAdSizeBox[0] = NSValue(cgSize: bid.size)
                    flowController().adLoaderLoadedApolloAd(compositeMock().mockAdLoader)
                }
            })),
            .flowControllerDelegate(call: .shouldContinue(handler: { loader in
                return true
            })),
            .adLoader(call: .reportSuccess(handler: { (ad, size) in
                XCTAssertEqual(ad as? NSObject, fakeAd())
                XCTAssertEqual(size, fakeAdSize())
                successReported.fulfill()
            })),
        ])
        
        flowControllerBox[0] = OXAAdLoadFlowController(bidRequesterFactory: compositeMock().mockRequesterFactory,
                                                       adLoader: compositeMock().mockAdLoader,
                                                       delegate: compositeMock().mockFlowControllerDelegate,
                                                       configValidationBlock: compositeMock().mockConfigValidator)
        
        flowController().refresh()
        waitForExpectations(timeout: 1)
        
        XCTAssertFalse(flowController().hasFailedLoading)
        XCTAssertEqual(flowController().flowState, .idle)
        compositeMock().checkIsFinished()
    }
    
    func testApolloAd_happyPath_freezeOnShouldContinue() {
        let adUnitConfig = OXAAdUnitConfig(configId: "configID")
        
        let flowControllerBox = NSMutableArray()
        let flowController: ()->OXAAdLoadFlowController = { flowControllerBox[0] as! OXAAdLoadFlowController }
        
        let fakeAdBox = NSMutableArray()
        let fakeAd: ()->NSObject? = { (fakeAdBox.count > 0) ? (fakeAdBox[0] as! NSObject) : nil }
        let fakeAdSizeBox = NSMutableArray()
        let fakeAdSize: ()->NSValue? = { (fakeAdSizeBox.count > 0) ? (fakeAdSizeBox[0] as! NSValue) : nil }
        
        let compositeMockBox = NSMutableArray()
        let compositeMock: ()->CompositeMock = { compositeMockBox[0] as! CompositeMock }
        
        let nextShouldContinueExpectationBox = NSMutableArray()
        let nextShouldContinueExpectation: ()->XCTestExpectation? = {
            nextShouldContinueExpectationBox.count > 0 ? nextShouldContinueExpectationBox[0] as? XCTestExpectation : nil
        }
        
        let successReportedExpectationBox = NSMutableArray()
        let successReportedExpectation: ()->XCTestExpectation? = {
            successReportedExpectationBox.count > 0 ? successReportedExpectationBox[0] as? XCTestExpectation : nil
        }
        
        compositeMockBox[0] = CompositeMock(expectedCalls: [
            .flowControllerDelegate(call: .adUnitConfig(provider: { adUnitConfig })),
            .configValidation(call: { (adConfig, renderWithApollo) in true }),
            .flowControllerDelegate(call: .willSendBidRequest(handler: { loader in })),
            .makeBidRequester(handler: { config, mockRequester in mockRequester }),
            .bidRequester(call: (requesterOffset: 0, { completion in
                flowController().refresh()
                let bidResponse = try! OXABidResponseTransformer.transform(OXABidResponseTransformer.someValidResponse)
                completion(bidResponse, nil)
            })),
            .flowControllerDelegate(call: .shouldContinue(handler: { loader in
                nextShouldContinueExpectation()?.fulfill()
                return false
            })),
            .flowControllerDelegate(call: .willRequestPrimaryAd(handler: { loader in })),
            .adLoader(call: .setFlowDelegate(handler: { delegate in })),
            .adLoader(call: .primaryAdRequester(provider: { compositeMock().mockPrimaryAdRequester })),
            .primaryAdRequester(call: { bidResponse in
                flowController().adLoaderDidWinApollo(compositeMock().mockAdLoader)
            }),
            .configValidation(call: { (adConfig, renderWithApollo) in true }),
            .adLoader(call: .createApolloAd(handler: { (bid, config, adSaver, adLoadHandler) in
                flowController().refresh()
                fakeAdBox[0] = NSObject()
                adSaver(fakeAd() as Any)
                adLoadHandler {
                    fakeAdSizeBox[0] = NSValue(cgSize: bid.size)
                    flowController().adLoaderLoadedApolloAd(compositeMock().mockAdLoader)
                }
            })),
            .flowControllerDelegate(call: .shouldContinue(handler: { loader in
                nextShouldContinueExpectation()?.fulfill()
                return false
            })),
            .adLoader(call: .reportSuccess(handler: { (ad, size) in
                XCTAssertEqual(ad as? NSObject, fakeAd())
                XCTAssertEqual(size, fakeAdSize())
                successReportedExpectation()?.fulfill()
            })),
        ])
        
        flowControllerBox[0] = OXAAdLoadFlowController(bidRequesterFactory: compositeMock().mockRequesterFactory,
                                                       adLoader: compositeMock().mockAdLoader,
                                                       delegate: compositeMock().mockFlowControllerDelegate,
                                                       configValidationBlock: compositeMock().mockConfigValidator)
        
        nextShouldContinueExpectationBox[0] = expectation(description: "First 'shouldContinue' reached")
        let firstTimeout = expectation(description: "first timeout")
        firstTimeout.isInverted = true
        
        flowController().refresh()
        waitForExpectations(timeout: 1)
        
        XCTAssertEqual(flowController().flowState, .demandReceived)
        XCTAssertEqual(compositeMock().getProgress().done, 6)
        
        nextShouldContinueExpectationBox[0] = expectation(description: "Second 'shouldContinue' reached")
        let secondTimeout = expectation(description: "first timeout")
        secondTimeout.isInverted = true
        
        flowController().refresh()
        waitForExpectations(timeout: 1)
        
        XCTAssertEqual(flowController().flowState, .readyToDeploy)
        XCTAssertEqual(compositeMock().getProgress().done, 13)
        
        successReportedExpectationBox[0] = expectation(description: "success reported")
        
        flowController().refresh()
        waitForExpectations(timeout: 1)
        
        XCTAssertFalse(flowController().hasFailedLoading)
        XCTAssertEqual(flowController().flowState, .idle)
        XCTAssertEqual(compositeMock().getProgress().done, 14)
        compositeMock().checkIsFinished()
    }
}
