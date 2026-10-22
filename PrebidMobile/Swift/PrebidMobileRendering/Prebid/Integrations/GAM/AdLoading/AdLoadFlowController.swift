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

typealias AdUnitConfigValidationBlock = (_ adUnitConfig: AdUnitConfig, _ renderWithPrebid: Bool) -> Bool

class AdLoadFlowController: NSObject, AdLoaderFlowDelegate {

    // MARK: - Properties

    private let bidRequesterFactory: (AdUnitConfig) -> BidRequesterProtocol
    private var adLoader: AdLoaderProtocol?
    private weak var delegate: AdLoadFlowControllerDelegate?
    private let configValidationBlock: AdUnitConfigValidationBlock
    private let savedAdUnitConfig: AdUnitConfig

    var bidResponse: BidResponse?
    var flowState: AdLoadFlowState = .idle
    private var bidRequestError: Error?
    private var bidRequester: BidRequesterProtocol?
    private var prebidAdObject: AnyObject?
    private var primaryAdObject: AnyObject?
    private var adSize: NSValue?

    let dispatchQueue: DispatchQueue
    let mutationLock = NSLock()

    // MARK: - Init

    required init(bidRequesterFactory: @escaping (AdUnitConfig) -> BidRequesterProtocol,
         adLoader: AdLoaderProtocol,
         adUnitConfig: AdUnitConfig,
         delegate: AdLoadFlowControllerDelegate,
         configValidationBlock: @escaping AdUnitConfigValidationBlock) {

        self.bidRequesterFactory = bidRequesterFactory
        self.adLoader = adLoader
        self.savedAdUnitConfig = adUnitConfig
        self.delegate = delegate
        self.configValidationBlock = configValidationBlock

        let queueName = "PBMAdLoadFlowController_\(UUID().uuidString)"
        self.dispatchQueue = DispatchQueue(label: queueName)
        super.init()
    }

    // MARK: - Public API

    var hasFailedLoading: Bool {
        flowState == .loadingFailed
    }

    // MARK: - PBMAdLoaderFlowDelegate

    func adLoader(_ adLoader: AdLoaderProtocol, loadedPrimaryAd adObject: AnyObject, adSize: NSValue?) {
        enqueueGatedBlock { [weak self] in
            if let error = self?.bidRequestError {
                self?.bidRequestError = nil
                Log.info("[ERROR]: \(error.localizedDescription)")
            }
            self?.adSize = adSize
            self?.primaryAdObject = adObject
            self?.markReadyToDeployAdView()
        }
    }

    func adLoader(_ adLoader: AdLoaderProtocol, failedWithPrimarySDKError error: Error?) {
        enqueueGatedBlock { [weak self] in
            guard self?.bidResponse?.winningBid != nil else {
                self?.reportLoadingFailedWithError(error)
                return
            }
            self?.loadPrebidDisplayView()
        }
    }

    func adLoaderDidWinPrebid(_ adLoader: AdLoaderProtocol) {
        enqueueGatedBlock { [weak self] in
            self?.loadPrebidDisplayView()
        }
    }

    func adLoaderLoadedPrebidAd(_ adLoader: AdLoaderProtocol) {
        enqueueGatedBlock { [weak self] in
            if let bidSize = self?.bidResponse?.winningBid?.size {
                self?.adSize = NSValue(cgSize: bidSize)
            }
            self?.markReadyToDeployAdView()
        }
    }

    func adLoader(_ adLoader: AdLoaderProtocol, failedWithPrebidError error: Error?) {
        enqueueGatedBlock { [weak self] in
            self?.prebidAdObject = nil
            self?.reportLoadingFailedWithError(error)
        }
    }

    // MARK: - Gated Enqueue Helpers

    func enqueueGatedBlock(_ block: @escaping VoidBlock) {
        dispatchQueue.async { [weak self] in
            self?.mutationLock.lock()
            block()
            self?.mutationLock.unlock()
        }
    }

