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
    
    private weak var window: UIWindow?
    
    private var timer: Timer?
    private var checkInterval: TimeInterval
    
    private var targetViewClassName: String
    private var targetViewControllerClassName: String
    
    private var onTargetInterstitialPresented: ((UIView) -> Void)?
    
    init(
        checkInterval: TimeInterval = 1.0,
        targetViewClassName: String = "GADWebAdView",
        targetViewControllerClassName: String = "GADFullScreenAdViewController",
        window: UIWindow?,
        onTargetInterstitialPresented: ((UIView) -> Void)? = nil
    ) {
        self.checkInterval = checkInterval
        self.targetViewClassName = targetViewClassName
        self.targetViewControllerClassName = targetViewControllerClassName
        self.window = window
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
        guard let presentedVC = window?.topViewController else {
            return
        }
        
        let presentedVCClassName = String(describing: type(of: presentedVC))
        let isTargetViewController = presentedVCClassName == targetViewControllerClassName
        
        let targetAdView = presentedVC.view.searchSubviews(targetClassName: targetViewClassName)
        
        if let targetAdView, isTargetViewController {
            stop()
            onTargetInterstitialPresented?(targetAdView)
        }
    }
}
