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
import UIKit

@objc(PBMFactory) @_spi(PBMInternal) public
class Factory: NSObject {
    
    // MARK: BidRequester
    
    @objc public static func createBidRequester(connection: PrebidServerConnectionProtocol,
                                                sdkConfiguration: Prebid,
                                                targeting: Targeting,
                                                adUnitConfiguration: AdUnitConfig) -> BidRequester {
        BidRequesterImpl(connection: connection,
                         sdkConfiguration: sdkConfiguration,
                         targeting: targeting,
                         adUnitConfiguration: adUnitConfiguration)
    }
    
    // MARK: WinNotifier
    
    @objc public static let WinNotifierType: WinNotifier.Type = WinNotifierImpl.self
    
    @objc public static func createWinNotifier() -> WinNotifier {
        WinNotifierImpl()
    }
    
    // MARK: AdViewManager
    
    @objc public static func createAdViewManager(connection: PrebidServerConnectionProtocol,
                                                 modalManagerDelegate: ModalManagerDelegate?) -> AdViewManager {
        AdViewManagerImpl(connection: connection, modalManagerDelegate: modalManagerDelegate)
    }
    
    // MARK: Transaction
    
    @objc public static func createTransaction(serverConnection: PrebidServerConnectionProtocol,
                                               adConfiguration: AdConfiguration,
                                               models: [CreativeModel]) -> Transaction {
        TransactionImpl(serverConnection: serverConnection, adConfiguration: adConfiguration, models: models)
    }
    
    // MARK: ViewExposure
    
    @objc public static let ViewExposureType: ViewExposure.Type = ViewExposureImpl.self
    
    @objc public static func createViewExposure(exposureFactor: Float,
                                                visibleRectangle: CGRect,
                                                occlusionRectangles: [NSValue]?) -> ViewExposure {
        ViewExposureImpl(exposureFactor: exposureFactor,
                         visibleRectangle: visibleRectangle,
                         occlusionRectangles: occlusionRectangles)
    }
    
    // MARK: ModalState
    
    @objc public static func createModalState(view: UIView,
                                              adConfiguration: AdConfiguration?,
                                              displayProperties: InterstitialDisplayProperties?,
                                              onStatePopFinished: ModalStatePopHandler? = nil,
                                              onStateHasLeftApp: ModalStateAppLeavingHandler? = nil,
                                              nextOnStatePopFinished: ModalStatePopHandler? = nil,
                                              nextOnStateHasLeftApp: ModalStateAppLeavingHandler? = nil,
                                              onModalPushedBlock: VoidBlock? = nil) -> ModalState {
        ModalStateImpl(view: view,
                       adConfiguration: adConfiguration,
                       displayProperties: displayProperties,
                       onStatePopFinished: onStatePopFinished,
                       onStateHasLeftApp: onStateHasLeftApp,
                       nextOnStatePopFinished: nextOnStatePopFinished,
                       nextOnStateHasLeftApp: nextOnStateHasLeftApp,
                       onModalPushedBlock: onModalPushedBlock)
    }
    
    // MARK: PBMCreativeViewabilityTracker
    
    @objc public static func createCreativeViewabilityTracker(
        view: UIView,
        pollingTimeInterval: TimeInterval,
        onExposureChange: @escaping ViewExposureChangeHandler
    ) -> CreativeViewabilityTracker {
        CreativeViewabilityTrackerImpl(view: view,
                                       pollingTimeInterval: pollingTimeInterval,
                                       onExposureChange: onExposureChange)
    }
    
    @objc public static func createCreativeViewabilityTracker(
        creative: AbstractCreative
    ) -> CreativeViewabilityTracker {
        CreativeViewabilityTrackerImpl(creative: creative)
    }
    
    // MARK: PBMTransactionFactory
    
    @objc public static func createTransactionFactory(
        bid: Bid,
        adConfiguration: AdUnitConfig,
        connection: PrebidServerConnectionProtocol,
        callback: @escaping TransactionFactoryCallback
    ) -> TransactionFactory {
        TransactionFactoryImpl(
            bid: bid,
            adConfiguration: adConfiguration,
            connection: connection,
            callback: callback)
    }
}
