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

import UIKit

@testable @_spi(PBMInternal) import PrebidMobile

class ModalManagerTestDisplayInInterstitial: XCTestCase {
    
    var expectationModalManagerDidFinishPop:XCTestExpectation?
    func modalManagerDidFinishPop(_ state: ModalState!) {
        expectationModalManagerDidFinishPop?.fulfill()
    }
    
    var expectationModalManagerDidLeaveApp:XCTestExpectation?
    func modalManagerDidLeaveApp(_ state: ModalState!) {
        expectationModalManagerDidLeaveApp?.fulfill()
    }
    
    private var logToFile: LogToFileLock?
    
    override func tearDown() {
        logToFile = nil
        expectationModalManagerDidFinishPop = nil
        expectationModalManagerDidLeaveApp = nil
        super.tearDown()
    }
    
    func testPushPop() {
        logToFile = .init()
        
        let modalManager = ModalManager()
        XCTAssertNil(modalManager.modalViewController)
        XCTAssertEqual(modalManager.modalStateStack.count, 0)
        
        //ViewControllers are picky about being presented in a windowless environment.
        //This Mock simulates a dismiss.
        modalManager.modalViewControllerClass = MockPBMModalViewController.self
        
        //Create a MockVC to present from. This will prevent complaints that we don't have an Application or keyWindow.
        let mockVC = MockViewController()
        mockVC.expectationDidPresentViewController = self.expectation(description: "expectationDidPresentViewController")
        
        //Push a view. Expect that the mock VC will be asked to present a ModalViewController and that afterwards the stack will be size 1
        var expectationPushModalCompletionManager = self.expectation(description: "expectationPushModalCompletionManager")
        
        var state = Factory.createModalState(view: PBMWebView(),
                                             adConfiguration:AdConfiguration(),
                                             displayProperties:InterstitialDisplayProperties(),
                                             onStatePopFinished: { [weak self] poppedState in
            self?.modalManagerDidFinishPop(poppedState)
        }, onStateHasLeftApp: { [weak self] leavingState in
            self?.modalManagerDidLeaveApp(leavingState)
            
        })
        _ = modalManager.pushModal(state, fromRootViewController:mockVC, animated:true, shouldReplace:false, completionHandler:{
            expectationPushModalCompletionManager.fulfill()
        })
        
        self.waitForExpectations(timeout: 4.0, handler: nil)
        PBMAssertEq(modalManager.modalStateStack.count, 1)
        
        //Push another view. Expect stack size to be 2
        expectationPushModalCompletionManager = self.expectation(description: "expectationPushModalCompletionManager")
        state = Factory.createModalState(view: PBMWebView(),adConfiguration:AdConfiguration(), displayProperties:InterstitialDisplayProperties(), onStatePopFinished: { [weak self] poppedState in
            self?.modalManagerDidFinishPop(poppedState)
        }, onStateHasLeftApp: { [weak self] leavingState in
            self?.modalManagerDidLeaveApp(leavingState)
            
        })
        _ = modalManager.pushModal(state, fromRootViewController:mockVC, animated:true, shouldReplace:false, completionHandler:{
            expectationPushModalCompletionManager.fulfill()
        })
        self.waitForExpectations(timeout: 4.0, handler: nil)
        PBMAssertEq(modalManager.modalStateStack.count, 2)
        
        //Pop once
        self.expectationModalManagerDidFinishPop = self.expectation(description: "expectationModalManagerDidFinishPop")
        modalManager.popModal()
        self.waitForExpectations(timeout: 3.0, handler:nil)
        PBMAssertEq(modalManager.modalStateStack.count, 1)
        
        //Pop again
        self.expectationModalManagerDidFinishPop = self.expectation(description: "expectationModalManagerDidFinishPop")
        modalManager.popModal()
        self.waitForExpectations(timeout: 3.0, handler:nil)
        PBMAssertEq(modalManager.modalStateStack.count, 0)
        
        //Pop again with empty stack
        modalManager.popModal()
        PBMAssertEq(modalManager.modalStateStack.count, 0)
        
        let asyncExpectation = self.expectation(description: "async dispatch finished")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute:{
            asyncExpectation.fulfill()
        })
        waitForExpectations(timeout: 3)
        
