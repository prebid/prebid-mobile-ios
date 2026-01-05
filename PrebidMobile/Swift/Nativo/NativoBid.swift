//
// Copyright 2018-2025 Prebid.org, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import UIKit

@objcMembers
public class NativoBid: Bid {

    override init(bid: ORTBBid<ORTBBidExt>) {
        super.init(bid: bid)
    }

    // MARK: Overrides to avoid ext.prebid dependency

    // Always render as banner for Nativo
    public override var adFormat: AdFormat? {
        return .banner
    }

    // Force plugin renderer selection to Nativo
    public override var pluginRendererName: String? {
        return NativoPrebidRenderer.NAME
    }

    public override var pluginRendererVersion: String? {
        return NativoPrebidRenderer.VERSION
    }

    // Not used for rendering; return nil for Nativo
    public override var targetingInfo: [String : String]? {
        return nil
    }

    public override var meta: [String : Any]? {
        return nil
    }

    public override var videoAdConfiguration: ORTBAdConfiguration? {
        return nil
    }

    public override var rewardedConfig: ORTBRewardedConfiguration? {
        return nil
    }

    public override var events: ORTBExtPrebidEvents? {
        return nil
    }
    
    public override var isWinning: Bool {
        return true
    }
}
