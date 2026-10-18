/*   Copyright 2018-2021 Prebid.org, Inc.

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

final class WindowLocker {

    private(set) var isLocked = false

    private weak var window: UIWindow?
    private weak var measurementSession: OMSession?
    private weak var lockingView: UIView?
    private let serialLockerQueue = DispatchQueue(label: "PBMWindowLocker")

    init(window: UIWindow?, measurementSession: OMSession?) {
        self.window = window
        self.measurementSession = measurementSession
    }

    func lock() {
        serialLockerQueue.async {
            DispatchQueue.main.async {
                if self.isLocked {
                    Log.error("Attempting to lock already locked window locker.")
                    return
                }
                guard let lockingView = self.lockingView ?? self.buildLockingView() else {
                    Log.error("Failed to create window locking view.")
                    return
                }
                self.lockingView = lockingView
                // ObjC messaged a deallocated (nil) window as a no-op and still marked the locker as locked.
                if let window = self.window {
                    window.addSubview(lockingView)
                    window.addConstraints([
                        NSLayoutConstraint(item: window, attribute: .width, relatedBy: .equal, toItem: lockingView, attribute: .width, multiplier: 1, constant: 0),
                        NSLayoutConstraint(item: window, attribute: .height, relatedBy: .equal, toItem: lockingView, attribute: .height, multiplier: 1, constant: 0),
                        NSLayoutConstraint(item: window, attribute: .centerX, relatedBy: .equal, toItem: lockingView, attribute: .centerX, multiplier: 1, constant: 0),
                        NSLayoutConstraint(item: window, attribute: .centerY, relatedBy: .equal, toItem: lockingView, attribute: .centerY, multiplier: 1, constant: 0)
                    ])
                }

                self.isLocked = true
            }
        }
    }

    func unlock() {
        serialLockerQueue.async {
            DispatchQueue.main.async {
                if !self.isLocked {
                    Log.error("Attempting to unlock already unlocked window locker.")
                    return
                }
                self.lockingView?.removeFromSuperview()
                self.isLocked = false
            }
        }
    }

    private func buildLockingView() -> UIView? {
        guard let window else {
            return nil
        }

        let backgroundView = UIView(frame: window.bounds)
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.startAnimating()

        backgroundView.addSubview(activityIndicatorView)
        backgroundView.addConstraints([
            NSLayoutConstraint(item: backgroundView, attribute: .centerX, relatedBy: .equal, toItem: activityIndicatorView, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: backgroundView, attribute: .centerY, relatedBy: .equal, toItem: activityIndicatorView, attribute: .centerY, multiplier: 1, constant: 0)
        ])

        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false

        // FIXME: Customize dark appearance
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        activityIndicatorView.color = UIColor.white

        measurementSession?.addFriendlyObstruction(backgroundView, purpose: .windowLockerBackground)
        measurementSession?.addFriendlyObstruction(activityIndicatorView, purpose: .windowLockerActivityIndicator)

        return backgroundView
    }
}
