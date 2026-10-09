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

// ObjC name and init selector preserved so the runtime class name stays stable; only TransactionFactoryImpl constructs it now.
@objc(PBMDisplayTransactionFactory) @_spi(PBMInternal) public
class DisplayTransactionFactory: NSObject, TransactionDelegate {

    private let bid: Bid
    private let adConfiguration: AdUnitConfig
    private let connection: PrebidServerConnectionProtocol

    // NOTE: need to call the completion callback only in the main thread
    // use onFinished(transaction:error:)
    private let callback: TransactionFactoryCallback

    private var transaction: Transaction?

    private var isLoading: Bool {
        transaction != nil
    }

    // MARK: - Public API

    @objc(initWithBid:adConfiguration:connection:callback:)
    public init(
        bid: Bid,
        adConfiguration: AdUnitConfig,
        connection: PrebidServerConnectionProtocol,
        callback: @escaping TransactionFactoryCallback
    ) {
        self.bid = bid
        self.adConfiguration = adConfiguration
        self.connection = connection
        self.callback = callback
        super.init()
    }

    @objc(loadWithAdMarkup:)
    @discardableResult
    public func load(adMarkup: String) -> Bool {
        if isLoading {
            return false
        }

        loadHTMLTransaction(adMarkup: adMarkup)

        return true
    }

    // MARK: - TransactionDelegate

    public func transactionReadyForDisplay(_ transaction: Transaction) {
        self.transaction = nil
        onFinished(transaction: transaction, error: nil)
    }

    public func transactionFailedToLoad(_ transaction: Transaction, error: Error) {
        self.transaction = nil
        onFinished(transaction: nil, error: error)
    }

    // MARK: - Private Helpers

    private func loadHTMLTransaction(adMarkup: String) {
        let creativeModels = [
            htmlCreativeModel(bid: bid, adMarkup: adMarkup, adConfiguration: adConfiguration)
        ]

        let newTransaction = Factory.createTransaction(
            serverConnection: connection,
            adConfiguration: adConfiguration.adConfiguration,
            models: creativeModels
        )
        transaction = newTransaction

        newTransaction.bid = bid

        newTransaction.delegate = self
        newTransaction.startCreativeFactory()
    }

    private func htmlCreativeModel(bid: Bid, adMarkup: String, adConfiguration: AdUnitConfig) -> CreativeModel {
        let model = CreativeModel(adConfiguration: adConfiguration.adConfiguration)

        model.html = adMarkup
        model.width = Int(bid.size.width)
        model.height = Int(bid.size.height)
        model.expirationInterval = bid.exp
        return model
    }

    private func onFinished(transaction: Transaction?, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.callback(transaction, error)
        }
    }
}
