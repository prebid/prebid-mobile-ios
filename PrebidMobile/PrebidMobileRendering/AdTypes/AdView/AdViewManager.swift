//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    

import Foundation

@objc(PBMAdViewManager) @_spi(PBMInternal) public
protocol AdViewManager: CreativeViewDelegate {
        
    var adConfiguration: AdConfiguration { get set }
    var modalManager: PBMModalManager { get set }
    weak var adViewManagerDelegate: PBMAdViewManagerDelegate? { get set }
    var autoDisplayOnLoad: Bool { get set }
    var isCreativeOpened: Bool { get }
    
    var isMuted: Bool { get }
    
    init(connection: PrebidServerConnectionProtocol,
         modalManagerDelegate: PBMModalManagerDelegate?)
    
    func revenueForNextCreative() -> String?
    
    // Indicates whether the manager has all the needed data to show the add.
    // If NO then the show method will not lead to displaying the ad.
    func isAbleToShowCurrentCreative() -> Bool
    
    func show()
    func pause()
    func resume()
    
    func mute()
    func unmute()
    
    func handleExternalTransaction(_ transaction: Transaction)
    
    // Exposed for tests
#if DEBUG
    weak var currentCreative: PBMAbstractCreative? { get set }
    var externalTransaction: Transaction? { get set }
    
    func setupCreative(_ creative: PBMAbstractCreative)
    func setupCreative(_ creative: PBMAbstractCreative, withThread thread: ThreadProtocol)
#endif
}
