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

// Replaces the ObjC `PBMTransactionFactory_Objc`. `Factory.createTransactionFactory` constructs it directly,
// so it needs no `@objc(...)` runtime name or `NSClassFromString` lookup.
final class TransactionFactoryImpl: NSObject, TransactionFactory {

    private let bid: Bid
    private let adConfiguration: AdUnitConfig
    private let connection: PrebidServerConnectionProtocol

    // NOTE: need to call the completion callback only in the main thread
    // use onFinished(transaction:error:)
    private let callback: TransactionFactoryCallback

    private var currentFactory: NSObject?

    private var isLoading: Bool {
        currentFactory != nil
    }

    // MARK: - Public API

    init(
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

    @discardableResult
    func load(adMarkup: String) -> Bool {
        if isLoading {
            return false
        }

        if adMarkup.contains("<VAST") {
            return loadVASTTransaction(adMarkup: adMarkup)
        } else {
            return loadHTMLTransaction(adMarkup: adMarkup)
        }
    }

    // MARK: - Private Helpers

    private func loadHTMLTransaction(adMarkup: String) -> Bool {
        let factory = DisplayTransactionFactory(
            bid: bid,
            adConfiguration: adConfiguration,
            connection: connection,
            callback: callbackForProperFactory()
        )
        currentFactory = factory
        return factory.load(adMarkup: adMarkup)
    }

    private func loadVASTTransaction(adMarkup: String) -> Bool {
        let factory = VastTransactionFactory(
            bid: bid,
            connection: connection,
            adConfiguration: adConfiguration.adConfiguration,
            callback: callbackForProperFactory()
        )
        currentFactory = factory
        return factory.load(adMarkup: adMarkup)
    }

    private func callbackForProperFactory() -> TransactionFactoryCallback {
        { [weak self] transaction, error in
            guard let self else { return }

            self.onFinished(transaction: transaction, error: error)
        }
    }

    private func onFinished(transaction: Transaction?, error: Error?) {
        currentFactory = nil
        callback(transaction, error)
    }
}
