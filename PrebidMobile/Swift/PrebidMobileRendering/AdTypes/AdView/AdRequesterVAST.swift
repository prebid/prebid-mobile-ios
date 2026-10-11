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

import Foundation

// ObjC name preserved so the runtime class name stays stable; no ObjC code references it any more.
@objc(PBMAdRequesterVAST) @_spi(PBMInternal) public
class AdRequesterVAST: NSObject {

    @objc public var adConfiguration: AdConfiguration
    @objc public var serverConnection: PrebidServerConnectionProtocol
    // Weak: the load manager owns the requester (see AdLoadManagerVAST.adRequester).
    @objc public weak var adLoadManager: AdLoadManagerVAST?

    private var adsBuilder: VastAdsBuilder?

    @objc(initWithServerConnection:adConfiguration:)
    public init(serverConnection: PrebidServerConnectionProtocol, adConfiguration: AdConfiguration) {
        self.serverConnection = serverConnection
        self.adConfiguration = adConfiguration
        super.init()
    }

    // MARK: - Internal Methods

    // Not declared in the ObjC header and without callers (the ObjC `-load` next to it was an empty stub);
    // ported line for line so `VastRequester.loadVastURL` keeps its one production user.
    func loadVASTURL(_ url: String) {
        VastRequester.loadVastURL(url, connection: serverConnection) { [weak self] serverResponse, error in
            guard let self else {
                Log.error("PBMAdRequesterVAST is nil")
                return
            }

            if let error {
                self.adLoadManager?.requestCompletedFailure(error)
            } else {
                self.buildAdsArray(serverResponse?.rawData ?? Data())
            }
        }
    }

    @objc(buildVastAdsArray:)
    public func buildAdsArray(_ rawVASTData: Data) {
        if adsBuilder != nil {
            Log.error("Loading of VAST is failed. Ads Builder is not intended to be re-used.")
            return
        }

        let builder = VastAdsBuilder(connection: serverConnection)
        adsBuilder = builder
        builder.buildAds(rawVASTData) { [weak self] ads, error in
            guard let self else {
                Log.error("PBMAdRequesterVAST is nil")
                return
            }

            if let error {
                self.adLoadManager?.requestCompletedFailure(error)
                return
            }

            let adRequestResponseVast = AdRequestResponseVAST()
            adRequestResponseVast.ads = ads
            self.adLoadManager?.requestCompletedSuccess(adRequestResponseVast)

            self.adsBuilder = nil
        }
    }
}
