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

/// Transitional: the class is `public` only because the ObjC `PBMOpenMeasurementWrapper` still constructs it. It becomes
/// `internal` once the wrapper is ported. No OMID type appears in a public signature.
@objc(PBMOpenMeasurementSession)
public class OpenMeasurementSession: NSObject, OMSession {

    var session: OMIDPrebidorgAdSession?

    public private(set) var eventTracker: EventTrackerProtocol

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

    /// Transitional seam for the ObjC wrapper: takes the OMID objects as `NSObject` so no OMID type is public.
    @objc(initWithContext:configuration:)
    public convenience init?(omidContext: NSObject, omidConfiguration: NSObject) {
        guard let context = omidContext as? OMIDPrebidorgAdSessionContext,
              let configuration = omidConfiguration as? OMIDPrebidorgAdSessionConfiguration else {
            return nil
        }
        self.init(context: context, configuration: configuration)
    }

    /// A session without an OMID session behind it. Exists so tests can subclass the session.
    override init() {
        eventTracker = OpenMeasurementEventTracker()
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

    public func start() {
        guard let session else {
            Log.error("Measurement Session is missed.")
            return
        }

        session.start()
    }

    public func addFriendlyObstruction(_ friendlyObstruction: UIView, purpose: OpenMeasurementFriendlyObstructionPurpose) {
        guard let session else {
            Log.error("Measurement Session is missed.")
            return
        }

        let convertedPurpose = OpenMeasurementFriendlyObstructionTypeBridge.obstructionType(of: purpose)
        let detailedReason = OpenMeasurementFriendlyObstructionTypeBridge.describe(purpose)

        do {
            try session.addFriendlyObstruction(friendlyObstruction, purpose: convertedPurpose, detailedReason: detailedReason)
        } catch {
            Log.error(error.localizedDescription)
        }
    }

    // MARK: - Methods

    @objc(setupMainView:)
    public func setupMainView(_ mainView: UIView) {
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
