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
import UIKit
import OMSDK_Prebidorg

/// Implements `EventTrackerProtocol` according to the OM specification.
///
/// `internal`: the ObjC original was a private header, never public API. It conforms to the public `EventTrackerProtocol`.
class OpenMeasurementEventTracker: NSObject, EventTrackerProtocol {

    var session: OMIDPrebidorgAdSession?

    var adEvents: OMIDPrebidorgAdEvents?
    var mediaEvents: OMIDPrebidorgMediaEvents?

    // The ObjC class inherited a plain `init` (no session, no events). Tests and mocks rely on it.
    override init() {
        super.init()
    }

    init(session: OMIDPrebidorgAdSession) {
        self.session = session
        super.init()
        initOMEventTrackers()
    }

    // MARK: - EventTrackerProtocol

    func trackEvent(_ event: TrackingEvent) {
        guard session != nil else {
            Log.error("Measurement Session is missed.")
            return
        }

        switch event {
        case .loaded         : trackAdLoaded()
        case .impression     : trackImpression()

        case .click          : mediaEvents?.adUserInteraction(withType: .click)
        case .companionClick : mediaEvents?.adUserInteraction(withType: .click)

        case .firstQuartile  : mediaEvents?.firstQuartile()
        case .midpoint       : mediaEvents?.midpoint()
        case .thirdQuartile  : mediaEvents?.thirdQuartile()
        case .complete       : mediaEvents?.complete()
        case .pause          : mediaEvents?.pause()
        case .resume         : mediaEvents?.resume()
        case .skip           : mediaEvents?.skipped()

        // Are not supported in the current implementation. All video ads are shown in fullscreen mode without options.
        case .fullscreen     : mediaEvents?.playerStateChange(to: .fullscreen)
        case .exitFullscreen : mediaEvents?.playerStateChange(to: .normal)
        case .normal         : mediaEvents?.playerStateChange(to: .normal)
        case .collapse       : mediaEvents?.playerStateChange(to: .collapsed)
        case .expand         : mediaEvents?.playerStateChange(to: .expanded)

        default:
            break
        }
    }

    func trackVideoAdLoaded(_ parameters: VideoVerificationParameters) {
        do {
            let vastProperties = OMIDPrebidorgVASTProperties(autoPlay: parameters.autoPlay, position: .standalone)
            try adEvents?.loaded(with: vastProperties)
        } catch {
            Log.error(error.localizedDescription)
        }
    }

    func trackStartVideo(duration: TimeInterval, volume: Double) {
        mediaEvents?.start(withDuration: CGFloat(duration), mediaPlayerVolume: CGFloat(volume))
    }

    // The ObjC original ignored `deviceVolume`; kept.
    func trackVolumeChanged(playerVolume: Double, deviceVolume: Double) {
        mediaEvents?.volumeChange(to: CGFloat(playerVolume))
    }

    // MARK: - Internal

    func trackAdLoaded() {
        do {
            try adEvents?.loaded()
        } catch {
            Log.error(error.localizedDescription)
        }
    }

    func trackImpression() {
        do {
            try adEvents?.impressionOccurred()
        } catch {
            Log.error("Open Measurement can't track impression with error: \(error.localizedDescription)")
        }
    }

    private func initOMEventTrackers() {
        guard let session else {
            return
        }

        do {
            adEvents = try OMIDPrebidorgAdEvents(adSession: session)
        } catch {
            Log.error("Open Measurement can't create ad events with error: \(error.localizedDescription)")
        }

        if session.configuration.mediaEventsOwner == .nativeOwner {
            do {
                mediaEvents = try OMIDPrebidorgMediaEvents(adSession: session)
            } catch {
                Log.error("Open Measurement can't create video events with error: \(error.localizedDescription)")
            }
        }
    }
}
