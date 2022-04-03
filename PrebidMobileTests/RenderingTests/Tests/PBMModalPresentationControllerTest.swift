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

import XCTest
@testable import PrebidMobile

class PBMModalPresentationControllerTest: XCTestCase, UIViewControllerTransitioningDelegate {
    
    var modalState: PBMModalState?
    var modalPresentationController: PBMModalPresentationController?
    var expectationPresentationController:XCTestExpectation!
    
    func testDelegateInit() {
        
        let presentedVC = UIViewController()
        presentedVC.modalPresentationStyle = .custom;
        presentedVC.transitioningDelegate = self;
        
        XCTAssertNil(modalState)
        modalState = PBMModalState(view: PBMWebView(), adConfiguration:AdConfiguration(), displayProperties:PBMInterstitialDisplayProperties(), onStatePopFinished: nil, onStateHasLeftApp: nil)
        XCTAssertNil(modalPresentationController)
        
        expectationPresentationController = self.expectation(description: "expectationPresentationController")
        
        let rootVC = UIViewController()
        rootVC.present(presentedVC, animated: true)
        
        self.waitForExpectations(timeout: 3.0, handler: nil)
        
        XCTAssertNotNil(modalPresentationController)
    }
    
    func testFrameOfPresentedViewInContainerView() {
        
        let suggestedFrame = CGRect(x: 0, y: 0, width: 300, height: 200)
        
        let modalPresentationController = PBMModalPresentationController(presentedViewController: UIViewController(), presenting: UIViewController())
        XCTAssertNotEqual(suggestedFrame, modalPresentationController.frameOfPresentedView)
        modalPresentationController.frameOfPresentedView = suggestedFrame
        
        let frameOfPresentedViewInContainerView = modalPresentationController.frameOfPresentedViewInContainerView
        let frameOfPresentedView = modalPresentationController.frameOfPresentedView
        
        XCTAssertEqual(frameOfPresentedViewInContainerView, suggestedFrame)
        XCTAssertEqual(frameOfPresentedViewInContainerView, frameOfPresentedView)
    }
    
    //MARK - UIViewControllerTransitioningDelegate
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        modalPresentationController = PBMModalPresentationController(presentedViewController: presented, presenting: presenting)
        
        expectationPresentationController.fulfill()
        
        return modalPresentationController
    }
}
