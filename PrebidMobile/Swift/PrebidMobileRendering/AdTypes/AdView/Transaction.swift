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

@objc(PBMTransaction) @_spi(PBMInternal) public
protocol Transaction: NSObjectProtocol {
    var adConfiguration: AdConfiguration { get } // If need to change use resetAdConfiguration
    var creatives: [AbstractCreative] { get set }
    var creativeModels: [CreativeModel] { get set }
    var measurementSession: OMSession { get set }
    var measurementWrapper: OMSessionWrapper { get set }
    
    var bid: Bid? { get set }
    
    weak var delegate: TransactionDelegate? { get set }
    
    init(serverConnection: PrebidServerConnectionProtocol,
         adConfiguration: AdConfiguration,
         models: [CreativeModel])
    
    func startCreativeFactory()
    func getAdDetails() -> AdDetails?
    func getFirstCreative() -> AbstractCreative?
    func getCreative(after: AbstractCreative) -> AbstractCreative?
    func revenueForCreative(after: AbstractCreative) -> String?
    func resetAdConfiguration(_ adConfiguration: AdConfiguration)
    
#if DEBUG
    // Expose objc impl method to swift for tests
    func updateAdConfiguration()
#endif
}
