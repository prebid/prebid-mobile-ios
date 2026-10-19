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

// `CreativeViewabilityTracker` is the name of the protocol, so the class takes an `Impl` suffix.
// Replaces the ObjC `PBMCreativeViewabilityTracker_Objc`: `Factory.createCreativeViewabilityTracker` constructs it
// directly, no `NSClassFromString` lookup.
final class CreativeViewabilityTrackerImpl: NSObject, CreativeViewabilityTracker {

    private let pollingTimeInterval: TimeInterval
    private let onExposureChange: ViewExposureChangeHandler
    // Nil when the creative has no view: the ObjC checker then reported zero exposure forever.
    private let checker: ViewExposureChecker?
    private var timer: TimerInterface?
    private var lastExposure: ViewExposure = Factory.ViewExposureType.zeroExposure()
    private weak var testedView: UIView?
    private var isViewabilityMode = false

    private init(optionalView view: UIView?,
                 pollingTimeInterval: TimeInterval,
                 onExposureChange: @escaping ViewExposureChangeHandler) {
        checker = view.map { ViewExposureChecker(view: $0) }
        self.pollingTimeInterval = pollingTimeInterval
        self.onExposureChange = onExposureChange
        testedView = view
        super.init()
    }

    convenience init(view: UIView, pollingTimeInterval: TimeInterval, onExposureChange: @escaping ViewExposureChangeHandler) {
        self.init(optionalView: view, pollingTimeInterval: pollingTimeInterval, onExposureChange: onExposureChange)
    }

    convenience init(creative: AbstractCreative) {
        // `?? 0` keeps the ObjC nil-messaging result for a model without an ad configuration.
        self.init(optionalView: creative.view,
                  pollingTimeInterval: creative.creativeModel.adConfiguration?.pollFrequency ?? 0) { [weak creative] tracker, viewExposure in
            guard let creative, let impl = tracker as? CreativeViewabilityTrackerImpl else {
                return
            }
            let isVisible = impl.isVisibleView(impl.testedView)
            creative.onViewabilityChanged(isVisible, viewExposure: viewExposure)
        }
        isViewabilityMode = true
    }

    deinit {
        stop()
    }

    func start() {
        stop()
        let timerFactory = WeakTimerTargetBox.scheduledTimerFactory(withWeakifiedTarget: Timer.pbmScheduledTimerFactory())
        timer = timerFactory(pollingTimeInterval, self, #selector(checkViewability), nil, true)
    }

    func stop() {
        timer?.invalidate()
    }

    // Selector target of the polling timer, so it exists in Release too; only the protocol requirement is DEBUG-only.
    @objc func checkViewability() {
        // Don't waste time on exposure calculation when it's not needed.
        if isViewabilityMode {
            onExposureChange(self, lastExposure)
            return
        }
        // TODO: check visibility using viewableDuration and area in future
        checkExposure(force: false)
    }

    func checkExposure(force isForce: Bool) {
        let newExposure = checker?.exposure ?? Factory.ViewExposureType.zeroExposure()

        if isForce || !newExposure.isEqual(lastExposure) {
            lastExposure = newExposure
            onExposureChange(self, newExposure)
        }
    }

    private func isVisibleView(_ view: UIView?) -> Bool {
#if DEBUG
        if Prebid.forcedIsViewable {
            return true
        }
#endif
        guard let view else {
            return false
        }
        return view.isVisible(inViewLegacy: view.superview) && view.window != nil
    }
}
