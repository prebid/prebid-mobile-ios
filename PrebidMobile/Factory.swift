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

@objc(PBMFactory) @_spi(PBMInternal) public
class Factory: NSObject {
    static let bidRequesterType: BidRequester.Type = {
        NSClassFromString("PBMBidRequester_Objc") as! BidRequester.Type
    }()
    
    @objc public static func createBidRequester(connection: PrebidServerConnectionProtocol,
                                                sdkConfiguration: Prebid,
                                                targeting: Targeting,
                                                adUnitConfiguration: AdUnitConfig) -> BidRequester {
        bidRequesterType.init(connection: connection,
                              sdkConfiguration: sdkConfiguration,
                              targeting: targeting,
                              adUnitConfiguration: adUnitConfiguration)
    }
    
    @objc public static let WinNotifierType: WinNotifier.Type = {
        NSClassFromString("PBMWinNotifier_Objc") as! WinNotifier.Type
    }()
    
    @objc public static func createWinNotifier() -> WinNotifier {
        WinNotifierType.init()
    }
}

