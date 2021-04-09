//
//  ModalManagerTest.swift
//  OpenXSDKCore
//
//  Copyright © 2015 OpenX. All rights reserved.
//

import Foundation
import XCTest

import UIKit
@testable import OpenXApolloSDK

class ModalManagerTestDisplayInInterstitial : XCTestCase {
    
    var expectationModalManagerDidFinishPop:XCTestExpectation!
    func modalManagerDidFinishPop(_ state: OXMModalState!) {
        expectationModalManagerDidFinishPop.fulfill()
    }
    
    var expectationModalManagerDidLeaveApp:XCTestExpectation!
    func modalManagerDidLeaveApp(_ state: OXMModalState!) {
        expectationModalManagerDidLeaveApp.fulfill()
    }
    
    private var logToFile: LogToFileLock?
    
    override func tearDown() {
        logToFile = nil
        super.tearDown()
    }
    
    func testPushPop() {
        logToFile = .init()
        
        let modalManager = OXMModalManager()
        OXMAssertEq(modalManager.modalViewController, nil)
        OXMAssertEq(modalManager.modalStateStack.count, 0)
        
        //ViewControllers are picky about being presented in a windowless environment.
        //This Mock simulates a dismiss.
        modalManager.modalViewControllerClass = MockOXMModalViewController.self
        
        //Create a MockVC to present from. This will prevent complaints that we don't have an Application or keyWindow.
        let mockVC = MockViewController()
        mockVC.expectationDidPresentViewController = self.expectation(description: "expectationDidPresentViewController")

        //Push a view. Expect that the mock VC will be asked to present a ModalViewController and that afterwards the stack will be size 1
        var expectationPushModalCompletionManager = self.expectation(description: "expectationPushModalCompletionManager")
        
        var state = OXMModalState(view: OXMWebView(), adConfiguration:OXMAdConfiguration(), displayProperties:OXMInterstitialDisplayProperties(), onStatePopFinished: { [weak self] poppedState in
            self?.modalManagerDidFinishPop(poppedState)
            }, onStateHasLeftApp: { [weak self] leavingState in
                self?.modalManagerDidLeaveApp(leavingState)
                
        })
        modalManager.pushModal(state, fromRootViewController:mockVC, animated:true, shouldReplace:false, completionHandler:{
            expectationPushModalCompletionManager.fulfill()
        })
        
        self.waitForExpectations(timeout: 4.0, handler: nil)
        OXMAssertEq(modalManager.modalStateStack.count, 1)
        
        //Push another view. Expect stack size to be 2
        expectationPushModalCompletionManager = self.expectation(description: "expectationPushModalCompletionManager")
        state = OXMModalState(view: OXMWebView(),adConfiguration:OXMAdConfiguration(), displayProperties:OXMInterstitialDisplayProperties(), onStatePopFinished: { [weak self] poppedState in
            self?.modalManagerDidFinishPop(poppedState)
            }, onStateHasLeftApp: { [weak self] leavingState in
                self?.modalManagerDidLeaveApp(leavingState)
                
        })
        modalManager.pushModal(state, fromRootViewController:mockVC, animated:true, shouldReplace:false, completionHandler:{
            expectationPushModalCompletionManager.fulfill()
        })
        self.waitForExpectations(timeout: 4.0, handler: nil)
        OXMAssertEq(modalManager.modalStateStack.count, 2)
        
        //Pop once
        self.expectationModalManagerDidFinishPop = self.expectation(description: "expectationModalManagerDidFinishPop")
        modalManager.popModal()
        self.waitForExpectations(timeout: 3.0, handler:nil)
        OXMAssertEq(modalManager.modalStateStack.count, 1)
        
        //Pop again
        self.expectationModalManagerDidFinishPop = self.expectation(description: "expectationModalManagerDidFinishPop")
        modalManager.popModal()
        self.waitForExpectations(timeout: 3.0, handler:nil)
        OXMAssertEq(modalManager.modalStateStack.count, 0)
        
        //Pop again with empty stack
        modalManager.popModal()
        OXMAssertEq(modalManager.modalStateStack.count, 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute:{
            let log = OXMLog.singleton.getLogFileAsString()
            XCTAssert(log.contains("popModal called on empty modalStateStack!"))
        })
    }
    
    func testDismissAllInterstitialsIfAny() {
        let modalManager = OXMModalManager()
        OXMAssertEq(modalManager.modalViewController, nil)
        OXMAssertEq(modalManager.modalStateStack.count, 0)
        
        //ViewControllers are picky about being presented in a windowless environment.
        //This Mock simulates a dismiss.
        modalManager.modalViewControllerClass = MockOXMModalViewController.self
        let mockVC = MockViewController()
        
        //Push a view.
        var expectationPushModalCompletionManager = self.expectation(description: "expectationPushModalCompletionManager")
        var state = OXMModalState(view: OXMWebView(),
                                  adConfiguration:OXMAdConfiguration(),
                                  displayProperties:OXMInterstitialDisplayProperties(),
                                  onStatePopFinished: { [weak self] poppedState in
                                      self?.modalManagerDidFinishPop(poppedState)
                                      }, onStateHasLeftApp: { [weak self] leavingState in
                                          self?.modalManagerDidLeaveApp(leavingState)
                                          
                                  })
        modalManager.pushModal(state,
                               fromRootViewController:mockVC,
                               animated:true,
                               shouldReplace:false,
                               completionHandler:{
            expectationPushModalCompletionManager.fulfill()
        })
        self.waitForExpectations(timeout: 4.0, handler: nil)
        OXMAssertEq(modalManager.modalStateStack.count, 1)
        
        //Push another view. Expect stack size to be 2
        expectationPushModalCompletionManager = self.expectation(description: "expectationPushModalCompletionManager")
        state = OXMModalState(view: OXMWebView(),
                              adConfiguration:OXMAdConfiguration(),
                              displayProperties:OXMInterstitialDisplayProperties(),
                              onStatePopFinished: { [weak self] poppedState in
                                  self?.modalManagerDidFinishPop(poppedState)
                                  }, onStateHasLeftApp: { [weak self] leavingState in
                                      self?.modalManagerDidLeaveApp(leavingState)
                                      
                              })
        modalManager.pushModal(state,
                               fromRootViewController:mockVC,
                               animated:true,
                               shouldReplace:false,
                               completionHandler:{
            expectationPushModalCompletionManager.fulfill()
        })
        self.waitForExpectations(timeout: 4.0, handler: nil)
        OXMAssertEq(modalManager.modalStateStack.count, 2)
        
        self.expectationModalManagerDidFinishPop = self.expectation(description: "expectationModalManagerDidFinishPop")
        modalManager.dismissAllInterstitialsIfAny()
        self.waitForExpectations(timeout: 4.0, handler: nil)
        OXMAssertEq(modalManager.modalViewController, nil)
        OXMAssertEq(modalManager.modalStateStack.count, 0)
    }
    
