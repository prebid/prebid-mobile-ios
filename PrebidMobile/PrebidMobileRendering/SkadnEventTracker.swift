/*   Copyright 2018-2019 Prebid.org, Inc.

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
import StoreKit

@available(iOS 14.5, *)
@objc(PBMSkadnEventTracker) @objcMembers
public class SkadnEventTracker: NSObject, PBMEventTrackerProtocol {
    
    let imp: SKAdImpression
    
    public init(with imp: SKAdImpression) {
        self.imp = imp
    }
    
    // MARK: - PBMEventTrackerProtocol
    
    public func trackEvent(_ event: PBMTrackingEvent) {
        switch event {
        case .impression:
            executeImpressionTask()
        default:
            break
        }
    }
    
    private func executeImpressionTask() {
        let arrayOfTasks = [
            ImpressionTask(task: { (completion) in
                SKAdNetwork.startImpression(self.imp, completionHandler: { error in
                    if let error = error {
                        Log.error(error.localizedDescription)
                    }
                })
                completion()
            }, delayInterval: 5),
            ImpressionTask(task: { (completion) in
                SKAdNetwork.endImpression(self.imp, completionHandler: { error in
                    if let error = error {
                        Log.error(error.localizedDescription)
                    }
                })
                completion()
            }, delayInterval: 0)
        ]
        
        ImpressionTasksExecutor.shared.add(tasks: arrayOfTasks)
    }
    
    public func trackVideoAdLoaded(_ parameters: PBMVideoVerificationParameters!) {
        
    }
    
    public func trackStartVideo(withDuration duration: CGFloat, volume: CGFloat) {
        
    }
    
    public func trackVolumeChanged(_ playerVolume: CGFloat, deviceVolume: CGFloat) {
        
    }
}
