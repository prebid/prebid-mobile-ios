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

class PBMModalAnimatorTest: XCTestCase {
    
    var expectation:XCTestExpectation?
    
    func testPresentVC() {
        let frame = CGRect(x: 10.0, y: 10.0, width: 320.0, height: 50.0);
        let modalAnimator = PBMModalAnimator(frameOfPresentedView: frame)
        
        XCTAssertFalse(modalAnimator.isPresented)
        XCTAssertNil(modalAnimator.modalPresentationController)
        
        let presentedVC = UIViewController()
        presentedVC.modalPresentationStyle = .custom;
        presentedVC.transitioningDelegate = modalAnimator;
        let rootVC = UIViewController()
        
        //prevent "Attempt to present <UIViewController: > on <UIViewController: > whose view is not in the window hierarchy!"
        //warning
        let window = UIWindow(frame: frame)
        window.rootViewController = rootVC
        window.makeKeyAndVisible()
        
        rootVC.present(presentedVC, animated: true)
        
        //to hold a weak ref to PBMModalAnimator.modalPresentationController
        let weakRefHolder = modalAnimator.modalPresentationController

        Thread.sleep(forTimeInterval: 2)
        
        XCTAssertTrue(modalAnimator.isPresented)
        XCTAssertNotNil(weakRefHolder)
        XCTAssertNotNil(modalAnimator.modalPresentationController)
    }
    
    func testPresentationController() {
        
        let presentingViewController = UIViewController()
        let presentedViewController = UIViewController()
        
        let frame = CGRect(x: 10.0, y: 10.0, width: 320.0, height: 50.0);
        let modalAnimator = PBMModalAnimator(frameOfPresentedView: frame)
        XCTAssertFalse(modalAnimator.isPresented)

        let presentationController = modalAnimator.presentationController(forPresented: presentedViewController, presenting: presentingViewController, source: UIViewController())
        XCTAssertNotNil(presentationController)
        XCTAssertTrue(presentationController?.presentingViewController == presentingViewController)
        XCTAssertTrue(presentationController?.presentedViewController == presentedViewController)
        XCTAssertTrue(modalAnimator.isPresented)
    }
    
    func testControllerTransitioningDelegate() {
        let frame = CGRect(x: 10.0, y: 10.0, width: 320.0, height: 50.0);
        let modalAnimator = PBMModalAnimator(frameOfPresentedView: frame)
        XCTAssertFalse(modalAnimator.isPresented)
        
        var result = modalAnimator.animationController(forPresented: UIViewController(), presenting: UIViewController(), source: UIViewController())
        XCTAssertEqual(modalAnimator, result as! PBMModalAnimator)
        XCTAssertTrue(modalAnimator.isPresented)
        
        result = modalAnimator.animationController(forDismissed: UIViewController())
        XCTAssertEqual(modalAnimator, result as! PBMModalAnimator)
        XCTAssertFalse(modalAnimator.isPresented)
    }
    
    func testControllerAnimatedTransitioning() {
        let frame = CGRect(x: 10.0, y: 10.0, width: 320.0, height: 50.0);
        let modalAnimator = PBMModalAnimator(frameOfPresentedView: frame)
        XCTAssertFalse(modalAnimator.isPresented)
        
        modalAnimator.isPresented = true
        modalAnimator.animationEnded(false)
        XCTAssertFalse(modalAnimator.isPresented)
        
        let controllerContextTransitioning = MockUIViewControllerContextTransitioning()
        let interval = modalAnimator.transitionDuration(using: controllerContextTransitioning)
        let roundInterval = round(interval * 100) / 100
        XCTAssertEqual(roundInterval, 0.3)
    }
    
    func testAnimateTransition() {
        
        let controllerContextTransitioning = MockUIViewControllerContextTransitioning()
        controllerContextTransitioning.mock_completeTransition = { (_) in
            self.expectation?.fulfill()
        }
        
        // isPresented is false
        expectation = self.expectation(description: "Expected completeTransition isPresented false")
        
        let frame = CGRect(x: 10.0, y: 10.0, width: 320.0, height: 50.0);
        let modalAnimator = PBMModalAnimator(frameOfPresentedView: frame)
        XCTAssertFalse(modalAnimator.isPresented)
        
        modalAnimator.animateTransition(using: controllerContextTransitioning)
        waitForExpectations(timeout: 1)
        
        // isPresented is true
        modalAnimator.isPresented = true
        XCTAssertTrue(modalAnimator.isPresented)
        expectation = self.expectation(description: "Expected completeTransition isPresented true")
        modalAnimator.animateTransition(using: controllerContextTransitioning)
        waitForExpectations(timeout: 1)
    }
}


class MockUIViewControllerContextTransitioning: NSObject, UIViewControllerContextTransitioning {
   
    var containerView = UIView()
    var isAnimated = false
    var isInteractive = true
    var transitionWasCancelled = false
    var presentationStyle = UIModalPresentationStyle.custom
    
    var toViewController = UIViewController()
    var fromViewController = UIViewController()
    
    func updateInteractiveTransition(_ percentComplete: CGFloat) {
        
    }
    
    func finishInteractiveTransition() {
        
    }
    
    func cancelInteractiveTransition() {
        
    }
    
    func pauseInteractiveTransition() {
        
    }
    
    var mock_completeTransition: ((Bool) -> Void)?
    func completeTransition(_ didComplete: Bool) {
        self.mock_completeTransition?(didComplete)
    }
    
    func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
        var vc = toViewController
        switch key {
        case UITransitionContextViewControllerKey.to:
            vc = toViewController
        case UITransitionContextViewControllerKey.from:
            vc = fromViewController
        default:
            vc = UIViewController()
        }
        return vc
    }
    
    func view(forKey key: UITransitionContextViewKey) -> UIView? {
        var view = toViewController.view
        switch key {
        case UITransitionContextViewKey.to:
            view = toViewController.view
        case UITransitionContextViewKey.from:
            view = fromViewController.view
        default:
            view = UIView()
        }
        return view
    }
    
    var targetTransform: CGAffineTransform = .identity
    
    func initialFrame(for vc: UIViewController) -> CGRect {
        return CGRect.zero
    }
    
    func finalFrame(for vc: UIViewController) -> CGRect {
        return CGRect.zero
    }
}
