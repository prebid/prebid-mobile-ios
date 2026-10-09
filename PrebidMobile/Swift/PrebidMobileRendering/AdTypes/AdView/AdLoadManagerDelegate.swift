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

@objc(PBMAdLoadManagerDelegate) @_spi(PBMInternal) public
protocol AdLoadManagerDelegate {
    @objc(loadManager:didLoadTransaction:)
    func loadManager(_ loadManager: AdLoadManagerProtocol, didLoad transaction: Transaction)

    // The transaction is nil when the failure happens before one was created (e.g. the VAST request failed).
    // Note: TransactionDelegate.transactionFailedToLoad passes a non-optional transaction.
    @objc(loadManager:failedToLoadTransaction:error:)
    func loadManager(_ loadManager: AdLoadManagerProtocol, failedToLoad transaction: Transaction?, error: Error)
}
