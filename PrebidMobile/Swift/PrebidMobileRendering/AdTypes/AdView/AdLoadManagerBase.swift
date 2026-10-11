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
@objc(PBMAdLoadManagerBase) @_spi(PBMInternal) public
class AdLoadManagerBase: NSObject, AdLoadManagerProtocol {

    @objc public weak var adLoadManagerDelegate: AdLoadManagerDelegate?
    @objc public var connection: PrebidServerConnectionProtocol
    @objc public var adConfiguration: AdConfiguration
    @objc public var bid: Bid
    @objc public var dispatchQueue: DispatchQueue

    private var currentTransaction: Transaction?

    // `required` because AdLoadManagerProtocol declares this initializer and the VAST subclass and the test mock inherit it.
    // The ObjC `PBMAssert(connection)` is gone: the parameter is non-optional and every caller is Swift.
    @objc(initWithBid:connection:adConfiguration:)
    public required init(bid: Bid, connection: PrebidServerConnectionProtocol, adConfiguration: AdConfiguration) {
        self.bid = bid
        self.connection = connection
        self.adConfiguration = adConfiguration
        self.dispatchQueue = DispatchQueue(label: "PBMAdLoadManager")
        super.init()
    }

    @objc(makeCreativesWithCreativeModels:)
    public func makeCreatives(creativeModels: [CreativeModel]) {
        for model in creativeModels {
            model.expirationInterval = bid.exp
        }

        // Create the transaction(s)
        // Currently, we only handle one transaction.
        let transaction = Factory.createTransaction(
            serverConnection: connection,
            adConfiguration: adConfiguration,
            models: creativeModels
        )
        currentTransaction = transaction

        transaction.bid = bid

        transaction.delegate = self

        transaction.startCreativeFactory()
    }

    @objc(requestCompletedFailure:)
    public func requestCompletedFailure(_ error: Error) {
        Log.whereAmI()

        adLoadManagerDelegate?.loadManager(self, failedToLoad: nil, error: error)
    }

    // MARK: - TransactionDelegate

    public func transactionReadyForDisplay(_ transaction: Transaction) {
        adLoadManagerDelegate?.loadManager(self, didLoad: transaction)

        // When transaction is ready we should pass it to the receiver and release the property in this class.
        // Transaction is not needed in the load manager anymore.
        currentTransaction = nil
    }

    // The delegate method takes an optional transaction, so the non-optional one passes straight through.
    public func transactionFailedToLoad(_ transaction: Transaction, error: Error) {
        adLoadManagerDelegate?.loadManager(self, failedToLoad: transaction, error: error)
    }
}
