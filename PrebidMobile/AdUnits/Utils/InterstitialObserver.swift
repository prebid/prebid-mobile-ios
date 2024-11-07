/*   Copyright 2018-2024 Prebid.org, Inc.

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

import UIKit

/// A class that schedules a timer that checks if VC and views of particular type are presented.
class InterstitialObserver {
    
    private var timer: Timer?
    private var checkInterval: TimeInterval
    
    private var targetViewClassName: String
    private var targetViewControllerClassName: String
    
    private var onTargetInterstitialPresented: ((UIView) -> Void)?
    
    init(
        checkInterval: TimeInterval = 1.0,
        targetViewClassName: String = "GADWebAdView",
        targetViewControllerClassName: String = "GADFullScreenAdViewController",
        onTargetInterstitialPresented: ((UIView) -> Void)? = nil
    ) {
        self.checkInterval = checkInterval
        self.targetViewClassName = targetViewClassName
        self.targetViewControllerClassName = targetViewControllerClassName
        self.onTargetInterstitialPresented = onTargetInterstitialPresented
    }
    
    deinit {
        stop()
    }
    
    func start() {
        let timer = Timer.scheduledTimer(
            timeInterval: checkInterval,
            target: self,
            selector: #selector(checkPresentedViewController),
            userInfo: nil,
            repeats: true
        )
        
        self.timer = timer
        
        RunLoop.main.add(timer, forMode: .common)
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func checkPresentedViewController() {
        // FIXME: when publisher loads multiple interstitials at the same time - how do we know which one is presented ?
        
        if let presentedVC = UIWindow.topViewController {
            // printSubviews(of: presentedVC.view)
            
            // => GADFullScreenAdViewController
            print("LOG: presentedVC \(String(describing: type(of: presentedVC)))")
            
            let presentedVCClassName = String(describing: type(of: presentedVC))
            let isGADViewController = presentedVCClassName == targetViewControllerClassName
            
            print("LOG: isGADViewController \(isGADViewController)")
            
            // => GADWebAdView
            let gadAdView = presentedVC.view.searchSubviews(targetClassName: targetViewClassName)
            
            if let gadAdView, isGADViewController {
                print("LOG: GMA View Controller was found!")
                stop()
                onTargetInterstitialPresented?(gadAdView)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func printSubviews(of view: UIView, level: Int = 0) {
        let indentation = String(repeating: "-", count: level)
        print("\(indentation) \(type(of: view))")
        
        for subview in view.subviews {
            printSubviews(of: subview, level: level + 1)
        }
    }
}
