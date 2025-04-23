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
    
    static let bidRequesterType: BidRequester.Type = {
        NSClassFromString("PBMBidRequester_Objc") as! BidRequester.Type
    }()
    
    @objc public static func createBidRequester(connection: PrebidServerConnectionProtocol,
                                                sdkConfiguration: Prebid,
                                                targeting: Targeting,
                                                adUnitConfiguration: AdUnitConfig) -> BidRequester {
        bidRequesterType.init(connection: connection,
                              sdkConfiguration: sdkConfiguration,
                              targeting: targeting,
                              adUnitConfiguration: adUnitConfiguration)
    }
    
    // MARK: WinNotifier
    
    @objc public static let WinNotifierType: WinNotifier.Type = {
        NSClassFromString("PBMWinNotifier_Objc") as! WinNotifier.Type
    }()
    
    @objc public static func createWinNotifier() -> WinNotifier {
        WinNotifierType.init()
    }
    
    // MARK: AdViewManager
    
    @objc public static let AdViewManagerType: AdViewManager.Type = {
        NSClassFromString("PBMAdViewManager_Objc") as! AdViewManager.Type
    }()
    
    @objc public static func createAdViewManager(connection: PrebidServerConnectionProtocol,
                                                 modalManagerDelegate: ModalManagerDelegate?) -> AdViewManager {
        AdViewManagerType.init(connection: connection, modalManagerDelegate: modalManagerDelegate)
    }
    
    // MARK: Transaction
    
    @objc public static let TransactionType: Transaction.Type = {
        NSClassFromString("PBMTransaction_Objc") as! Transaction.Type
    }()
    
    @objc public static func createTransaction(serverConnection: PrebidServerConnectionProtocol,
                                               adConfiguration: AdConfiguration,
                                               models: [CreativeModel]) -> Transaction {
        TransactionType.init(serverConnection: serverConnection, adConfiguration: adConfiguration, models: models)
    }
    
    // MARK: ViewExposure
    
    @objc public static let ViewExposureType: ViewExposure.Type = {
        NSClassFromString("PBMViewExposure_Objc") as! ViewExposure.Type
    }()
    
    @objc public static func createViewExposure(exposureFactor: Float,
                                                visibleRectangle: CGRect,
                                                occlusionRectangles: [NSValue]?) -> ViewExposure {
        ViewExposureType.init(exposureFactor: exposureFactor,
                              visibleRectangle: visibleRectangle,
                              occlusionRectangles: occlusionRectangles)
    }
    
    // MARK: ModalState
    
    @objc public static let ModalStateType: ModalState.Type = {
        NSClassFromString("PBMModalState_Objc") as! ModalState.Type
    }()
    
    @objc public static func createModalState(view: UIView,
                                              adConfiguration: AdConfiguration?,
                                              displayProperties: InterstitialDisplayProperties?,
                                              onStatePopFinished: ModalStatePopHandler? = nil,
                                              onStateHasLeftApp: ModalStateAppLeavingHandler? = nil,
                                              nextOnStatePopFinished: ModalStatePopHandler? = nil,
                                              nextOnStateHasLeftApp: ModalStateAppLeavingHandler? = nil,
                                              onModalPushedBlock: VoidBlock? = nil) -> ModalState {
        ModalStateType.init(view: view,
                            adConfiguration: adConfiguration,
                            displayProperties: displayProperties,
                            onStatePopFinished: onStatePopFinished,
                            onStateHasLeftApp: onStateHasLeftApp,
                            nextOnStatePopFinished: nextOnStatePopFinished,
                            nextOnStateHasLeftApp: nextOnStateHasLeftApp,
                            onModalPushedBlock: onModalPushedBlock)
    }
    
    // MARK: PBMInterstitialAdLoader
    
    @objc public static let PBMInterstitialAdLoaderType: PBMInterstitialAdLoader.Type = {
        NSClassFromString("PBMInterstitialAdLoader_Objc") as! PBMInterstitialAdLoader.Type
    }()
    
    @objc public static func PBMInterstitialAdLoader(delegate: InterstitialAdLoaderDelegate,
                                                     eventHandler: PrimaryAdRequesterProtocol) -> PBMInterstitialAdLoader {
        PBMInterstitialAdLoaderType.init(delegate: delegate, eventHandler: eventHandler)
    }
}