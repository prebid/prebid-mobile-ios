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

// ObjC name preserved so the runtime class name stays stable; no ObjC code references or subclasses it any more.
@objc(PBMAdLoadManagerVAST) @_spi(PBMInternal) public
class AdLoadManagerVAST: AdLoadManagerBase {

    private var creativeModelCollectionMaker: CreativeModelCollectionMakerVAST?
    private var adRequester: AdRequesterVAST?

    @objc(loadFromString:)
    public func load(from vastString: String) {
        dispatchQueue.async { [weak self] in
            guard let self else {
                Log.error("PBMAdLoadManagerVast is nil!")
                return
            }

            if self.prepareForLoading() {
                self.adRequester?.buildAdsArray(Data(vastString.utf8))
            }
        }
    }

    private func prepareForLoading() -> Bool {
        if adRequester != nil {
            Log.error("Previous load is in progress. Load() ignored.")
            return false
        }

        let requester = AdRequesterVAST(serverConnection: connection, adConfiguration: adConfiguration)
        requester.adLoadManager = self
        adRequester = requester

        creativeModelCollectionMaker = CreativeModelCollectionMakerVAST(
            serverConnection: connection,
            adConfiguration: adConfiguration
        )
        return true
    }

    @objc(requestCompletedSuccess:)
    public func requestCompletedSuccess(_ adRequestResponse: AdRequestResponseVAST) {
        Log.whereAmI()

        // The maker exists once loading has started. Before that the ObjC messaged nil, which was a silent no-op.
        creativeModelCollectionMaker?.makeModels(
            adRequestResponse,
            successCallback: { [weak self] creativeModels in
                guard let self else {
                    Log.error("PBMAdLoadManagerVAST is nil!")
                    return
                }

                self.makeCreatives(creativeModels: creativeModels)
            },
            failureCallback: { [weak self] error in
                guard let self else {
                    Log.error("PBMAdLoadManagerVAST is nil!")
                    return
                }

                self.adLoadManagerDelegate?.loadManager(self, failedToLoad: nil, error: error)
            }
        )
    }
}
