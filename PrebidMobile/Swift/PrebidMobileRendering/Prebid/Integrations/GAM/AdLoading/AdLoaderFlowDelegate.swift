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
    
@objc(PBMAdLoaderFlowDelegate) @_spi(PBMInternal) public
protocol AdLoaderFlowDelegate {
    
    func adLoader(_ adLoader: AdLoaderProtocol, loadedPrimaryAd adObject: AnyObject, adSize: NSValue?)
    func adLoader(_ adLoader: AdLoaderProtocol, failedWithPrimarySDKError error: Error?)
    func adLoader(_ adLoader: AdLoaderProtocol, failedWithPrebidError error: Error?)
    func adLoaderDidWinPrebid(_ adLoader: AdLoaderProtocol)
    func adLoaderLoadedPrebidAd(_ adLoader: AdLoaderProtocol)
}
