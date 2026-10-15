/*   Copyright 2018-2025 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation

// `Transaction` is the name of the protocol, so the class takes an `Impl` suffix, like `ModalStateImpl` / `AdViewManagerImpl`.
// Replaces the ObjC `PBMTransaction_Objc`: `Factory.createTransaction` constructs it directly, no `NSClassFromString` lookup.
final class TransactionImpl: NSObject, Transaction {

    private(set) var adConfiguration: AdConfiguration
    var creatives = [AbstractCreative]()
    var creativeModels: [CreativeModel]
    // Stays nil until the first creative creates the session (see `createOpenMeasurementSessionForFirstCreative`).
    var measurementSession: OMSession?
    var measurementWrapper: OMSessionWrapper
    var bid: Bid?
    weak var delegate: TransactionDelegate?

    private let serverConnection: PrebidServerConnectionProtocol
    private var creativeFactory: CreativeFactory?

    init(serverConnection: PrebidServerConnectionProtocol,
         adConfiguration: AdConfiguration,
         models: [CreativeModel]) {
        self.serverConnection = serverConnection
        self.adConfiguration = adConfiguration
        creativeModels = models
        measurementWrapper = Factory.openMeasurementWrapper
        super.init()
    }

    func startCreativeFactory() {
        let finishedCallback: CreativeFactory.FinishedCallback = { [weak self] creatives, error in
            guard let self else { return }

            self.creativeFactory = nil
            if let error {
                self.delegate?.transactionFailedToLoad(self, error: error)
            } else if let creatives {
                self.creatives = creatives
                self.createOpenMeasurementSessionForFirstCreative()
                self.updateAdConfiguration()
                self.delegate?.transactionReadyForDisplay(self)
            }
        }

        let factory = CreativeFactory(serverConnection: serverConnection, transaction: self, finishedCallback: finishedCallback)
        creativeFactory = factory
        factory.start()
    }

    func getAdDetails() -> AdDetails? {
        getFirstCreative()?.creativeModel.adDetails
    }

    // Return the first item in the list. If list is empty return nil.
    func getFirstCreative() -> AbstractCreative? {
        creatives.first
    }

    // Returns the creative after the current creative.
    // Returns nil if the creative is the last one on the list.
    func getCreative(after creative: AbstractCreative) -> AbstractCreative? {
        if creative === creatives.last {
            return nil
        }

        // Identity, like `-indexOfObject:` for creatives (they do not override `isEqual:`); the first occurrence wins.
        guard let index = creatives.firstIndex(where: { $0 === creative }) else {
            return getFirstCreative()
        }

        // return the next creative
        return creatives[index + 1]
    }

    func revenueForCreative(after creative: AbstractCreative) -> String? {
        let targetCreative = getCreative(after: creative) ?? creative
        return targetCreative.creativeModel.revenue
    }

    func resetAdConfiguration(_ adConfiguration: AdConfiguration) {
        self.adConfiguration = adConfiguration
        for creativeModel in creativeModels {
            creativeModel.adConfiguration = adConfiguration
        }
    }

    // MARK: - Internal

    func updateAdConfiguration() {
        // Update ad size in configuration from first creative model
        if let firstCreativeModel = creativeModels.first {
            adConfiguration.size = CGSize(width: firstCreativeModel.width, height: firstCreativeModel.height)
        }
    }

    // MARK: - Private

    private func createOpenMeasurementSessionForFirstCreative() {
        let creative = getFirstCreative()
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            if let creative, self.measurementSession == nil {
                creative.createOpenMeasurementSession()
            }
        }
    }
}
