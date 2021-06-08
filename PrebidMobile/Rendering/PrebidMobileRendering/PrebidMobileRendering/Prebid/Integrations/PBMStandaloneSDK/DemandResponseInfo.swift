//
//  DemandResponseInfo.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

public class DemandResponseInfo: NSObject {
    
    @objc public private(set) var fetchDemandResult: FetchDemandResult
    
    private(set) var configId: String?
    @objc public private(set) var bid: Bid?
    
    var winNotifierBlock: PBMWinNotifierBlock

    @objc public required init(fetchDemandResult: FetchDemandResult,
                  bid: Bid?,
                  configId: String?,
                  winNotifierBlock: @escaping PBMWinNotifierBlock
    ) {
        self.fetchDemandResult = fetchDemandResult
        self.bid = bid
        self.configId = configId
        self.winNotifierBlock = winNotifierBlock
    }
    
    @objc public func getNativeAd(withCompletion completion: @escaping (NativeAd?) -> Void) {
        getAdMarkupString(withCompletion: { adMarkupString in
            
            guard let adMarkupString = adMarkupString else {
                completion(nil)
                return
            }
            
            do {
                let nativeAdMarkup = try PBMNativeAdMarkup(jsonString: adMarkupString)
                completion(NativeAd(nativeAdMarkup: nativeAdMarkup))
            } catch {
                PBMLog.error(error.localizedDescription)
                completion(nil)
            }
        })
    }
    
    // MARK: - Private Methods
    
    func getAdMarkupString(withCompletion completion: @escaping PBMAdMarkupStringHandler) {
        guard let bid = bid else {
            completion(nil)
            return
        }
        winNotifierBlock(bid, completion)
    }
}
