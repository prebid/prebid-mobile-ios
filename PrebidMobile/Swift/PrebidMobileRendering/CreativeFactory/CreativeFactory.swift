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

// Runs one `CreativeFactoryJob` per creative model of the transaction and reports when all of them succeeded or one failed.
final class CreativeFactory {

    typealias FinishedCallback = ([AbstractCreative]?, Error?) -> Void

    private let serverConnection: PrebidServerConnectionProtocol
    // Strong, as in the ObjC original: the transaction owns this factory until the callback fires and drops it.
    private let transaction: Transaction
    private var jobs = [CreativeFactoryJob]()
    private let finishedCallback: FinishedCallback
    private let dispatchQueue = DispatchQueue(label: "PBMCreativeFactory_\(UUID().uuidString)")

    init(serverConnection: PrebidServerConnectionProtocol,
         transaction: Transaction,
         finishedCallback: @escaping FinishedCallback) {
        self.serverConnection = serverConnection
        self.transaction = transaction
        self.finishedCallback = finishedCallback
    }

    func start() {
        jobs = convertCreativeModels()

        if jobs.isEmpty {
            let error = PBMError.error(message: "PBMCreativeFactory: There were no jobs for processing",
                                       type: PBMErrorType.internalError)
            finishedCallback(nil, error)
            return
        }

        for job in jobs {
            job.start()
        }
    }

    private func convertCreativeModels() -> [CreativeFactoryJob] {
        transaction.creativeModels.map { model in
            CreativeFactoryJob(creativeModel: model,
                               transaction: transaction,
                               serverConnection: serverConnection) { [weak self] _, error in
                guard let self else { return }

                self.onFinishedJob(error: error)
            }
        }
    }

    private func onFinishedJob(error: Error?) {
        dispatchQueue.async { [weak self] in
            guard let self else { return }

            if let error {
                Log.info("PBMCreativeFactory: \((error as NSError).description)")
                self.finishedCallback(nil, error)
                return
            }

            if self.allJobsSucceeded() {
                // A job reaches `.success` only after `succeed(with:)` stored its creative, so nothing is dropped here.
                self.finishedCallback(self.jobs.compactMap { $0.creative }, nil)
            }
        }
    }

    private func allJobsSucceeded() -> Bool {
        jobs.allSatisfy { $0.state == .success }
    }
}
