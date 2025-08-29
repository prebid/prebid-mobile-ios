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

import UIKit

/// A protocol for handling events related to banner video playback events.
@objc(PBMBannerViewVideoPlaybackDelegate)
public protocol BannerViewVideoPlaybackDelegate: NSObjectProtocol {
    /// Notifies the delegate that banner video ad has been paused.
    @objc func videoPlaybackDidPause(_ banner: BannerView)
    /// Notifies the delegate that banner video ad has been resumed.
    @objc func videoPlaybackDidResume(_ banner: BannerView)
    
    /// Notifies the delegate that banner video ad has been muted.
    @objc func videoPlaybackWasMuted(_ banner: BannerView)
    /// Notifies the delegate that banner video ad has been unmuted.
    @objc func videoPlaybackWasUnmuted(_ banner: BannerView)
    /// Notifies the delegate that banner video ad has completed.
    @objc func videoPlaybackDidComplete(_ banner: BannerView)
}
