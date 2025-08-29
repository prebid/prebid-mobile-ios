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

@objc(PBMCreativeViewDelegate) @_spi(PBMInternal) public
protocol CreativeViewDelegate: NSObjectProtocol {
    func creativeDidComplete(_ creative: AbstractCreative)
    func creativeDidDisplay(_ creative: AbstractCreative)
    func creativeWasClicked(_ creative: AbstractCreative)
    func creativeViewWasClicked(_ creative: AbstractCreative)
    func creativeClickthroughDidClose(_ creative: AbstractCreative)
    func creativeInterstitialDidClose(_ creative: AbstractCreative)
    func creativeInterstitialDidLeaveApp(_ creative: AbstractCreative)
    func creativeFullScreenDidFinish(_ creative: AbstractCreative)
    
    // Rewarded Ad Only
    func creativeDidSendRewardedEvent(_ creative: AbstractCreative)
    
    // MRAID Only
    func creativeReadyToReimplant(_ creative: AbstractCreative)
    func creativeMraidDidCollapse(_ creative: AbstractCreative)
    func creativeMraidDidExpand(_ creative: AbstractCreative)
    
    // Video specific method
    @objc optional func videoCreativeDidComplete(_ creative: AbstractCreative)
    @objc optional func videoWasMuted(_ creative: AbstractCreative)
    @objc optional func videoWasUnmuted(_ creative: AbstractCreative)
    @objc optional func videoDidResume(_ creative: AbstractCreative)
    @objc optional func videoDidPause(_ creative: AbstractCreative)

}