        let log = Log.getLogFileAsString() ?? ""
        XCTAssertTrue(log.contains("popModal called on empty modalStateStack!"))
    }
    
    func testDismissAllInterstitialsIfAny() {
        let modalManager = ModalManager()
        XCTAssertNil(modalManager.modalViewController)
        XCTAssertEqual(modalManager.modalStateStack.count, 0)
        
        //ViewControllers are picky about being presented in a windowless environment.
        //This Mock simulates a dismiss.
        modalManager.modalViewControllerClass = MockPBMModalViewController.self
        let mockVC = MockViewController()
        
        //Push a view.
        var expectationPushModalCompletionManager = self.expectation(description: "expectationPushModalCompletionManager")
        var state = Factory.createModalState(view: PBMWebView(),
                                             adConfiguration:AdConfiguration(),
                                             displayProperties:InterstitialDisplayProperties(),
                                             onStatePopFinished: { [weak self] poppedState in
            self?.modalManagerDidFinishPop(poppedState)
        }, onStateHasLeftApp: { [weak self] leavingState in
            self?.modalManagerDidLeaveApp(leavingState)
            
        })
        _ = modalManager.pushModal(state,
                                   fromRootViewController:mockVC,
                                   animated:true,
                                   shouldReplace:false,
                                   completionHandler:{
            expectationPushModalCompletionManager.fulfill()
        })
        self.waitForExpectations(timeout: 4.0, handler: nil)
        PBMAssertEq(modalManager.modalStateStack.count, 1)
        
        //Push another view. Expect stack size to be 2
        expectationPushModalCompletionManager = self.expectation(description: "expectationPushModalCompletionManager")
        state = Factory.createModalState(view: PBMWebView(),
                                         adConfiguration:AdConfiguration(),
                                         displayProperties:InterstitialDisplayProperties(),
                                         onStatePopFinished: { [weak self] poppedState in
            self?.modalManagerDidFinishPop(poppedState)
        }, onStateHasLeftApp: { [weak self] leavingState in
            self?.modalManagerDidLeaveApp(leavingState)
            
        })
        _ = modalManager.pushModal(state,
                                   fromRootViewController:mockVC,
                                   animated:true,
                                   shouldReplace:false,
                                   completionHandler:{
            expectationPushModalCompletionManager.fulfill()
        })
        self.waitForExpectations(timeout: 4.0, handler: nil)
        PBMAssertEq(modalManager.modalStateStack.count, 2)
        
        self.expectationModalManagerDidFinishPop = self.expectation(description: "expectationModalManagerDidFinishPop")
        modalManager.dismissAllInterstitialsIfAny()
        self.waitForExpectations(timeout: 4.0, handler: nil)
        XCTAssertNil(modalManager.modalViewController)
        XCTAssertEqual(modalManager.modalStateStack.count, 0)
    }
    
    func testHideShow() {
        let modalManager = ModalManager()
        XCTAssertNil(modalManager.modalViewController)
        XCTAssertEqual(modalManager.modalStateStack.count, 0)
        
        //ViewControllers are picky about being presented in a windowless environment.
        //This Mock simulates a dismiss.
        modalManager.modalViewControllerClass = MockPBMModalViewController.self
        
        //Create a MockVC to present from. This will prevent complaints that we don't have an Application or keyWindow.
        let mockVC = MockViewController()
        mockVC.expectationDidPresentViewController = self.expectation(description: "expectationDidPresentViewController")
        
        //Push a view. Expect that the mock VC will be asked to present a ModalViewController and that afterwards the stack will be size 1
        var expectationPushModalCompletionManager = self.expectation(description: "expectationPushModalCompletionManager")
        
        let state = Factory.createModalState(view: PBMWebView(),
                                             adConfiguration:AdConfiguration(),
                                             displayProperties:InterstitialDisplayProperties(),
                                             onStatePopFinished: { [weak self] poppedState in
            self?.modalManagerDidFinishPop(poppedState)
        }, onStateHasLeftApp: { [weak self] leavingState in
            self?.modalManagerDidLeaveApp(leavingState)
            
        })
        _ = modalManager.pushModal(state, fromRootViewController:mockVC, animated:true, shouldReplace:false, completionHandler:{
            expectationPushModalCompletionManager.fulfill()
        })
        
        self.waitForExpectations(timeout: 4.0, handler: nil)
        
        // Hide Modal
        expectationPushModalCompletionManager = self.expectation(description: "expectationPushModalCompletionManager")
        
        modalManager.hideModal(animated: true, completionHandler: {
            expectationPushModalCompletionManager.fulfill()
        })
        
        self.waitForExpectations(timeout: 4.0, handler: nil)
        
        // Back Modal
        mockVC.expectationDidPresentViewController = self.expectation(description: "expectationDidPresentViewController")
        modalManager.backModal(animated: true, fromRootViewController: mockVC, completionHandler: {
            PBMAssertEq(modalManager.modalStateStack.count, 1)
        })
        
        self.waitForExpectations(timeout: 4.0, handler: nil)
    }
    
    func testModalViewControllerDidLeaveApp() {
        let modalManager = ModalManager()
        modalManager.modalViewControllerClass = MockPBMModalViewController.self
        
        let mockVC = MockViewController()
        mockVC.expectationDidPresentViewController = self.expectation(description: "expectationDidPresentViewController")
        
        let expectationPushModalCompletionManager = self.expectation(description: "expectationPushModalCompletionManager")
        
        let state = Factory.createModalState(view: PBMWebView(), adConfiguration:AdConfiguration(), displayProperties:InterstitialDisplayProperties(),
                                             onStatePopFinished: { [weak self] poppedState in
            self?.modalManagerDidFinishPop(poppedState)
        }, onStateHasLeftApp: { [weak self] leavingState in
            self?.modalManagerDidLeaveApp(leavingState)
            
        })
        _ = modalManager.pushModal(state, fromRootViewController:mockVC, animated:true, shouldReplace:false, completionHandler:{
            expectationPushModalCompletionManager.fulfill()
        })
        
        self.waitForExpectations(timeout: 2.0, handler: nil)
        
        expectationModalManagerDidLeaveApp = self.expectation(description: "expectationModalManagerDidLeaveApp")
        
        modalManager.modalViewControllerDidLeaveApp()
        
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }
}

