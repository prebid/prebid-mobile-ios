/*   Copyright 2018-2021 Prebid.org, Inc.

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

public class PrebidRenderer: NSObject, PrebidMobilePluginRenderer {
    
    public let name = "PrebidRenderer"
    
    public let version = Prebid.shared.version
    
    public var data: [AnyHashable: Any]? = nil
    
    private var adViewManager: PBMAdViewManager?
    
    public var transactionFactory: PBMTransactionFactory?
    
    public func isSupportRendering(for format: AdFormat?) -> Bool {
        AdFormat.allCases.contains(where: { $0 == format })
    }
   
    public func setupBid(
        _ bid: Bid,
        adConfiguration: AdUnitConfig,
        connection: PrebidServerConnectionProtocol
    ) {
        
    }
    
    public func createBannerAdView(
        with frame: CGRect,
        bid: Bid,
        adConfiguration: AdUnitConfig,
        connection: PrebidServerConnectionProtocol,
        adViewDelegate: (any PBMAdViewDelegate)?
    ) {
    
        self.transactionFactory = PBMTransactionFactory(bid: bid, adConfiguration: adConfiguration, connection: connection) { [weak self] transaction, error in
            self?.transactionFactory = nil
            guard let transaction else {
                adViewDelegate?.failed(toLoad: NSError(domain: "", code: 0))
                return
            }
            if let error {
                adViewDelegate?.failed(toLoad: error)
                return
            }
            self?.displayTransaction(transaction, adConfiguration: adConfiguration, connection: connection, adViewDelegate: adViewDelegate)
        }
        
        PBMWinNotifier.notifyThroughConnection(PrebidServerConnection.shared,
                                               winning: bid) { [weak self] adMarkup in
            
            self?.transactionFactory?.load(withAdMarkup: adMarkup!)
        }

    }
    
    
    private func displayTransaction(
        _ transaction: PBMTransaction,
        adConfiguration: AdUnitConfig,
        connection: PrebidServerConnectionProtocol,
        adViewDelegate: (any PBMAdViewDelegate)?
    ) {
        adViewManager = PBMAdViewManager(connection: connection, modalManagerDelegate: adViewDelegate)
        adViewManager?.adViewManagerDelegate = adViewDelegate
        adViewManager?.adConfiguration = adConfiguration.adConfiguration

        if adConfiguration.adConfiguration.winningBidAdFormat == .video {
            adConfiguration.adConfiguration.isBuiltInVideo = true
        }

        adViewManager?.handleExternalTransaction(transaction)
    }
    
    
    
    
    public func createInterstitialController(
        bid: Bid,
        adConfiguration: AdUnitConfig,
        connection: PrebidServerConnectionProtocol,
        adViewManagerDelegate adViewDelegate: InterstitialController?,
        videoControlsConfig: VideoControlsConfiguration?
    ) {
        guard transactionFactory == nil else {
            return
        }
        
        adConfiguration.adConfiguration.winningBidAdFormat = bid.adFormat
        videoControlsConfig?.initialize(with: bid.videoAdConfiguration)
        
        // This part is dedicating to test server-side ad configurations.
        // Need to be removed when ext.prebid.passthrough will be available.
        #if DEBUG
        adConfiguration.adConfiguration.videoControlsConfig.initialize(with: bid.testVideoAdConfiguration)
        #endif
        transactionFactory = PBMTransactionFactory(bid: bid,
                                                   adConfiguration: adConfiguration,
                                                   connection: PrebidServerConnection.shared,
                                                   callback: { [weak adViewDelegate] transaction, error in
                
            if let transaction = transaction {
                adViewDelegate?.display(transaction: transaction)
            } else {
                self.transactionFactory = nil
                adViewDelegate?.reportFailureWithError(error)
            }
        })
        
        PBMWinNotifier.notifyThroughConnection(PrebidServerConnection.shared,
                                               winning: bid,
                                               callback: { [weak self] adMarkup in
            if let self = self, let adMarkup = adMarkup {
                self.transactionFactory?.load(withAdMarkup: adMarkup)
            } else {
                Log.debug("Ad markup is empty")
            }
        })
    }
    
}
