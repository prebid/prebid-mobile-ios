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

@objcMembers public class NativeAd: NSObject, CacheExpiryDelegate {
    
    private static let nativeAdIABShouldBeViewableForTrackingDuration = 1.0
    private static let nativeAdCheckViewabilityForTrackingFrequency = 0.25
    
    public private(set) var title:String?
    public private(set) var text:String?
    public private(set) var iconUrl:String?
    public private(set) var imageUrl:String?
    public private(set) var callToAction:String?
    public private(set) var sponsoredBy:String?
    
    public weak var delegate: NativeAdEventDelegate?
    
    //NativeAd Expire
    private var expired = false
    //Impression Tracker
    private var targetViewabilityValue = 0
    private var viewabilityTimer:Timer?
    private var viewabilityValue = 0
    private var impressionHasBeenTracked = false
    private var viewForTracking:UIView?
    private var impTrackers = [String]()
    //Click Handling
    private var gestureRecognizerRecords = [NativeAdGestureRecognizerRecord]()
    private var clickUrl:String?

    
    public static func  create(cacheId: String)->NativeAd? {
        
        guard let content = CacheManager.shared.get(cacheId: cacheId), let response = Utils.shared.getDictionaryFromString(content), let adm = response["adm"] as? String, let data = adm.data(using: .utf8) else {
            Log.error("Invalid native contents")
            return nil
        }
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                Log.error("Invalid native json")
                return nil
            }
            let ad:NativeAd = NativeAd()
            //assets
            if let assets = json["assets"] as? [AnyObject] {
                for adObject in assets {
                    if let adObject = adObject as? [String : AnyObject]{
                        //title
                        if let title = adObject["title"], let text = title["text"] as? String {
                            ad.title = text;
                        }
                        //description
                        if let id = adObject["id"] as? Int, id == 3, let description = adObject["data"], let text = description["value"] as? String {
                            ad.text = text;
                        }
                        //sponsoredBy
                        if let id = adObject["id"] as? Int, id == 5, let sponsoredBy = adObject["data"], let text = sponsoredBy["value"] as? String {
                            ad.sponsoredBy = text;
                        }
                        //call to action
                        if let id = adObject["id"] as? Int, id == 4, let callToAction = adObject["data"], let text = callToAction["value"] as? String {
                            ad.callToAction = text;
                        }
                        if let img = adObject["img"]{
                            if let id = adObject["id"] as? Int, id == 2{
                                //img
                                if let url = img["url"] as? String {
                                    ad.imageUrl = url;
                                }
                            }else{
                                //icon
                                if let url = img["url"] as? String {
                                    ad.iconUrl = url;
                                }
                            }
                        }
                    }
                }
            }
            
            let price = response["price"] as? Double
            
