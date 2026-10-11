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

@objc(PBMVideoViewPlaybackState) @_spi(PBMInternal) public
enum VideoViewPlaybackState: Int {
    case unstarted = 0
    case playing
    // Paused explicitly, e.g. while a clickthrough overlay
    // (App Store / SafariViewController) is presented.
    // Playback is resumed explicitly as well - by the overlay's exit handler.
    case paused
    // Paused automatically because the app resigned active.
    // The only state that is auto-resumed when the app becomes active again.
    case pausedByBackground
    // Paused automatically because the ad view left the viewport,
    // e.g. it was scrolled off-screen.
    // Auto-resumed when the ad becomes viewable again.
    case pausedByVisibility
    case finished
}
