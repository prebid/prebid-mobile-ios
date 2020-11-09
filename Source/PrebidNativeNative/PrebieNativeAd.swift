/*   Copyright 2019-2020 Prebid.org, Inc.

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
import UIKit

public  class PrebidNativeAd: NSObject {
    
    public var title:String?
    public var text:String?
    public var iconUrl:String?
    public var imageUrl:String?
    public var callToAction:String?
    public  var clickUrl:String?
    
    public weak var delegate: PrebidNativeAdEventDelegate?
    
    //NativeAd Expire
    private var expired = false
    private var adDidExpireTimer:Timer?
    //Impression Tracker
    private var targetViewabilityValue = 0
    private var viewabilityTimer:Timer?
    private var viewabilityValue = 0
    private var impressionHasBeenTracked = false
    private var viewForTracking:UIView?
    private var impTrackers = [String]()
    
    public static func  create(cacheId:String)-> PrebidNativeAd? {
        if let content = CacheManager.shared.get(cacheId: cacheId) {
            let data = content.data(using: .utf8)!
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let ad: PrebidNativeAd = PrebidNativeAd()
//                    //assets
//                    if let assets = json["assets"] as? [AnyObject] {
//                        for adObject in assets {
//                            if let adObject = adObject as? [String : AnyObject]{
//                                //title
//                                if let title = adObject["title"], let text = title["text"] as? String {
//                                    ad.title = text;
//                                }
//                                //description
//                                if let description = adObject["description"], let text = description["text"] as? String {
//                                    ad.text = text;
//                                }
//                                //img
//                                if let img = adObject["img"], let url = img["url"] as? String {
//                                    ad.imageUrl = url;
//                                }
//                                //icon
//                                if let icon = adObject["icon"], let url = icon["url"] as? String {
//                                    ad.iconUrl = url;
//                                }
//                                //call to action
//                                ad.callToAction = "Learn More"
//                            }
//                        }
//                    }
//
//                    //clickUrl
//                    if let link = json["link"] as? [String : AnyObject], let url = link["url"] as? String {
//                        ad.clickUrl = url;
//                    }
                    //eventtrackers
                    if let eventtrackers = json["eventtrackers"] as? [AnyObject] {
                        for eventtracker in eventtrackers {
                            if let eventtracker = eventtracker as? [String : AnyObject], let url = eventtracker["url"] as? String  {
                                ad.impTrackers.append(url)
                            }
                        }
                    }
                    ad.title = "Hello World"
                    ad.text = "This is a Prebid Native Ad. For more information please check prebid.org."
                    ad.callToAction = "Learn More"
                    ad.iconUrl = "https://dummyimage.com/40x40/000/fff"
                    ad.imageUrl = "https://dummyimage.com/600x400/000/fff"
                    ad.clickUrl = "https://prebig.org"
                    if ad.isValid() {
                        ad.registerAdAboutToExpire()
                        return ad
                    }else{
                        return nil
                    }
                }
            } catch let error as NSError {
                Log.error("Failed to load: \(error.localizedDescription)")
            }
            
        }
        return nil
    }
    
    private override init() {
        super.init()
    }
    private func isValid() -> Bool{
        return !(title ?? "").isEmpty
       // && !(text ?? "").isEmpty
       // && !(callToAction ?? "").isEmpty
       // && canOpenString(string: iconUrl!)
        && canOpenString(string: imageUrl!)
       // && canOpenString(string: clickUrl!)
    }
    
    private func canOpenString(string:String) -> Bool {
        guard let url = URL(string: string) else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }
    
    //MARK: registerView function
    @discardableResult 
    public func registerView(view : UIView, withRootViewController : UIViewController, clickableViews : [UIView]? ) -> Bool{
        guard view != nil else {
            Log.error("A valid view is required for tracking")
            return false
        }
        guard !expired else {
            Log.error("The native Ad is expired, cannot use it for tracking")
            return false
        }
        viewForTracking = view
        setupViewabilityTracker()
        return true
    }
    
    //MARK: NativeAd Expire
    private func registerAdAboutToExpire(){
        invalidateAdExpireTimer(timer: adDidExpireTimer)
        adDidExpireTimer = Timer.scheduledTimer(timeInterval: Constants.kNativeAdResponseExpirationTime, target: self, selector:#selector(onAdExpired), userInfo: nil, repeats:false)
    }
    
    private func invalidateAdExpireTimer(timer : Timer?){
        if let timer = timer, timer.isValid {
            timer.invalidate()
        }
    }
    
    @objc private func onAdExpired() {
        expired = true
        if let adDidExpireTimer = adDidExpireTimer, adDidExpireTimer.isValid {
            delegate?.adDidExpire?(ad: self)
        }
        invalidateAdExpireTimer(timer: adDidExpireTimer)
    }
    
    
    //MARK: Impression Tracking
    private func setupViewabilityTracker(){
        let requiredAmountOfSimultaneousViewableEvents = lround(Constants.kAppNexusNativeAdIABShouldBeViewableForTrackingDuration / Constants.kAppNexusNativeAdCheckViewabilityForTrackingFrequency) + 1
        
        targetViewabilityValue = lround(pow(Double(2),Double(requiredAmountOfSimultaneousViewableEvents)) - 1)
        
        Log.debug("\n\trequiredAmountOfSimultaneousViewableEvents=\(requiredAmountOfSimultaneousViewableEvents) \n\ttargetViewabilityValue=\(targetViewabilityValue)")
        
        viewabilityTimer = Timer.scheduledTimer(timeInterval: Constants.kAppNexusNativeAdCheckViewabilityForTrackingFrequency, target: self, selector:#selector(checkViewability), userInfo: nil, repeats:true)
    }
    
    @objc private func checkViewability() {
        viewabilityValue = (viewabilityValue << 1 | (viewForTracking?.an_isAtLeastHalfViewable() == true ? 1 : 0)) & targetViewabilityValue
        let isIABViewable = (viewabilityValue == targetViewabilityValue)
        Log.debug("\n\tviewabilityValue=\(viewabilityValue) \n\tself.targetViewabilityValue=\(targetViewabilityValue) \n\tisIABViewable=\(isIABViewable)")
        if isIABViewable {
            trackImpression()
        }
    }
    
    private func trackImpression(){
        if !impressionHasBeenTracked {
            Log.debug("Firing impression trackers")
            fireImpTrackers()
            viewabilityTimer?.invalidate()
            impressionHasBeenTracked = true
        }
    }
    
    private func fireImpTrackers(){
        if impTrackers.count != 0 {
            TrackerManager.shared.fireTrackerURLArray(arrayWithURLs: impTrackers) { [weak self] isTrackerFired in
                guard let strongSelf = self else {
                    Log.debug("FAILED TO ACQUIRE strongSelf.")
                    return
                }
                if isTrackerFired {
                    strongSelf.delegate?.adDidLogImpression?(ad: strongSelf)
                }
            }
        }
    }
    
    
}