    func testHideShow() {
        let modalManager = OXMModalManager()
        OXMAssertEq(modalManager.modalViewController, nil)
        OXMAssertEq(modalManager.modalStateStack.count, 0)
        
        //ViewControllers are picky about being presented in a windowless environment.
        //This Mock simulates a dismiss.
        modalManager.modalViewControllerClass = MockOXMModalViewController.self
        
        //Create a MockVC to present from. This will prevent complaints that we don't have an Application or keyWindow.
        let mockVC = MockViewController()
        mockVC.expectationDidPresentViewController = self.expectation(description: "expectationDidPresentViewController")
        
        //Push a view. Expect that the mock VC will be asked to present a ModalViewController and that afterwards the stack will be size 1
        var expectationPushModalCompletionManager = self.expectation(description: "expectationPushModalCompletionManager")
        
        let state = OXMModalState(view: OXMWebView(), adConfiguration:OXMAdConfiguration(), displayProperties:OXMInterstitialDisplayProperties(),
        onStatePopFinished: { [weak self] poppedState in
            self?.modalManagerDidFinishPop(poppedState)
            }, onStateHasLeftApp: { [weak self] leavingState in
                self?.modalManagerDidLeaveApp(leavingState)
                
        })
        modalManager.pushModal(state, fromRootViewController:mockVC, animated:true, shouldReplace:false, completionHandler:{
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
            OXMAssertEq(modalManager.modalStateStack.count, 1)
        })
        
        self.waitForExpectations(timeout: 4.0, handler: nil)
    }
    
    func testModalViewControllerDidLeaveApp() {
        let modalManager = OXMModalManager()
        modalManager.modalViewControllerClass = MockOXMModalViewController.self

        let mockVC = MockViewController()
        mockVC.expectationDidPresentViewController = self.expectation(description: "expectationDidPresentViewController")
        
        let expectationPushModalCompletionManager = self.expectation(description: "expectationPushModalCompletionManager")
        
        let state = OXMModalState(view: OXMWebView(), adConfiguration:OXMAdConfiguration(), displayProperties:OXMInterstitialDisplayProperties(),
        onStatePopFinished: { [weak self] poppedState in
            self?.modalManagerDidFinishPop(poppedState)
            }, onStateHasLeftApp: { [weak self] leavingState in
                self?.modalManagerDidLeaveApp(leavingState)
                
        })
        modalManager.pushModal(state, fromRootViewController:mockVC, animated:true, shouldReplace:false, completionHandler:{
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
        let defaultState = OXMModalState(view: OXMWebView(), adConfiguration:OXMAdConfiguration(), displayProperties:OXMInterstitialDisplayProperties(), onStatePopFinished: nil, onStateHasLeftApp: nil)
        XCTAssertEqual(defaultState.mraidState, .notEnabled)
        presentationFrom(defaultState) { controller in
            XCTAssertTrue(controller!.isMember(of: OXMModalViewController.self))
        }
    }
    
    func testPresentNonModalViewController() {
        let resizedState = OXMModalState(view: OXMWebView(), adConfiguration:OXMAdConfiguration(), displayProperties:OXMInterstitialDisplayProperties(), onStatePopFinished: nil, onStateHasLeftApp: nil)
        resizedState.mraidState = OXMMRAIDState.resized
        XCTAssertEqual(resizedState.mraidState, .resized)
        presentationFrom(resizedState) { controller in
            XCTAssertTrue(controller!.isMember(of: OXMNonModalViewController.self))
        }
    }
    
    func presentationFrom(_ state: OXMModalState, completion: ((UIViewController?) -> Void)?)  {
        let mockVC = MockViewController()
        mockVC.expectationDidPresentViewController = self.expectation(description: "expectationDidPresentViewController")
        
        let modalManager = OXMModalManager()
        OXMAssertEq(modalManager.modalViewController, nil)
        OXMAssertEq(modalManager.modalStateStack.count, 0)
        
        //Push OXMNonModalViewController
        let expectationPushModalCompletionManager = self.expectation(description: "expectationPushModalCompletionManager")
        modalManager.pushModal(state, fromRootViewController:mockVC, animated:true, shouldReplace:false, completionHandler:{
            expectationPushModalCompletionManager.fulfill()
            OXMAssertEq(modalManager.modalStateStack.count, 1)            
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
        let modalManager = OXMModalManager()
        modalManager.forceOrientation(UIInterfaceOrientation.portrait)
    }
    
    func testOxmDescription() {
        let modalManager = OXMModalManager()
        
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


