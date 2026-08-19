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

import Foundation

@objc(PBMWeakTimerTargetBox)
public class WeakTimerTargetBox: NSObject {

    private weak var weakTarget: AnyObject?
    private let aSelector: Selector

    @objc(initWithWeakTarget:aSelector:)
    public init(weakTarget: AnyObject, selector: Selector) {
        self.weakTarget = weakTarget
        self.aSelector  = selector
        super.init()
    }

    @objc(onTimerFired:)
    public func onTimerFired(_ timer: TimerInterface) {
        guard let target = weakTarget else {
            timer.invalidate()
            return
        }
        if target.responds(to: aSelector) {
            target.perform(aSelector, with: timer)
        } else {
            timer.invalidate()
        }
    }

    @objc(scheduledTimerFactoryWithWeakifiedTarget:)
    public static func scheduledTimerFactory(
        withWeakifiedTarget factory: @escaping (TimeInterval, AnyObject, Selector, Any?, Bool) -> TimerInterface
    ) -> (TimeInterval, AnyObject, Selector, Any?, Bool) -> TimerInterface {
        return { timeInterval, target, selector, userInfo, repeats in
            let box = WeakTimerTargetBox(weakTarget: target, selector: selector)
            return factory(timeInterval, box, #selector(WeakTimerTargetBox.onTimerFired(_:)), userInfo, repeats)
        }
    }
}