    func refresh() {
        enqueueGatedBlock { [weak self] in
            self?.moveToNextLoadingStep()
        }
    }

    func enqueueNextStepAttempt() {
        enqueueGatedBlock { [weak self] in
            guard let self else { return }
            if self.delegate?.adLoadFlowControllerShouldContinue(self) == true {
                self.moveToNextLoadingStep()
            }
        }
    }

    // MARK: - Loading Logic

    private func moveToNextLoadingStep() {
        switch flowState {
        case .idle, .loadingFailed:
            tryLaunchingAdRequestFlow()
        case .bidRequest, .primaryAdRequest, .loadingDisplayView:
            return // waiting
        case .demandReceived:
            requestPrimaryAdServer(bidResponse)
        case .readyToDeploy:
            deployPendingViewAndSendSuccessReport()
        }
    }

    private func tryLaunchingAdRequestFlow() {
        guard configValidationBlock(savedAdUnitConfig, false) else {
            let error = PBMError.error(message: "AdUnitConfig is not valid.", type: .internalError)
            reportLoadingFailedWithError(error)
            return
        }

        delegate?.adLoadFlowControllerWillSendBidRequest(self)
        sendBidRequest()
    }

    private func sendBidRequest() {
        flowState = .bidRequest
        bidRequester = bidRequesterFactory(savedAdUnitConfig)
        bidRequester?.requestBids { [weak self ] response, error in
            self?.enqueueGatedBlock { [weak self] in
                self?.handleBidResponse(response: response, error: error)
            }
        }
    }

    private func handleBidResponse(response: BidResponse?, error: Error?) {
        self.bidResponse = (response != nil && error == nil) ? response : nil
        self.bidRequestError = error
        self.bidRequester = nil
        self.flowState = .demandReceived
        enqueueNextStepAttempt()
    }

    private func requestPrimaryAdServer(_ bidResponse: BidResponse?) {
        flowState = .primaryAdRequest
        delegate?.adLoadFlowControllerWillRequestPrimaryAd(self)
        adLoader?.flowDelegate = self

        DispatchQueue.main.async { [weak self] in
            self?.adLoader?.primaryAdRequester?.requestAd(with: bidResponse)
        }
    }

    private func loadPrebidDisplayView() {
        if let error = bidRequestError {
            reportLoadingFailedWithError(error)
            bidRequestError = nil
            return
        }

        guard configValidationBlock(savedAdUnitConfig, true) else {
            let error = PBMError.error(message: "AdUnitConfig is not valid.",
                                       type: .internalError)
            reportLoadingFailedWithError(error)
            return
        }

        guard let bid = bidResponse?.winningBid else {
            reportLoadingFailedWithError(PBMError.noWinningBid())
            return
        }

        flowState = .loadingDisplayView

        DispatchQueue.main.sync { [weak self] in
            guard let self = self else { return }
            var prebidAdObjectBox: AnyObject?
            self.adLoader?.createPrebidAd(with: bid,
                                          adUnitConfig: self.savedAdUnitConfig,
                                          adObjectSaver: { prebidAdObjectBox = $0 },
                                          loadMethodInvoker: { loadMethod in
                self.enqueueGatedBlock { [weak self] in
                    self?.prebidAdObject = prebidAdObjectBox
                    loadMethod()
                }
            })
        }
    }

    private func markReadyToDeployAdView() {
        flowState = .readyToDeploy
        enqueueNextStepAttempt()
    }

    private func deployPendingViewAndSendSuccessReport() {
        flowState = .idle
        guard let adObject = primaryAdObject ?? prebidAdObject else { return }
        adLoader?.reportSuccess(with: adObject,
                                adSize: adSize)
    }

    private func reportLoadingFailedWithError(_ error: Error?) {
        flowState = .loadingFailed
        delegate?.adLoadFlowController(self, failedWithError: error)
    }
}
