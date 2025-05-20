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
    func creativeDidComplete(_ creative: PBMAbstractCreative)
    func creativeDidDisplay(_ creative: PBMAbstractCreative)
    func creativeWasClicked(_ creative: PBMAbstractCreative)
    func creativeViewWasClicked(_ creative: PBMAbstractCreative)
    func creativeClickthroughDidClose(_ creative: PBMAbstractCreative)
    func creativeInterstitialDidClose(_ creative: PBMAbstractCreative)
    func creativeInterstitialDidLeaveApp(_ creative: PBMAbstractCreative)
    func creativeFullScreenDidFinish(_ creative: PBMAbstractCreative)
    
    // Rewarded Ad Only
    func creativeDidSendRewardedEvent(_ creative: PBMAbstractCreative)
    
    // MRAID Only
    func creativeReadyToReimplant(_ creative: PBMAbstractCreative)
    func creativeMraidDidCollapse(_ creative: PBMAbstractCreative)
    func creativeMraidDidExpand(_ creative: PBMAbstractCreative)
    
    // Video specific method
    @objc optional func videoCreativeDidComplete(_ creative: PBMAbstractCreative)
    @objc optional func videoWasMuted(_ creative: PBMAbstractCreative)
    @objc optional func videoWasUnmuted(_ creative: PBMAbstractCreative)
}