            //clickUrl
            if let link = json["link"] as? [String : AnyObject], var url = link["url"] as? String {
                if (url.contains("{AUCTION_PRICE}") && price != nil){
                    url = url.replacingOccurrences(of: "{AUCTION_PRICE}", with: "\(price ?? 0.0)")
                }
                ad.clickUrl = url;
            }
            //eventtrackers
            if let eventtrackers = json["eventtrackers"] as? [AnyObject] {
                for eventtracker in eventtrackers {
                    if let eventtracker = eventtracker as? [String : AnyObject], var url = eventtracker["url"] as? String  {
                        if (url.contains("{AUCTION_PRICE}") && price != nil){
                            url = url.replacingOccurrences(of: "{AUCTION_PRICE}", with: "\(price ?? 0.0)")
                        }
                        ad.impTrackers.append(url)
                    }
                }
            }
            if ad.isValid() {
                CacheManager.shared.delegate = ad
                return ad
            }else{
                Log.error("Native Ad is not valid")
                return nil
            }
            
        } catch let error as NSError {
            Log.error("Failed to load: \(error.localizedDescription)")
        }
        return nil
    }
    
    private override init() {
        super.init()
    }
    
    deinit {
        unregisterViewFromTracking()
    }
    
    private func isValid() -> Bool{
        return !(title ?? "").isEmpty
        && !(text ?? "").isEmpty
        && !(callToAction ?? "").isEmpty
        && canOpenString(iconUrl)
        && canOpenString(imageUrl)
        && canOpenString(clickUrl)
    }
    
    private func canOpenString(_ string: String?) -> Bool {
        guard let string = string else {
            return false
        }
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count)) {
            return match.range.length == string.utf16.count
        } else {
            return false
        }
    }
    
    //MARK: registerView function
    @discardableResult 
    public func registerView(view: UIView?, clickableViews: [UIView]? ) -> Bool {
        guard let view = view else {
            Log.error("A valid view is required for tracking")
            return false
        }
        
        guard !expired else {
            Log.error("The native Ad is expired, cannot use it for tracking")
            return false
        }
        viewForTracking = view
        setupViewabilityTracker()
        attachGestureRecognizersToNativeView(nativeView: view, withClickableViews: clickableViews)
        return true
    }
    
    private func unregisterViewFromTracking(){
        detachAllGestureRecognizers()
        viewForTracking = nil
        invalidateTimer(viewabilityTimer)
    }
    
    //MARK: NativeAd Expire
    func cacheExpired() {
        if viewForTracking == nil {
            expired = true
            delegate?.adDidExpire?(ad: self)
            unregisterViewFromTracking()
        }
    }
    
    private func invalidateTimer(_ timer :Timer?){
        if let timer = timer, timer.isValid {
            timer.invalidate()
        }
    }
    
    
    //MARK: Impression Tracking
    private func setupViewabilityTracker(){
        let requiredAmountOfSimultaneousViewableEvents = lround(NativeAd.nativeAdIABShouldBeViewableForTrackingDuration / NativeAd.nativeAdCheckViewabilityForTrackingFrequency) + 1
        
        targetViewabilityValue = lround(pow(Double(2),Double(requiredAmountOfSimultaneousViewableEvents)) - 1)
        
        Log.debug("\n\trequiredAmountOfSimultaneousViewableEvents=\(requiredAmountOfSimultaneousViewableEvents) \n\ttargetViewabilityValue=\(targetViewabilityValue)")

        viewabilityTimer = Timer.scheduledTimer(withTimeInterval: NativeAd.nativeAdCheckViewabilityForTrackingFrequency, repeats: true) { [weak self] timer in
            guard let strongSelf = self else {
                timer.invalidate()
                Log.debug("FAILED TO ACQUIRE strongSelf viewabilityTimer")
                return
            }
            strongSelf.checkViewability()
        }
    }
    
    @objc private func checkViewability() {
        viewabilityValue = (viewabilityValue << 1 | (viewForTracking?.pb_isAtLeastHalfViewable() == true ? 1 : 0)) & targetViewabilityValue
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
                    Log.debug("FAILED TO ACQUIRE strongSelf for fireImpTrackers")
                    return
                }
                if isTrackerFired {
                    strongSelf.delegate?.adDidLogImpression?(ad: strongSelf)
                }
            }
        }
    }
    
    //MARK: Click handling
    private func attachGestureRecognizersToNativeView(nativeView: UIView, withClickableViews clickableViews: [UIView]?){
        if let clickableViews = clickableViews, clickableViews.count != 0 {
            clickableViews.forEach { clickableView in
                attachGestureRecognizerToView(view: clickableView)
            }
        }else{
            attachGestureRecognizerToView(view: nativeView)
        }
    }
    
    private func attachGestureRecognizerToView(view: UIView){
        view.isUserInteractionEnabled = true
        let record = NativeAdGestureRecognizerRecord.init()
        record.viewWithTracking = view
        if let button = view as? UIButton {
            button.addTarget(self, action: #selector(handleClick), for: .touchUpInside)
        }else{
            let clickRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(handleClick))
            view.addGestureRecognizer(clickRecognizer)
            record.gestureRecognizer = clickRecognizer
        }
        gestureRecognizerRecords.append(record)
    }
    
    private func detachAllGestureRecognizers(){
        gestureRecognizerRecords.forEach { record in
            if let view = record.viewWithTracking{
                if let button = view as? UIButton {
                    button.removeTarget(self, action: #selector(handleClick), for: .touchUpInside)
                }else if let gesture = record.gestureRecognizer as? UITapGestureRecognizer{
                    view.removeGestureRecognizer(gesture)
                }
            }
        }
        gestureRecognizerRecords.removeAll()
    }
    
    @objc private func handleClick() {
        self.delegate?.adWasClicked?(ad: self)
        if let clickUrl = clickUrl, let clickUrlString = clickUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: clickUrlString) {
            if !openURLWithExternalBrowser(url: url){
                Log.debug("Could not open click URL: \(clickUrl)")
            }
        }
    }
    
    private func openURLWithExternalBrowser(url : URL) -> Bool{
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            return true
        }else{
            return false
        }
    }
    
}

private class NativeAdGestureRecognizerRecord : NSObject {
    weak var viewWithTracking : UIView?
    weak var gestureRecognizer : UIGestureRecognizer?
    
    override init() {
        super.init()
    }
    
    deinit {
        viewWithTracking = nil
        gestureRecognizer = nil
    }
}


