//
//  SampleCustomRenderer.swift
//  TestUtils
//
//  Created by Richard Dépierre on 24/07/2024.
//

import Foundation
import PrebidMobile
import UIKit

public class SampleCustomRenderer: NSObject, PrebidMobilePluginRenderer {
    
    public let name = "SampleCustomRenderer"
    
    public let version = "1.0.0"
    
    public var data: [AnyHashable: Any]? = nil
    
    private var adViewManager: PBMAdViewManager?
    
    public var transactionFactory: PBMTransactionFactory?
    
    public func isSupportRendering(
        for format: AdFormat?
    ) -> Bool {
        .banner == format
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
        adViewDelegate: (
            any PBMAdViewDelegate
        )?
    ) {
        
        self.transactionFactory = PBMTransactionFactory(
            bid: bid,
            adConfiguration: adConfiguration,
            connection: connection
        ) {
            [weak self] transaction,
            error in
            self?.transactionFactory = nil
            guard let transaction else {
                adViewDelegate?.failed(
                    toLoad: NSError(
                        domain: "",
                        code: 0
                    )
                )
                return
            }
            if let error {
                adViewDelegate?.failed(
                    toLoad: error
                )
                return
            }
            self?.displayTransaction(
                transaction,
                adConfiguration: adConfiguration,
                connection: connection,
                adViewDelegate: adViewDelegate
            )
        }
        
        PBMWinNotifier.notifyThroughConnection(
            PrebidServerConnection.shared,
            winning: bid
        ) { [weak self] adMarkup in
            
            self?.transactionFactory?.load(
                withAdMarkup: adMarkup!
            )
        }
        
    }
    
    
    private func displayTransaction(
        _ transaction: PBMTransaction,
        adConfiguration: AdUnitConfig,
        connection: PrebidServerConnectionProtocol,
        adViewDelegate: (
            any PBMAdViewDelegate
        )?
    ) {
        adViewManager = PBMAdViewManager(
            connection: connection,
            modalManagerDelegate: adViewDelegate
        )
        adViewManager?.adViewManagerDelegate = adViewDelegate
        adViewManager?.adConfiguration = adConfiguration.adConfiguration
        
        if adConfiguration.adConfiguration.winningBidAdFormat == .video {
            adConfiguration.adConfiguration.isBuiltInVideo = true
        }
        
        adViewManager?.handleExternalTransaction(
            transaction
        )
        
        
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
        adConfiguration.adConfiguration.isOriginalAPI
        videoControlsConfig?.initialize(
            with: bid.videoAdConfiguration
        )
        
        // This part is dedicating to test server-side ad configurations.
        // Need to be removed when ext.prebid.passthrough will be available.
#if DEBUG
        adConfiguration.adConfiguraxtion.videoControlsConfig.initialize(
            with: bid.testVideoAdConfiguration
        )
#endif
        transactionFactory = PBMTransactionFactory(bid: bid,
                                                   adConfiguration: adConfiguration,
                                                   connection: PrebidServerConnection.shared,
                                                   callback: {
            [weak adViewDelegate] transaction,
            error in
            
            if let transaction = transaction {
                adViewDelegate?.display(
                    transaction: transaction
                )
            } else {
                adViewDelegate?.reportFailureWithError(
                    error
                )
            }
        })
        
        PBMWinNotifier.notifyThroughConnection(PrebidServerConnection.shared,
                                               winning: bid,
                                               callback: {
            [weak self] adMarkup in
            if let adMarkup = adMarkup {
                self?.transactionFactory?.load(
                    withAdMarkup: adMarkup
                )
            } else {
                //TODO: inform failure
            }
        })
    }
    
}
