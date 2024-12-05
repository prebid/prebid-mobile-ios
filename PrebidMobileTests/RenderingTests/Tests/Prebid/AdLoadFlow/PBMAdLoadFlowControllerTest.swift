/*   Copyright 2018-2021 Prebid.org, Inc.

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
import XCTest

@testable import PrebidMobile

class PBMAdLoadFlowControllerTest: XCTestCase {
    private typealias CompositeMock = PBMAdLoadFlowControllerTest_CompositeMock
    
    override func setUp() {
        super.setUp()
        
        Prebid.reset()
    }
    
    func testNoImmediateCalls() {
        let adUnitConfig = AdUnitConfig(configId: "configId")
        let compositeMock = CompositeMock(expectedCalls: [])
        let flowController = PBMAdLoadFlowController(bidRequesterFactory: compositeMock.mockRequesterFactory,
                                                     adLoader: compositeMock.mockAdLoader,
                                                     adUnitConfig: adUnitConfig,
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
        let adUnitConfig = AdUnitConfig(configId: "configID")
        
        let flowControllerBox = NSMutableArray()
        let flowController: ()->PBMAdLoadFlowController = { flowControllerBox[0] as! PBMAdLoadFlowController }
        
        let fakeAdBox = NSMutableArray()
        let fakeAd: ()->NSObject? = { (fakeAdBox.count > 0) ? (fakeAdBox[0] as! NSObject) : nil }
        let fakeAdSizeBox = NSMutableArray()
        let fakeAdSize: ()->NSValue? = { (fakeAdSizeBox.count > 0) ? (fakeAdSizeBox[0] as! NSValue) : nil }
        
        let compositeMockBox = NSMutableArray()
        let compositeMock: ()->CompositeMock = { compositeMockBox[0] as! CompositeMock }
        
        let successReported = expectation(description: "success reported")
        
        compositeMockBox[0] = CompositeMock(expectedCalls: [
            .configValidation(call: { (adConfig, renderWithPrebid) in
                XCTAssertFalse(renderWithPrebid)
                return true
            }),
            .flowControllerDelegate(call: .willSendBidRequest(handler: { loader in
                XCTAssertEqual(loader, flowController())
            })),
            .makeBidRequester(handler: { config, mockRequester in mockRequester }),
            .bidRequester(call: (requesterOffset: 0, { completion in
                let bidResponse = try! PBMBidResponseTransformer.transform(PBMBidResponseTransformer.someValidResponse)
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
        
        flowControllerBox[0] = PBMAdLoadFlowController(bidRequesterFactory: compositeMock().mockRequesterFactory,
                                                       adLoader: compositeMock().mockAdLoader,
                                                       adUnitConfig: adUnitConfig,
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
    
    func testPrebidAd_happyPath_fromIdle() {
        testPrebidAd_happyPath(preFailed: false)
    }
    
    func testPrebidAd_happyPath_fromFailed() {
        testPrebidAd_happyPath(preFailed: true)
    }
    
    func testPrebidAd_happyPath(preFailed: Bool) {
        let adUnitConfig = AdUnitConfig(configId: "configID")
        
        let flowControllerBox = NSMutableArray()
        let flowController: ()->PBMAdLoadFlowController = { flowControllerBox[0] as! PBMAdLoadFlowController }
        
        let fakeAdBox = NSMutableArray()
        let fakeAd: ()->NSObject? = { (fakeAdBox.count > 0) ? (fakeAdBox[0] as! NSObject) : nil }
        let fakeAdSizeBox = NSMutableArray()
        let fakeAdSize: ()->NSValue? = { (fakeAdSizeBox.count > 0) ? (fakeAdSizeBox[0] as! NSValue) : nil }
        
        let compositeMockBox = NSMutableArray()
        let compositeMock: ()->CompositeMock = { compositeMockBox[0] as! CompositeMock }
        
        let successReported = expectation(description: "success reported")
        
        compositeMockBox[0] = CompositeMock(expectedCalls: [
            .configValidation(call: { (adConfig, renderWithPrebid) in
                XCTAssertFalse(renderWithPrebid)
                return true
            }),
            .flowControllerDelegate(call: .willSendBidRequest(handler: { loader in
                XCTAssertEqual(loader, flowController())
            })),
            .makeBidRequester(handler: { config, mockRequester in mockRequester }),
            .bidRequester(call: (requesterOffset: 0, { completion in
                let bidResponse = try! PBMBidResponseTransformer.transform(PBMBidResponseTransformer.someValidResponse)
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
                flowController().adLoaderDidWinPrebid(compositeMock().mockAdLoader)
            }),
            .configValidation(call: { (adConfig, renderWithPrebid) in
                XCTAssertTrue(renderWithPrebid)
                return true
            }),
            .adLoader(call: .createPrebidAd(handler: { (bid, config, adSaver, adLoadHandler) in
                fakeAdBox[0] = NSObject()
                adSaver(fakeAd() as Any)
                adLoadHandler {
                    fakeAdSizeBox[0] = NSValue(cgSize: bid.size)
                    flowController().adLoaderLoadedPrebidAd(compositeMock().mockAdLoader)
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
        
        flowControllerBox[0] = PBMAdLoadFlowController(bidRequesterFactory: compositeMock().mockRequesterFactory,
                                                       adLoader: compositeMock().mockAdLoader,
                                                       adUnitConfig: adUnitConfig,
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
        let adUnitConfig = AdUnitConfig(configId: "configID")
        
        let flowControllerBox = NSMutableArray()
        let flowController: ()->PBMAdLoadFlowController = { flowControllerBox[0] as! PBMAdLoadFlowController }
        
        let fakeAdBox = NSMutableArray()
        let fakeAd: ()->NSObject? = { (fakeAdBox.count > 0) ? (fakeAdBox[0] as! NSObject) : nil }
        let fakeAdSizeBox = NSMutableArray()
        let fakeAdSize: ()->NSValue? = { (fakeAdSizeBox.count > 0) ? (fakeAdSizeBox[0] as! NSValue) : nil }
        
        let compositeMockBox = NSMutableArray()
        let compositeMock: ()->CompositeMock = { compositeMockBox[0] as! CompositeMock }
        
        let successReported = expectation(description: "success reported")
        
        compositeMockBox[0] = CompositeMock(expectedCalls: [
            .configValidation(call: { (adConfig, renderWithPrebid) in
                XCTAssertFalse(renderWithPrebid)
                return true
            }),
            .flowControllerDelegate(call: .willSendBidRequest(handler: { loader in
                XCTAssertEqual(loader, flowController())
            })),
            .makeBidRequester(handler: { config, mockRequester in mockRequester }),
            .bidRequester(call: (requesterOffset: 0, { completion in
                let rawResponse = PBMBidResponseTransformer.invalidAccountIDResponse(accountID: "some id")
                var bidResponse: BidResponse?
                do {
                    bidResponse = try PBMBidResponseTransformer.transform(rawResponse)
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
        
        flowControllerBox[0] = PBMAdLoadFlowController(bidRequesterFactory: compositeMock().mockRequesterFactory,
                                                       adLoader: compositeMock().mockAdLoader,
                                                       adUnitConfig: adUnitConfig,
                                                       delegate: compositeMock().mockFlowControllerDelegate,
                                                       configValidationBlock: compositeMock().mockConfigValidator)
        
        flowController().refresh()
        waitForExpectations(timeout: 1)
        
        XCTAssertFalse(flowController().hasFailedLoading)
        XCTAssertEqual(flowController().flowState, .idle)
        compositeMock().checkIsFinished()
    }
    
    func testPrimaryAd_noBids_noPrimaryAd() {
        let adUnitConfig = AdUnitConfig(configId: "configID")
        
        let flowControllerBox = NSMutableArray()
        let flowController: ()->PBMAdLoadFlowController = { flowControllerBox[0] as! PBMAdLoadFlowController }
        
        let fakeErrorBox = NSMutableArray()
        let fakeError: ()->Error? = { (fakeErrorBox.count > 0) ? (fakeErrorBox[0] as! Error) : nil }
        
        let compositeMockBox = NSMutableArray()
        let compositeMock: ()->CompositeMock = { compositeMockBox[0] as! CompositeMock }
        
        let failureReported = expectation(description: "failure reported")
        
        compositeMockBox[0] = CompositeMock(expectedCalls: [
            .configValidation(call: { (adConfig, renderWithPrebid) in
                XCTAssertFalse(renderWithPrebid)
                return true
            }),
            .flowControllerDelegate(call: .willSendBidRequest(handler: { loader in
                XCTAssertEqual(loader, flowController())
            })),
            .makeBidRequester(handler: { config, mockRequester in mockRequester }),
            .bidRequester(call: (requesterOffset: 0, { completion in
                let rawResponse = PBMBidResponseTransformer.invalidAccountIDResponse(accountID: "some id")
                var bidResponse: BidResponse?
                do {
                    bidResponse = try PBMBidResponseTransformer.transform(rawResponse)
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
                flowController().adLoaderDidWinPrebid(compositeMock().mockAdLoader)
            }),
            .flowControllerDelegate(call: .failedWithError(handler: { (loader, error) in
                XCTAssertEqual(loader, flowController())
                XCTAssertEqual(error as NSError?, fakeError() as NSError?)
                failureReported.fulfill()
            })),
        ])
        
        flowControllerBox[0] = PBMAdLoadFlowController(bidRequesterFactory: compositeMock().mockRequesterFactory,
                                                       adLoader: compositeMock().mockAdLoader,
                                                       adUnitConfig: adUnitConfig,
                                                       delegate: compositeMock().mockFlowControllerDelegate,
                                                       configValidationBlock: compositeMock().mockConfigValidator)
        
        flowController().refresh()
        waitForExpectations(timeout: 1)
        
        XCTAssertTrue(flowController().hasFailedLoading)
        XCTAssertEqual(flowController().flowState, .loadingFailed)
        compositeMock().checkIsFinished()
    }
    
    func testPrebidAd_didFail() {
        let adUnitConfig = AdUnitConfig(configId: "configID")
        
        let flowControllerBox = NSMutableArray()
        let flowController: ()->PBMAdLoadFlowController = { flowControllerBox[0] as! PBMAdLoadFlowController }
        
        let fakeErrorBox = NSMutableArray()
        let fakeError: ()->Error? = { (fakeErrorBox.count > 0) ? (fakeErrorBox[0] as! Error) : nil }
        
        let compositeMockBox = NSMutableArray()
        let compositeMock: ()->CompositeMock = { compositeMockBox[0] as! CompositeMock }
        
        let failureReported = expectation(description: "failure reported")
        
        compositeMockBox[0] = CompositeMock(expectedCalls: [
            .configValidation(call: { (adConfig, renderWithPrebid) in
                XCTAssertFalse(renderWithPrebid)
                return true
            }),
            .flowControllerDelegate(call: .willSendBidRequest(handler: { loader in
                XCTAssertEqual(loader, flowController())
            })),
            .makeBidRequester(handler: { config, mockRequester in mockRequester }),
            .bidRequester(call: (requesterOffset: 0, { completion in
                let bidResponse = try! PBMBidResponseTransformer.transform(PBMBidResponseTransformer.someValidResponse)
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
                flowController().adLoaderDidWinPrebid(compositeMock().mockAdLoader)
            }),
            .configValidation(call: { (adConfig, renderWithPrebid) in
                XCTAssertTrue(renderWithPrebid)
                return true
            }),
            .adLoader(call: .createPrebidAd(handler: { (bid, config, adSaver, adLoadHandler) in
                adSaver(NSObject() as Any)
                adLoadHandler {
                    enum FakePrebidError: Error { case someError }
                    fakeErrorBox[0] = FakePrebidError.someError
                    flowController().adLoader(compositeMock().mockAdLoader, failedWithPrebidError: fakeError())
                }
            })),
            .flowControllerDelegate(call: .failedWithError(handler: { (loader, error) in
                XCTAssertEqual(loader, flowController())
                XCTAssertEqual(error as NSError?, fakeError() as NSError?)
                failureReported.fulfill()
            })),
        ])
        
        flowControllerBox[0] = PBMAdLoadFlowController(bidRequesterFactory: compositeMock().mockRequesterFactory,
                                                       adLoader: compositeMock().mockAdLoader,
                                                       adUnitConfig: adUnitConfig,
                                                       delegate: compositeMock().mockFlowControllerDelegate,
                                                       configValidationBlock: compositeMock().mockConfigValidator)
        
        flowController().refresh()
        waitForExpectations(timeout: 1)
        
        XCTAssertTrue(flowController().hasFailedLoading)
        XCTAssertEqual(flowController().flowState, .loadingFailed)
        compositeMock().checkIsFinished()
    }
    
    func testPrimaryAdFail_withBids_fallbackToPrebid() {
        let adUnitConfig = AdUnitConfig(configId: "configID")
        
        let flowControllerBox = NSMutableArray()
        let flowController: ()->PBMAdLoadFlowController = { flowControllerBox[0] as! PBMAdLoadFlowController }
        
        let fakeAdBox = NSMutableArray()
        let fakeAd: ()->NSObject? = { (fakeAdBox.count > 0) ? (fakeAdBox[0] as! NSObject) : nil }
        let fakeAdSizeBox = NSMutableArray()
        let fakeAdSize: ()->NSValue? = { (fakeAdSizeBox.count > 0) ? (fakeAdSizeBox[0] as! NSValue) : nil }
        
        let compositeMockBox = NSMutableArray()
        let compositeMock: ()->CompositeMock = { compositeMockBox[0] as! CompositeMock }
        
        let successReported = expectation(description: "success reported")
        
        compositeMockBox[0] = CompositeMock(expectedCalls: [
            .configValidation(call: { (adConfig, renderWithPrebid) in
                XCTAssertFalse(renderWithPrebid)
                return true
            }),
            .flowControllerDelegate(call: .willSendBidRequest(handler: { loader in
                XCTAssertEqual(loader, flowController())
            })),
            .makeBidRequester(handler: { config, mockRequester in mockRequester }),
            .bidRequester(call: (requesterOffset: 0, { completion in
                let bidResponse = try! PBMBidResponseTransformer.transform(PBMBidResponseTransformer.someValidResponse)
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
            .configValidation(call: { (adConfig, renderWithPrebid) in
                XCTAssertTrue(renderWithPrebid)
                return true
            }),
            .adLoader(call: .createPrebidAd(handler: { (bid, config, adSaver, adLoadHandler) in
                fakeAdBox[0] = NSObject()
                adSaver(fakeAd() as Any)
                adLoadHandler {
                    fakeAdSizeBox[0] = NSValue(cgSize: bid.size)
                    flowController().adLoaderLoadedPrebidAd(compositeMock().mockAdLoader)
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
        
        flowControllerBox[0] = PBMAdLoadFlowController(bidRequesterFactory: compositeMock().mockRequesterFactory,
                                                       adLoader: compositeMock().mockAdLoader,
                                                       adUnitConfig: adUnitConfig,
                                                       delegate: compositeMock().mockFlowControllerDelegate,
                                                       configValidationBlock: compositeMock().mockConfigValidator)
        
        flowController().refresh()
        waitForExpectations(timeout: 1)
        
        XCTAssertFalse(flowController().hasFailedLoading)
        XCTAssertEqual(flowController().flowState, .idle)
        compositeMock().checkIsFinished()
    }
    
    func testPrimaryAd_noBids_primarySDKError() {
        let adUnitConfig = AdUnitConfig(configId: "configID")
        
        let flowControllerBox = NSMutableArray()
        let flowController: ()->PBMAdLoadFlowController = { flowControllerBox[0] as! PBMAdLoadFlowController }
        
        let fakePrebidErrorBox = NSMutableArray()
        //let fakePrebidError: ()->Error? = { (fakePrebidErrorBox.count > 0) ? (fakePrebidErrorBox[0] as! Error) : nil }
        let fakeSDKErrorBox = NSMutableArray()
        let fakeSDKError: ()->Error? = { (fakeSDKErrorBox.count > 0) ? (fakeSDKErrorBox[0] as! Error) : nil }
        
        let compositeMockBox = NSMutableArray()
        let compositeMock: ()->CompositeMock = { compositeMockBox[0] as! CompositeMock }
        
        let failureReported = expectation(description: "failure reported")
        
        compositeMockBox[0] = CompositeMock(expectedCalls: [
            .configValidation(call: { (adConfig, renderWithPrebid) in
                XCTAssertFalse(renderWithPrebid)
                return true
            }),
            .flowControllerDelegate(call: .willSendBidRequest(handler: { loader in
                XCTAssertEqual(loader, flowController())
            })),
            .makeBidRequester(handler: { config, mockRequester in mockRequester }),
            .bidRequester(call: (requesterOffset: 0, { completion in
                let rawResponse = PBMBidResponseTransformer.invalidAccountIDResponse(accountID: "some id")
                var bidResponse: BidResponse?
                do {
                    bidResponse = try PBMBidResponseTransformer.transform(rawResponse)
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
        
        flowControllerBox[0] = PBMAdLoadFlowController(bidRequesterFactory: compositeMock().mockRequesterFactory,
                                                       adLoader: compositeMock().mockAdLoader,
                                                       adUnitConfig: adUnitConfig,
                                                       delegate: compositeMock().mockFlowControllerDelegate,
                                                       configValidationBlock: compositeMock().mockConfigValidator)
        
        flowController().refresh()
        waitForExpectations(timeout: 1)
        
        XCTAssertTrue(flowController().hasFailedLoading)
        XCTAssertEqual(flowController().flowState, .loadingFailed)
        compositeMock().checkIsFinished()
    }
    
    func testConfigInvalid_forEventHandler() {
        let adUnitConfig = AdUnitConfig(configId: "configID")
        
        let flowControllerBox = NSMutableArray()
        let flowController: ()->PBMAdLoadFlowController = { flowControllerBox[0] as! PBMAdLoadFlowController }
        
        let compositeMockBox = NSMutableArray()
        let compositeMock: ()->CompositeMock = { compositeMockBox[0] as! CompositeMock }
        
        let failureReported = expectation(description: "failure reported")
        
        compositeMockBox[0] = CompositeMock(expectedCalls: [
            .configValidation(call: { (adConfig, renderWithPrebid) in
                XCTAssertFalse(renderWithPrebid)
                return false
            }),
            .flowControllerDelegate(call: .failedWithError(handler: { (loader, error) in
                XCTAssertEqual(loader, flowController())
                XCTAssertNotNil(error)
                failureReported.fulfill()
            })),
        ])
        
        flowControllerBox[0] = PBMAdLoadFlowController(bidRequesterFactory: compositeMock().mockRequesterFactory,
                                                       adLoader: compositeMock().mockAdLoader,
                                                       adUnitConfig: adUnitConfig,
                                                       delegate: compositeMock().mockFlowControllerDelegate,
                                                       configValidationBlock: compositeMock().mockConfigValidator)
        
        flowController().refresh()
        waitForExpectations(timeout: 1)
        
        XCTAssertTrue(flowController().hasFailedLoading)
        XCTAssertEqual(flowController().flowState, .loadingFailed)
        compositeMock().checkIsFinished()
    }
    
    func testConfigInvalid_forPrebid() {
        let adUnitConfig = AdUnitConfig(configId: "configID")
        
        let flowControllerBox = NSMutableArray()
        let flowController: ()->PBMAdLoadFlowController = { flowControllerBox[0] as! PBMAdLoadFlowController }
        
        let compositeMockBox = NSMutableArray()
        let compositeMock: ()->CompositeMock = { compositeMockBox[0] as! CompositeMock }
        
        let failureReported = expectation(description: "failure reported")
        
        compositeMockBox[0] = CompositeMock(expectedCalls: [
            .configValidation(call: { (adConfig, renderWithPrebid) in
                XCTAssertFalse(renderWithPrebid)
                return true
            }),
            .flowControllerDelegate(call: .willSendBidRequest(handler: { loader in
                XCTAssertEqual(loader, flowController())
            })),
            .makeBidRequester(handler: { config, mockRequester in mockRequester }),
            .bidRequester(call: (requesterOffset: 0, { completion in
                let bidResponse = try! PBMBidResponseTransformer.transform(PBMBidResponseTransformer.someValidResponse)
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
                flowController().adLoaderDidWinPrebid(compositeMock().mockAdLoader)
            }),
            .configValidation(call: { (adConfig, renderWithPrebid) in
                XCTAssertTrue(renderWithPrebid)
                return false
            }),
            .flowControllerDelegate(call: .failedWithError(handler: { (loader, error) in
                XCTAssertEqual(loader, flowController())
                XCTAssertNotNil(error)
                failureReported.fulfill()
            })),
        ])
        
        flowControllerBox[0] = PBMAdLoadFlowController(bidRequesterFactory: compositeMock().mockRequesterFactory,
                                                       adLoader: compositeMock().mockAdLoader,
                                                       adUnitConfig: adUnitConfig,
                                                       delegate: compositeMock().mockFlowControllerDelegate,
                                                       configValidationBlock: compositeMock().mockConfigValidator)
        
        flowController().refresh()
        waitForExpectations(timeout: 1)
        
        XCTAssertTrue(flowController().hasFailedLoading)
        XCTAssertEqual(flowController().flowState, .loadingFailed)
        compositeMock().checkIsFinished()
    }
    
    func testPrebidWin_noWinningBidInBidResponse() {
        let adUnitConfig = AdUnitConfig(configId: "configID")
        
        let flowControllerBox = NSMutableArray()
        let flowController: ()->PBMAdLoadFlowController = { flowControllerBox[0] as! PBMAdLoadFlowController }
        
        let compositeMockBox = NSMutableArray()
        let compositeMock: ()->CompositeMock = { compositeMockBox[0] as! CompositeMock }
        
        let failureReported = expectation(description: "failure reported")
        
        compositeMockBox[0] = CompositeMock(expectedCalls: [
            .configValidation(call: { (adConfig, renderWithPrebid) in
                XCTAssertFalse(renderWithPrebid)
                return true
            }),
            .flowControllerDelegate(call: .willSendBidRequest(handler: { loader in
                XCTAssertEqual(loader, flowController())
            })),
            .makeBidRequester(handler: { config, mockRequester in mockRequester }),
            .bidRequester(call: (requesterOffset: 0, { completion in
                let bidResponse = try! PBMBidResponseTransformer.transform(PBMBidResponseTransformer
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
                flowController().adLoaderDidWinPrebid(compositeMock().mockAdLoader)
            }),
            .configValidation(call: { (adConfig, renderWithPrebid) in
                XCTAssertTrue(renderWithPrebid)
                return true
            }),
            .flowControllerDelegate(call: .failedWithError(handler: { (loader, error) in
                XCTAssertEqual(loader, flowController())
                XCTAssertEqual(error as NSError?, PBMError.noWinningBid as NSError)
                failureReported.fulfill()
            })),
        ])
        
        flowControllerBox[0] = PBMAdLoadFlowController(bidRequesterFactory: compositeMock().mockRequesterFactory,
                                                       adLoader: compositeMock().mockAdLoader,
                                                       adUnitConfig: adUnitConfig,
                                                       delegate: compositeMock().mockFlowControllerDelegate,
                                                       configValidationBlock: compositeMock().mockConfigValidator)
        
        flowController().refresh()
        waitForExpectations(timeout: 1)
        
        XCTAssertTrue(flowController().hasFailedLoading)
        XCTAssertEqual(flowController().flowState, .loadingFailed)
        compositeMock().checkIsFinished()
    }
    
    func testPrebidAd_happyPath_spamRefresh() {
        let adUnitConfig = AdUnitConfig(configId: "configID")
        
        let flowControllerBox = NSMutableArray()
        let flowController: ()->PBMAdLoadFlowController = { flowControllerBox[0] as! PBMAdLoadFlowController }
        
        let fakeAdBox = NSMutableArray()
        let fakeAd: ()->NSObject? = { (fakeAdBox.count > 0) ? (fakeAdBox[0] as! NSObject) : nil }
        let fakeAdSizeBox = NSMutableArray()
        let fakeAdSize: ()->NSValue? = { (fakeAdSizeBox.count > 0) ? (fakeAdSizeBox[0] as! NSValue) : nil }
        
        let compositeMockBox = NSMutableArray()
        let compositeMock: ()->CompositeMock = { compositeMockBox[0] as! CompositeMock }
        
        let successReported = expectation(description: "success reported")
        
        compositeMockBox[0] = CompositeMock(expectedCalls: [
            .configValidation(call: { (adConfig, renderWithPrebid) in
                flowController().refresh()
                return true
            }),
            .flowControllerDelegate(call: .willSendBidRequest(handler: { loader in
                flowController().refresh()
            })),
            .makeBidRequester(handler: { config, mockRequester in mockRequester }),
            .bidRequester(call: (requesterOffset: 0, { completion in
                flowController().refresh()
                let bidResponse = try! PBMBidResponseTransformer.transform(PBMBidResponseTransformer.someValidResponse)
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
                flowController().adLoaderDidWinPrebid(compositeMock().mockAdLoader)
            }),
            .configValidation(call: { (adConfig, renderWithPrebid) in
                flowController().refresh()
                return true
            }),
            .adLoader(call: .createPrebidAd(handler: { (bid, config, adSaver, adLoadHandler) in
                flowController().refresh()
                fakeAdBox[0] = NSObject()
                adSaver(fakeAd() as Any)
                adLoadHandler {
                    fakeAdSizeBox[0] = NSValue(cgSize: bid.size)
                    flowController().adLoaderLoadedPrebidAd(compositeMock().mockAdLoader)
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
        
        flowControllerBox[0] = PBMAdLoadFlowController(bidRequesterFactory: compositeMock().mockRequesterFactory,
                                                       adLoader: compositeMock().mockAdLoader,
                                                       adUnitConfig: adUnitConfig,
                                                       delegate: compositeMock().mockFlowControllerDelegate,
                                                       configValidationBlock: compositeMock().mockConfigValidator)
        
        flowController().refresh()
        waitForExpectations(timeout: 1)
        
        XCTAssertFalse(flowController().hasFailedLoading)
        XCTAssertEqual(flowController().flowState, .idle)
        compositeMock().checkIsFinished()
    }
    
    func testPrebidAd_happyPath_freezeOnShouldContinue() {
        let adUnitConfig = AdUnitConfig(configId: "configID")
        
        let flowControllerBox = NSMutableArray()
        let flowController: ()->PBMAdLoadFlowController = { flowControllerBox[0] as! PBMAdLoadFlowController }
        
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
            .configValidation(call: { (adConfig, renderWithPrebid) in true }),
            .flowControllerDelegate(call: .willSendBidRequest(handler: { loader in })),
            .makeBidRequester(handler: { config, mockRequester in mockRequester }),
            .bidRequester(call: (requesterOffset: 0, { completion in
                flowController().refresh()
                let bidResponse = try! PBMBidResponseTransformer.transform(PBMBidResponseTransformer.someValidResponse)
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
                flowController().adLoaderDidWinPrebid(compositeMock().mockAdLoader)
            }),
            .configValidation(call: { (adConfig, renderWithPrebid) in true }),
            .adLoader(call: .createPrebidAd(handler: { (bid, config, adSaver, adLoadHandler) in
                flowController().refresh()
                fakeAdBox[0] = NSObject()
                adSaver(fakeAd() as Any)
                adLoadHandler {
                    fakeAdSizeBox[0] = NSValue(cgSize: bid.size)
                    flowController().adLoaderLoadedPrebidAd(compositeMock().mockAdLoader)
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
        
        flowControllerBox[0] = PBMAdLoadFlowController(bidRequesterFactory: compositeMock().mockRequesterFactory,
                                                       adLoader: compositeMock().mockAdLoader,
                                                       adUnitConfig: adUnitConfig,
                                                       delegate: compositeMock().mockFlowControllerDelegate,
                                                       configValidationBlock: compositeMock().mockConfigValidator)
        
        nextShouldContinueExpectationBox[0] = expectation(description: "First 'shouldContinue' reached")
        let firstTimeout = expectation(description: "first timeout")
        firstTimeout.isInverted = true
        
        flowController().refresh()
        waitForExpectations(timeout: 1)
        
        XCTAssertEqual(flowController().flowState, .demandReceived)
        XCTAssertEqual(compositeMock().getProgress().done, 5)
        
        nextShouldContinueExpectationBox[0] = expectation(description: "Second 'shouldContinue' reached")
        let secondTimeout = expectation(description: "first timeout")
        secondTimeout.isInverted = true
        
        flowController().refresh()
        waitForExpectations(timeout: 1)
        
        XCTAssertEqual(flowController().flowState, .readyToDeploy)
        XCTAssertEqual(compositeMock().getProgress().done, 12)
        
        successReportedExpectationBox[0] = expectation(description: "success reported")
        
        flowController().refresh()
        waitForExpectations(timeout: 1)
        
        XCTAssertFalse(flowController().hasFailedLoading)
        XCTAssertEqual(flowController().flowState, .idle)
        XCTAssertEqual(compositeMock().getProgress().done, 13)
        compositeMock().checkIsFinished()
    }
}
