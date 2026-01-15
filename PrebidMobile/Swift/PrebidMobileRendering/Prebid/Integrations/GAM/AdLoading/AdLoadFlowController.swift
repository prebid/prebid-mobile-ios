//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    

import Foundation

@_spi(PBMInternal) public
typealias AdUnitConfigValidationBlock = (_ adUnitConfig: AdUnitConfig, _ renderWithPrebid: Bool) -> Bool

@objc(PBMAdLoadFlowController)
@objcMembers
@_spi(PBMInternal) public class AdLoadFlowController: NSObject, AdLoaderFlowDelegate {

    // MARK: - Properties

    private let bidRequesterFactory: (AdUnitConfig) -> BidRequesterProtocol
    private var adLoader: AdLoaderProtocol?
    private var bannerEventDelegate: BannerEventLoadingDelegate?
    private weak var delegate: AdLoadFlowControllerDelegate?
    private let configValidationBlock: AdUnitConfigValidationBlock
    private let savedAdUnitConfig: AdUnitConfig

    var bidResponse: BidResponse?
    var nativoBidResponse: BidResponse?
    var flowState: AdLoadFlowState = .idle
    private var bidRequestError: Error?
    private var bidRequester: BidRequesterProtocol?
    private var nativoRequester: BidRequesterProtocol?
    private var prebidAdObject: AnyObject?
    private var primaryAdObject: AnyObject?
    private var adSize: NSValue?

    @objc let dispatchQueue: DispatchQueue
    @objc let mutationLock = NSLock()

    // MARK: - Init

    required init(bidRequesterFactory: @escaping (AdUnitConfig) -> BidRequesterProtocol,
         adLoader: AdLoaderProtocol,
         adUnitConfig: AdUnitConfig,
         delegate: AdLoadFlowControllerDelegate,
         configValidationBlock: @escaping AdUnitConfigValidationBlock) {

        self.bidRequesterFactory = bidRequesterFactory
        self.adLoader = adLoader
        
        // Inconvenient logic needed to unwrap the BannerAdLoader, which is the same object as adLoader
        // Needed so that we can notify of Nativo wins
        if let bannerDelegate = adLoader as? BannerEventLoadingDelegate {
            self.bannerEventDelegate = bannerDelegate
        }
        
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

    public func adLoader(_ adLoader: AdLoaderProtocol, loadedPrimaryAd adObject: AnyObject, adSize: NSValue?) {
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

    public func adLoader(_ adLoader: AdLoaderProtocol, failedWithPrimarySDKError error: Error?) {
        enqueueGatedBlock { [weak self] in
            guard self?.bidResponse?.winningBid != nil else {
                self?.reportLoadingFailedWithError(error)
                return
            }
            self?.decideWinner { [weak self] winningBid in
                self?.loadPrebidDisplayView(bidResponse: winningBid)
            }
        }
    }

    public func adLoaderDidWinSdk(_ adLoader: AdLoaderProtocol, withBidResponse bidResponse: BidResponse?) {
        enqueueGatedBlock { [weak self] in
            if let winningBid = bidResponse {
                self?.loadPrebidDisplayView(bidResponse: winningBid)
            } else {
                self?.loadPrebidDisplayView(bidResponse: self?.bidResponse)
            }
        }
    }
    
    // At the moment this does that same thing as adLoaderDidWinPrebid
    // but adding it simply to show separate flow from Prebid win
    // Also bidResponse is different and doesn't contain same meta data
    public func adLoaderDidWinNativo(_ adLoader: AdLoaderProtocol) {
        enqueueGatedBlock { [weak self] in
            let response = self?.nativoBidResponse
            self?.loadPrebidDisplayView(bidResponse: response)
        }
    }

    public func adLoaderLoadedPrebidAd(_ adLoader: AdLoaderProtocol) {
        enqueueGatedBlock { [weak self] in
            if let bidSize = self?.bidResponse?.winningBid?.size {
                self?.adSize = NSValue(cgSize: bidSize)
            }
            self?.markReadyToDeployAdView()
        }
    }

    public func adLoader(_ adLoader: AdLoaderProtocol, failedWithPrebidError error: Error?) {
        enqueueGatedBlock { [weak self] in
            self?.prebidAdObject = nil
            self?.reportLoadingFailedWithError(error)
        }
    }

    // MARK: - Gated Enqueue Helpers

    @objc func enqueueGatedBlock(_ block: @escaping VoidBlock) {
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
        case .nativoRequest:
            sendNativoBidRequest()
        case .bidRequest, .primaryAdRequest, .loadingDisplayView:
            return // waiting
        case .demandReceived:
            decideWinner { winningBid in
                self.requestPrimaryAdServer(winningBid)
            }
        case .readyToDeploy:
            deployPendingViewAndSendSuccessReport()
        }
    }
    
    private func sendNativoBidRequest() {
        nativoRequester = Factory.createNativoBidRequester(
            connection: PrebidServerConnection.shared,
            sdkConfiguration: Prebid.shared,
            targeting: Targeting.shared,
            adUnitConfiguration: savedAdUnitConfig
        )
        nativoRequester?.requestBids { [weak self] (nativoResponse: BidResponse?, err: Error?) in
            self?.enqueueGatedBlock { [weak self] in
                if let err {
                    self?.reportLoadingFailedWithError(err)
                    return
                }
                self?.handleNativoResponse(response: nativoResponse, error: err)
            }
        }
    }
    
    private func handleNativoResponse(response: BidResponse?, error: Error?) {
        self.nativoBidResponse = response
        let bid = response?.winningBid
        let isOwnedOperated: Bool = bid?.bid.ext?.nativo?.isOwnedOperated ?? false
        if (isOwnedOperated) {
            // Render O&O demand via adLoader Nativo flow
            if let size = bid?.size {
                self.adSize = NSValue(cgSize: size)
            }
            self.bidRequestError = error
            self.bidRequester = nil
            adLoader?.flowDelegate = self
            self.loadPrebidDisplayView(bidResponse: response)
        } else {
            flowState = .bidRequest
            sendBidRequest()
        }
    }
    
    private func tryLaunchingAdRequestFlow() {
        guard configValidationBlock(savedAdUnitConfig, false) else {
            let error = PBMError.error(message: "AdUnitConfig is not valid.", type: .internalError)
            reportLoadingFailedWithError(error)
            return
        }

        delegate?.adLoadFlowControllerWillSendBidRequest(self)
        
        self.flowState = .nativoRequest
        enqueueNextStepAttempt()
    }

    private func sendBidRequest() {
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
    
    private func decideWinner(completion: ((BidResponse?) -> Void)? = nil) {
        let prebidPrice = bidResponse?.winningBid?.price ?? 0.0
        let nativoPrice = nativoBidResponse?.winningBid?.price ?? 0.0
        
        var winningResponse: BidResponse?
        if (nativoPrice >= prebidPrice) {
            winningResponse = nativoBidResponse
        } else {
            winningResponse = bidResponse
        }
        completion?(winningResponse)
    }

    private func requestPrimaryAdServer(_ bidResponse: BidResponse?) {
        flowState = .primaryAdRequest
        delegate?.adLoadFlowControllerWillRequestPrimaryAd(self)
        adLoader?.flowDelegate = self

        DispatchQueue.main.async { [weak self] in
            guard let self, let primaryAdServer = self.adLoader?.primaryAdRequester else { return }
            primaryAdServer.requestAd(with: bidResponse)
        }
    }

    private func loadPrebidDisplayView(bidResponse: BidResponse?) {
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
