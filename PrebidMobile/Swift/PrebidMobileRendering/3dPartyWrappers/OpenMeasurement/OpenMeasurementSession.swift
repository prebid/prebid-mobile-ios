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

/// Wraps an OMID ad session. `internal`: the ObjC original was a private header, never public API, so OMID types stay
/// out of the public surface. It conforms to the public `OMSession` protocol, which is all other code sees.
class OpenMeasurementSession: NSObject, OMSession {

    var session: OMIDPrebidorgAdSession?

    private(set) var eventTracker: EventTrackerProtocol

    // MARK: - Initialization

    /// Fails when OMSDK can't create the ad session (the ObjC original set `self = nil`).
    init?(context: OMIDPrebidorgAdSessionContext, configuration: OMIDPrebidorgAdSessionConfiguration) {
        let adSession: OMIDPrebidorgAdSession
        do {
            adSession = try OMIDPrebidorgAdSession(configuration: configuration, adSessionContext: context)
        } catch {
            Log.error("Unable to create Open Measurement session with error: \(error.localizedDescription)")
            return nil
        }

        session = adSession

        // IMPORTANT: Event tracker must be created before session start
        // Otherwise, tracking of video events will be unavailable.
        eventTracker = OpenMeasurementEventTracker(session: adSession)

        super.init()
    }

    deinit {
        // According to OM requirements, the WebView should live at least 1 sec to send all needed events.
        // https://interactiveadvertisingbureau.github.io/Open-Measurement-SDKiOS/#7-stop-the-session

        // The local keeps the view alive: `stop()` below drops the session, and `mainAdView` is a weak property.
        let view = session?.mainAdView
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withExtendedLifetime(view) {}
        }

        stop()
    }

    // MARK: - OMSession

    func start() {
        guard let session else {
            Log.error("Measurement Session is missed.")
            return
        }

        session.start()
    }

    func addFriendlyObstruction(_ friendlyObstruction: UIView, purpose: OpenMeasurementFriendlyObstructionPurpose) {
        guard let session else {
            Log.error("Measurement Session is missed.")
            return
        }

        let convertedPurpose = OpenMeasurementFriendlyObstructionTypeBridge.obstructionType(of: purpose)
        let detailedReason = OpenMeasurementFriendlyObstructionTypeBridge.describe(purpose)

        addFriendlyObstruction(friendlyObstruction, obstructionType: convertedPurpose, detailedReason: detailedReason)
    }

    private var genericBridgedErrorDomain: String { "Foundation._GenericObjCError" }

    /// OMID returns NO *without* an error object when the session has finished or the view was already added (MRAID
    /// re-adds the same views on resize/expand). Swift's `try` turns that bare NO into a generic error.
    func addFriendlyObstruction(_ friendlyObstruction: UIView,
                                obstructionType: OMIDFriendlyObstructionType,
                                detailedReason: String?) {
        guard let session else {
            Log.error("Measurement Session is missed.")
            return
        }

        do {
            try session.addFriendlyObstruction(friendlyObstruction, purpose: obstructionType, detailedReason: detailedReason)
        } catch {
            // A bare NO surfaces as Swift's generic error (domain `Foundation._GenericObjCError`, code 0, empty userInfo);
            // a genuine OMID error carries the `com.omid.library` domain.
            guard (error as NSError).domain != genericBridgedErrorDomain else {
                return
            }
            Log.error(error.localizedDescription)
        }
    }

    // MARK: - Methods

    func setupMainView(_ mainView: UIView) {
        guard let session else {
            Log.error("Measurement Session is missed.")
            return
        }

        session.mainAdView = mainView
    }

    func stop() {
        guard let session else {
            Log.error("Measurement Session is missed.")
            return
        }

        session.finish()
        self.session = nil
    }
}
