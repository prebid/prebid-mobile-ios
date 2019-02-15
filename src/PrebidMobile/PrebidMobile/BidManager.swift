/*   Copyright 2018-2019 Prebid.org, Inc.
 
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

@objcMembers class BidManager:NSObject {
    
    var prebidAdUnit:AdUnit?
    
    init(adUnit:AdUnit) {
        
        super.init()
        
        prebidAdUnit = adUnit
        
        if(RequestBuilder.myUserAgent == ""){
            RequestBuilder.UserAgent(){(userAgentString) in
                Log.info(userAgentString)
                RequestBuilder.myUserAgent = userAgentString
            }
        }
    }
    
    dynamic func requestBidsForAdUnit(callback: @escaping (_ response: BidResponse?, _ result: ResultCode) -> Void) {
        
        do {
            try RequestBuilder.shared.buildPrebidRequest(adUnit: prebidAdUnit){(urlRequest) in
                let demandFetchStartTime = self.getCurrentMillis()
                URLSession.shared.dataTask(with: urlRequest!) { data, response, error in
                    let demandFetchEndTime = self.getCurrentMillis()
                    guard error == nil else {
                        print("error calling GET on /todos/1")
                        return
                    }
                    
                    // make sure we got data
                    if(data == nil ) {
                        print("Error: did not receive data")
                        callback(nil,ResultCode.prebidNetworkError)

                    }
                    if(!Prebid.shared.timeoutUpdated) {
                        let tmax = self.getTmaxRequest(data!)
                        if(tmax > 0) {
                            Prebid.shared.timeoutMillis = min(demandFetchEndTime - demandFetchStartTime + tmax + 200, 10000)
                            Prebid.shared.timeoutUpdated = true
                        }
                    }
                    let processData = self.processBids(data!)
                    let bidMap:[String:AnyObject] = processData.0
                    let result:ResultCode = processData.1
                    if(result == ResultCode.prebidDemandFetchSuccess) {
                            let bidResponse = BidResponse(adId: "PrebidMobile", adServerTargeting: bidMap)
                            Log.info("Bid Successful with rounded bid targeting keys are \(bidResponse.customKeywords) for adUnit id is \(bidResponse.adUnitId)")
                        
                        DispatchQueue.main.async() {
                            callback(bidResponse, ResultCode.prebidDemandFetchSuccess)
                        }
                    } else {
                        callback(nil, result)
                    }
                    
                    }.resume()
                
            }
            
        } catch let error {
            print(error.localizedDescription)
            callback(nil,ResultCode.prebidServerURLInvalid)
        }
    }
    
    func processBids(_ data:Data) -> ([String:AnyObject],ResultCode) {
        
        do {
            let errorString:String = String.init(data: data, encoding: .utf8)!
            print(String(format: "Response from server: %@", errorString))
            if(!errorString.contains("Invalid request:")){
                let response:[String:AnyObject] = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
                
                var bidDict:[String:AnyObject] = [:]
                var containTopBid = false
                if (response.count > 0) {
                    if (response["seatbid"] != nil) {
                        let seatbids = response["seatbid"] as! [AnyObject]
                        for seatbid in seatbids {
                            if (seatbid is [String : AnyObject]) {
                                var seatbidDict = seatbid as? [String:AnyObject]
                                if (seatbidDict?["bid"] is [AnyObject]) {
                                    let bids = seatbidDict?["bid"] as! [AnyObject]
                                    for bid in bids {
                                        var containBid = false
                                        var adServerTargeting:[String:AnyObject]?
                                        if (bid["ext"] != nil) {
                                            let extDict:[String:Any] = bid["ext"] as! [String:Any]
                                            if (extDict["prebid"] != nil) {
                                                let prebidDict:[String:Any] = extDict["prebid"] as! [String:Any]
                                                adServerTargeting = prebidDict["targeting"] as? [String:AnyObject]
                                                if (adServerTargeting != nil) {
                                                    for key in adServerTargeting!.keys{
                                                        if (key == "hb_cache_id") {
                                                            containTopBid = true
                                                        }
                                                        if (key.starts(with: "hb_cache_id")) {
                                                            containBid = true
                                                        }
                                                    }
                                                    if (containBid) {
                                                        for (key, value) in adServerTargeting! {
                                                            bidDict[key] = value
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if (containTopBid && bidDict.count > 0) {
                    return (bidDict,ResultCode.prebidDemandFetchSuccess)
                } else {
                    return ([:],ResultCode.prebidDemandNoBids)
                }
            } else {
                if(errorString.contains("Stored Imp with ID")){
                    return ([:],ResultCode.prebidInvalidConfigId)
                } else if(errorString.contains("Stored Request with ID")) {
                    return ([:],ResultCode.prebidInvalidAccountId)
                } else if((errorString.contains("Invalid request: Request imp[0].banner.format")) || (errorString.contains("Unable to set interstitial size list"))){
                    return ([:],ResultCode.prebidInvalidSize)
                } else {
                    return ([:],ResultCode.prebidServerError)
                }
            }
            
        } catch let error {
            print(error.localizedDescription)
            
            return ([:],ResultCode.prebidDemandNoBids)
        }
        
    }
    
    func getCurrentMillis() -> Int {
        return Int(Date().timeIntervalSince1970 * 1000)
    }
    
    func getTmaxRequest(_ data:Data) -> Int {
        do{
            let response:[String:AnyObject] = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
            let ext = response["ext"] as! [String: AnyObject]
            if(ext["tmaxrequest"] != nil) {
                return  ext["tmaxrequest"] as! Int
            }
        } catch let error {
            print(error.localizedDescription)
        }
        return -1
    }
}
