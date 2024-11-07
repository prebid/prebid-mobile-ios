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
    
    private var timeInterval: TimeInterval
    private var timer: Timer?
    
    private var targetViewSearchClassNames: [String]
    private var targetViewControllerSearchClassName: String
    
    init(
        timeInterval: TimeInterval = 1.0,
        targetViewSearchClassNames: [String] = ["GADWebAdView", "GADCloseButton"],
        targetViewControllerSearchClassName: String = "GADFullScreenAdViewController"
    ) {
        self.timeInterval = timeInterval
        self.targetViewSearchClassNames = targetViewSearchClassNames
        self.targetViewControllerSearchClassName = targetViewControllerSearchClassName
    }
    
    deinit {
        stop()
    }
    
    func start() {
        let timer = Timer.scheduledTimer(
            timeInterval: timeInterval,
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
        if let presentedVC = UIWindow.topViewController {
            // printSubviews(of: presentedVC.view)
            
            // => GADFullScreenAdViewController
            print("LOG: presentedVC \(String(describing: type(of: presentedVC)))")
            
            let presentedVCClassName = String(describing: type(of: presentedVC))
            let isGADViewController = presentedVCClassName == targetViewControllerSearchClassName
            
            print("LOG: isGADViewController \(isGADViewController)")
            
            // => GADWebAdView
            // => GADCloseButton
            let gadViews = targetViewSearchClassNames.compactMap {
                searchSubviews(of: presentedVC.view, targetClassName: $0)
            }
            
            if isGADViewController && gadViews.count == targetViewSearchClassNames.count {
                print("LOG: GMA View Controller was found!")
                stop()
            }
        }
    }
    
    // MARK: - Helpers
    
    private func searchSubviews(of view: UIView, targetClassName: String) -> UIView? {
        let viewClassName = String(describing: type(of: view))
        
        if viewClassName == targetClassName {
            return view
        }
        
        for subview in view.subviews {
            if let foundView = searchSubviews(of: subview, targetClassName: targetClassName) {
                return foundView
            }
        }
        
        return nil
    }
    
    private func printSubviews(of view: UIView, level: Int = 0) {
        let indentation = String(repeating: "-", count: level)
        print("\(indentation) \(type(of: view))")
        
        for subview in view.subviews {
            printSubviews(of: subview, level: level + 1)
        }
    }
}
