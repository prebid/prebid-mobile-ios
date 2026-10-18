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

enum CreativeFactoryJobState: UInt {
    case initialized
    case running
    case success
    case error
}

// Resolves one `CreativeModel` into a creative (HTML or video) and reports the outcome once, on its serial queue.
final class CreativeFactoryJob: NSObject, CreativeResolutionDelegate {

    typealias FinishedCallback = (CreativeFactoryJob, Error?) -> Void

    var creative: AbstractCreative?
    var state = CreativeFactoryJobState.initialized

    private let creativeModel: CreativeModel
    private let finishedCallback: FinishedCallback
    private let serverConnection: PrebidServerConnectionProtocol
    private let transaction: Transaction
    private let dispatchQueue = DispatchQueue(label: "PBMCreativeFactoryJob_\(UUID().uuidString)")

    init(creativeModel: CreativeModel,
         transaction: Transaction,
         serverConnection: PrebidServerConnectionProtocol,
         finishedCallback: @escaping FinishedCallback) {
        self.creativeModel = creativeModel
        self.serverConnection = serverConnection
        self.transaction = transaction
        self.finishedCallback = finishedCallback
        super.init()
    }

    func succeed(with creative: AbstractCreative) {
        self.creative = creative
        dispatchQueue.async { [weak self] in
            guard let self else { return }

            if self.state == .running {
                self.state = .success
                self.finishedCallback(self, nil)
            }
        }
    }

    func fail(with error: Error) {
        dispatchQueue.async { [weak self] in
            guard let self else { return }

            if self.state == .running {
                self.state = .error
                self.finishedCallback(self, error)
            }
        }
    }

    func start() {
        start(timeInterval: getTimeInterval())
    }

    /// For internal use only
    func start(timeInterval: TimeInterval) {
        startTimer(timeInterval: timeInterval)

        dispatchQueue.async { [weak self] in
            guard let self else { return }

            if self.state != .initialized {
                self.fail(with: PBMError.error(message: "PBMCreativeFactoryJob: Tried to start PBMCreativeFactory twice",
                                               type: PBMErrorType.internalError))
                return
            }

            self.state = .running
        }

        // `self` is captured strongly, as in the ObjC original: the job must stay alive until the main-queue hop ran.
        DispatchQueue.main.async {
            guard let adConfiguration = self.creativeModel.adConfiguration else {
                self.fail(with: PBMError.error(message: "PBMCreativeFactoryJob: Undefined creative model",
                                               type: PBMErrorType.internalError))
                return
            }

            // The ObjC original compared the formats by identity (`==` on object pointers); the formats are singletons.
            let adType = adConfiguration.winningBidAdFormat
            if adType === AdFormat.banner || self.creativeModel.isCompanionAd {
                self.attemptAUIDCreative()
            } else if adType === AdFormat.video {
                self.attemptVASTCreative()
            } else if adType == nil {
                Log.error("The winning bid ad format is nil.")
            }
        }
    }

    func attemptVASTCreative() {
        guard let urlString = creativeModel.videoFileURL else {
            fail(with: PBMError.error(description: "PBMCreativeFactoryJob: Could not initialize VideoCreative without videoFileURL"))
            return
        }

        // `NSURL(string:)` like the ObjC `+URLWithString:`: `URL(string: "")` is nil, `NSURL(string: "")` is a valid empty URL.
        guard let url = NSURL(string: urlString) as URL? else {
            fail(with: PBMError.error(description: "Could not create URL from url string: \(urlString)"))
            return
        }

        let downloader = DownloadDataHelper(serverConnection: serverConnection)
        // `self` is captured strongly, as in the ObjC original (no `@weakify`).
        downloader.downloadData(for: url, maxSize: VideoCreative.maxSizeForPreRenderContent) { preloadedData, error in
            if let error {
                self.fail(with: error)
                return
            }

            DispatchQueue.main.async {
                self.initializeVideoCreative(preloadedData)
            }
        }
    }

    func getTimeInterval() -> TimeInterval {
        let adConfiguration = creativeModel.adConfiguration
        if adConfiguration?.winningBidAdFormat === AdFormat.video || adConfiguration?.presentAsInterstitial == true {
            return Prebid.shared.creativeFactoryTimeoutPreRenderContent
        } else {
            return Prebid.shared.creativeFactoryTimeout
        }
    }

    // MARK: - CreativeResolutionDelegate

    func creativeReady(_ creative: AbstractCreative) {
        succeed(with: creative)
    }

    func creativeFailed(_ error: Error) {
        fail(with: error)
    }

    // MARK: - Private

    private func startTimer(timeInterval: TimeInterval) {
        // The ObjC `dispatch_time` turned a `NaN` delay into "now"; `DispatchTime + NaN` would mean "never".
        let delay = timeInterval.isNaN ? 0 : timeInterval
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self else { return }

            self.fail(with: PBMError.error(message: "PBMCreativeFactoryJob: Failed to complete in specified time interval",
                                           type: PBMErrorType.internalError))
        }
    }

    private func attemptAUIDCreative() {
        guard creativeModel.adConfiguration != nil else {
            fail(with: PBMError.error(message: "PBMCreativeFactoryJob: Undefined creative model",
                                      type: PBMErrorType.internalError))
            return
        }

        let htmlCreative = HTMLCreative(creativeModel: creativeModel, transaction: transaction)
        htmlCreative.downloadBlock = createLoader()
        htmlCreative.creativeResolutionDelegate = self
        creative = htmlCreative
        htmlCreative.setupView()
    }

    private func initializeVideoCreative(_ data: Data?) {
        let videoCreative = VideoCreative(creativeModel: creativeModel, transaction: transaction, videoData: data)
        videoCreative.creativeResolutionDelegate = self
        creative = videoCreative
        videoCreative.setupView()
    }

    private func createLoader() -> (URL, @escaping PBMDownloadDataCompletionClosure) -> Void {
        let connection = serverConnection
        return { url, completionBlock in
            let downloader = DownloadDataHelper(serverConnection: connection)
            downloader.downloadData(for: url) { data, error in
                completionBlock(data, error)
            }
        }
    }
}
