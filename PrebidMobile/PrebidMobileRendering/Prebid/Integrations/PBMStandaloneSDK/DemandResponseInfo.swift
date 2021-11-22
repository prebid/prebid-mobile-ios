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

public class DemandResponseInfo: NSObject {
    
    @objc public private(set) var fetchDemandResult: FetchDemandResult
    
    private(set) var configId: String?
    @objc public private(set) var bid: Bid?
    
    var winNotifierBlock: PBMWinNotifierBlock
    
    private(set) var bidResponse: BidResponseForRendering?

    @objc public required init(fetchDemandResult: FetchDemandResult,
                               bid: Bid?,
                               configId: String?,
                               winNotifierBlock: @escaping PBMWinNotifierBlock,
                               bidResponse: BidResponseForRendering?
    ) {
        self.bidResponse = bidResponse
        self.fetchDemandResult = fetchDemandResult
        self.bid = bid
        self.configId = configId
        self.winNotifierBlock = winNotifierBlock
    }
    
    // The feature is not available. Use original Prebid Native API
    // TODO: Merge Native engine from original SDK and rendering codebase
    @objc func getNativeAd(withCompletion completion: @escaping (PBRNativeAd?) -> Void) {
        getAdMarkupString(withCompletion: { adMarkupString in
            
            guard let adMarkupString = adMarkupString else {
                completion(nil)
                return
            }
            
            do {
                let nativeAdMarkup = try PBMNativeAdMarkup(jsonString: adMarkupString)
                completion(PBRNativeAd(nativeAdMarkup: nativeAdMarkup))
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
