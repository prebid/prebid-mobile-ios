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

// Replaces the ObjC `PBMVastTransactionFactory`; only `TransactionFactoryImpl` constructs it.
final class VastTransactionFactory: NSObject, AdLoadManagerDelegate {

    private let connection: PrebidServerConnectionProtocol
    private let adConfiguration: AdConfiguration
    private let bid: Bid

    // NOTE: need to call the completion callback only in the main thread
    // use onFinished(transaction:error:)
    private let callback: TransactionFactoryCallback

    private var vastLoadManager: AdLoadManagerVAST?

    private var isLoading: Bool {
        vastLoadManager != nil
    }

    // MARK: - Public API

    init(
        bid: Bid,
        connection: PrebidServerConnectionProtocol,
        adConfiguration: AdConfiguration,
        callback: @escaping TransactionFactoryCallback
    ) {
        self.bid = bid
        self.adConfiguration = adConfiguration
        self.connection = connection
        self.callback = callback
        super.init()
    }

    @discardableResult
    func load(adMarkup: String) -> Bool {
        if isLoading {
            return false
        }

        return loadVASTTransaction(adMarkup: adMarkup)
    }

    // MARK: - AdLoadManagerDelegate

    func loadManager(_ loadManager: AdLoadManagerProtocol, didLoad transaction: Transaction) {
        onFinished(transaction: transaction, error: nil)
    }

    // The transaction is Optional on the delegate protocol (nil when the failure precedes its creation); the ObjC ignored it too.
    func loadManager(_ loadManager: AdLoadManagerProtocol, failedToLoad transaction: Transaction?, error: Error) {
        onFinished(transaction: nil, error: error)
    }

    // MARK: - Private Helpers

    private func loadVASTTransaction(adMarkup: String) -> Bool {
        let loadManager = AdLoadManagerVAST(bid: bid, connection: connection, adConfiguration: adConfiguration)
        vastLoadManager = loadManager
        loadManager.adLoadManagerDelegate = self
        loadManager.load(from: adMarkup)
        return true
    }

    private func onFinished(transaction: Transaction?, error: Error?) {
        vastLoadManager = nil
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            self.callback(transaction, error)
        }
    }
}
