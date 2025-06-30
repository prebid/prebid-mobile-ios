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

/// Timer that stops in background and resumes in foreground. Fires callback on timer completion.
/// Can execute only one task at a time.
@objc(PBMBackgroundAwareTimer) @objcMembers
public class BackgroundAwareTimer: NSObject {
    
    private(set) var isRunning: Bool
    private var remainingTime: TimeInterval
    private var startTime: Date?
    private var completion: (() -> Void)?
    
    private var gcdItem: DispatchWorkItem?
    
    public override init() {
        self.remainingTime = 0
        self.isRunning = false
        
        super.init()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    deinit {
        invalidateTimer()
    }
    
    public func startTimer(with interval: TimeInterval, completion: @escaping () -> Void) {
        guard !isRunning else { return }
        
        startTime = Date()
        remainingTime = interval
        self.completion = completion
        
        let gcdItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            completion()
            self.invalidateTimer()
        }
        
        self.gcdItem = gcdItem
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + remainingTime,
            execute: gcdItem
        )
        
        isRunning = true
    }
    
    public func invalidateTimer() {
        gcdItem = nil
        completion = nil
        isRunning = false
        NotificationCenter.default.removeObserver(self)
    }
    
    private func stopTimer() {
        guard isRunning else { return }
        
        gcdItem?.cancel()
        gcdItem = nil
        remainingTime -= Date().timeIntervalSince(startTime ?? Date())
        isRunning = false
    }
    
    @objc private func applicationDidEnterBackground() {
        stopTimer()
    }
    
    @objc private func applicationWillEnterForeground() {
        if let completion, !isRunning && remainingTime > 0 {
            startTimer(with: remainingTime, completion: completion)
        }
    }
}