class ModalManagerTestPresentationType : XCTestCase {
    
    func testPresentModalViewController() {
        let defaultState = Factory.createModalState(view: PBMWebView(),
                                                    adConfiguration:AdConfiguration(),
                                                    displayProperties:InterstitialDisplayProperties())
        XCTAssertEqual(defaultState.mraidState, .notEnabled)
        presentationFrom(defaultState) { controller in
            XCTAssertTrue(controller! is ModalViewController)
        }
    }
    
    func testPresentNonModalViewController() {
        let resizedState = Factory.createModalState(view: PBMWebView(),
                                                    adConfiguration:AdConfiguration(),
                                                    displayProperties:InterstitialDisplayProperties())
        resizedState.mraidState = MRAIDState.resized
        XCTAssertEqual(resizedState.mraidState, .resized)
        presentationFrom(resizedState) { controller in
            XCTAssertTrue(controller! is NonModalViewController)
        }
    }
    
    func presentationFrom(_ state: ModalState, completion: ((UIViewController?) -> Void)?)  {
        let mockVC = MockViewController()
        mockVC.expectationDidPresentViewController = self.expectation(description: "expectationDidPresentViewController")
        
        let modalManager = ModalManager()
        XCTAssertNil(modalManager.modalViewController)
        XCTAssertEqual(modalManager.modalStateStack.count, 0)
        
        //Push PBMNonModalViewController
        let expectationPushModalCompletionManager = self.expectation(description: "expectationPushModalCompletionManager")
        _ = modalManager.pushModal(state, fromRootViewController:mockVC, animated:true, shouldReplace:false, completionHandler:{
            expectationPushModalCompletionManager.fulfill()
            PBMAssertEq(modalManager.modalStateStack.count, 1)
            completion?(modalManager.modalViewController)
        })
        
        self.waitForExpectations(timeout: 3.0, handler:nil)
    }
}

class ModalManagerTestOther : XCTestCase {
    
    private var logToFile: LogToFileLock?
    
    override func tearDown() {
        logToFile = nil
        super.tearDown()
    }
    
    //TODO: This is currently a "doesn't crash" test. Once UIDevice can be injected, this can change
    //to one that verifies that UIDevice is receiving the proper instruction.
    func testForceOrientation() {
        let modalManager = ModalManager()
        modalManager.forceOrientation(UIInterfaceOrientation.portrait)
    }
    
    func testPBMDescription() {
        let modalManager = ModalManager()
        
        let expectationOrientation = expectation(description: "UIInterfaceOrientation.portrait")
        
        logToFile = .init()
        
        modalManager.forceOrientation(UIInterfaceOrientation.portrait)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute:{
            UtilitiesForTesting.checkLogContains("Forcing orientation to portrait")
            expectationOrientation.fulfill()
        })
        
        waitForExpectations(timeout: 1, handler:nil)
    }
}
