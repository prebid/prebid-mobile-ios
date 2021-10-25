//
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


import Foundation
import StoreKit

@available(iOS 14.5, *)
@objcMembers
public class PBMSkadnEventTracker: NSObject, PBMEventTrackerProtocol {
    
    let imp: SKAdImpression
    
    public init(with imp: SKAdImpression) {
        self.imp = imp
    }
    
    deinit {
        SKAdNetwork.endImpression(imp) { error in
            if let error = error {
                PBMLog.error(error.localizedDescription)
            }
        }
    }
    
    public func trackEvent(_ event: PBMTrackingEvent) {
        switch event {
        case .impression:
            SKAdNetwork.startImpression(imp) { error in
                if let error = error {
                    PBMLog.error(error.localizedDescription)
                }
            }
        default:
            break
        }
    }
    
    public func trackVideoAdLoaded(_ parameters: PBMVideoVerificationParameters!) {
        
    }
    
    public func trackStartVideo(withDuration duration: CGFloat, volume: CGFloat) {
        
    }
    
    public func trackVolumeChanged(_ playerVolume: CGFloat, deviceVolume: CGFloat) {
        
    }
}
