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

import UIKit
import RxSwift
import PrebidMobile

final class AppConfiguration: NSObject {
    private let keyUseMockServer = "KeyUseMockServer"
    static let shared = AppConfiguration()
    
    private override init() {}
    
    var isAppStatusBarHidden = true
    private lazy var useMockServerSubject = BehaviorSubject<Bool>(value: useMockServer)
    lazy var useMockServerObservable = useMockServerSubject.asObservable()
    var useMockServer: Bool {
        get {
            return UserDefaults.standard.bool(forKey: keyUseMockServer)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: keyUseMockServer)
            useMockServerSubject.onNext(newValue)
        }
    }
    var isGDPREnabled: Bool {
        get { IABConsentHelper.isGDPREnabled }
        set { IABConsentHelper.isGDPREnabled = newValue }
    }
    
    var adPosition: AdPosition?
    var videoPlacementType: VideoPlacementType?
    var adUnitContext: [(key: String, value: String)]?
    var userData: [(key: String, value: String)]?
    var appContentData: [(key: String, value: String)]?
}
