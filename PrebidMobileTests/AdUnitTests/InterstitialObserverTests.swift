/*   Copyright 2018-2024 Prebid.org, Inc.
 
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

fileprivate class DummyView: UIView {}
fileprivate class DummyViewController: UIViewController {}

final class InterstitialObserverTests: XCTestCase {
    
    func testCheckPresentedViewControllerInvokesCallbackWhenTargetPresented() {
        let expectation = expectation(description: "onTargetInterstitialPresented should be called")
        
        let window = UIWindow()
        
        let observer = InterstitialObserver(
            targetViewClassName: "DummyView",
            targetViewControllerClassName: "DummyViewController",
            window: window,
            onTargetInterstitialPresented: { view in
                expectation.fulfill()
            })
        
        
        let mockTargetVC = DummyViewController()
        let mockTargetView = DummyView()
        
        mockTargetVC.view.addSubview(mockTargetView)
        window.rootViewController = mockTargetVC
        
        observer.start()
        wait(for: [expectation], timeout: 5.0)
        observer.stop()
    }
    
    func testCheckPresentedViewControllerDoesNotInvokeCallbackWhenNoMatch() {
        let expectation = expectation(description: "onTargetInterstitialPresented should not be called")
        expectation.isInverted = true
        
        let window = UIWindow()
        
        let observer = InterstitialObserver(
            targetViewClassName: "DummyView",
            targetViewControllerClassName: "DummyViewController",
            window: window,
            onTargetInterstitialPresented: { view in
                expectation.fulfill()
            })
        
        
        let vc = UIViewController()
        let view = UIView()
        
        vc.view.addSubview(view)
        window.rootViewController = vc
        
        observer.start()
        wait(for: [expectation], timeout: 5.0)
        observer.stop()
    }
}
