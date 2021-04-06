//
//  OXMModalPresentationControllerTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest
@testable import OpenXApolloSDK

class OXMModalPresentationControllerTest: XCTestCase, UIViewControllerTransitioningDelegate {
    
    var modalState: OXMModalState?
    var modalPresentationController: OXMModalPresentationController?
    var expectationPresentationController:XCTestExpectation!
    
    func testDelegateInit() {
        
        let presentedVC = UIViewController()
        presentedVC.modalPresentationStyle = .custom;
        presentedVC.transitioningDelegate = self;
        
        XCTAssertNil(modalState)
        modalState = OXMModalState(view: OXMWebView(), adConfiguration:OXMAdConfiguration(), displayProperties:OXMInterstitialDisplayProperties(), onStatePopFinished: nil, onStateHasLeftApp: nil)
        XCTAssertNil(modalPresentationController)
        
        expectationPresentationController = self.expectation(description: "expectationPresentationController")

        let rootVC = UIViewController()
        rootVC.present(presentedVC, animated: true)
        
        self.waitForExpectations(timeout: 3.0, handler: nil)

        XCTAssertNotNil(modalPresentationController)
    }
    
    func testFrameOfPresentedViewInContainerView() {
        
        let suggestedFrame = CGRect(x: 0, y: 0, width: 300, height: 200)
        
        let modalPresentationController = OXMModalPresentationController(presentedViewController: UIViewController(), presenting: UIViewController())
        XCTAssertNotEqual(suggestedFrame, modalPresentationController.frameOfPresentedView)        
        modalPresentationController.frameOfPresentedView = suggestedFrame

        let frameOfPresentedViewInContainerView = modalPresentationController.frameOfPresentedViewInContainerView
        let frameOfPresentedView = modalPresentationController.frameOfPresentedView
        
        XCTAssertEqual(frameOfPresentedViewInContainerView, suggestedFrame)
        XCTAssertEqual(frameOfPresentedViewInContainerView, frameOfPresentedView)
    }
    
    //MARK - UIViewControllerTransitioningDelegate
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        modalPresentationController = OXMModalPresentationController(presentedViewController: presented, presenting: presenting)
        
        expectationPresentationController.fulfill()

        return modalPresentationController
    }
}
