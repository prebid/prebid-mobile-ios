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

public typealias WinNotifierBlock = (_ bid: Bid, _ adMarkupConsumer: @escaping AdMarkupStringHandler) -> Void

@_spi(PBMInternal) public
typealias WinNotifierFactoryBlock = (_ connection: PrebidServerConnectionProtocol) -> WinNotifierBlock

@objc(PBMWinNotifier) @_spi(PBMInternal) public
protocol WinNotifier {
    init()
    
    static var factoryBlock: WinNotifierFactoryBlock { get }
    
    static func notifyThroughConnection(_ connection: PrebidServerConnectionProtocol,
                                        winningBid: Bid,
                                        callback: @escaping AdMarkupStringHandler)
    
    static func winNotifierBlock(connection: PrebidServerConnectionProtocol) -> WinNotifierBlock
    
    static func cacheUrl(fromTargeting targeting: [String : String], idKey: String) -> String?
}
