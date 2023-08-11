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

@objcMembers
public class NativeAd: NSObject, CacheExpiryDelegate {
    
    // MARK: - Public properties
    
    public var nativeAdMarkup: NativeAdMarkup?
    public weak var delegate: NativeAdEventDelegate?
    
    // MARK: - Internal properties
    
    private static let nativeAdIABShouldBeViewableForTrackingDuration = 1.0
    private static let nativeAdCheckViewabilityForTrackingFrequency = 0.25
    
    //NativeAd Expire
    private var expired = false
    //Impression Tracker
    private var targetViewabilityValue = 0
    private var viewabilityTimer: Timer?
    private var viewabilityValue = 0
    private var impressionHasBeenTracked = false
    private weak var viewForTracking: UIView?
    //Click Handling
    private var gestureRecognizerRecords = [NativeAdGestureRecognizerRecord]()
    
    private let eventManager = EventManager()
    
    // MARK: - Array getters
    
    @objc public var titles: [NativeTitle] {
        nativeAdMarkup?.assets?.compactMap { return $0.title } ?? []
    }
    
    @objc public var dataObjects: [NativeData] {
        nativeAdMarkup?.assets?.compactMap { return $0.data } ?? []
    }
    
    @objc public var images: [NativeImage] {
        nativeAdMarkup?.assets?.compactMap { return $0.img } ?? []
    }
    
    @objc public var eventTrackers: [NativeEventTrackerResponse]? {
        return nativeAdMarkup?.eventtrackers
    }
    
    // MARK: - Filtered array getters
    
    @objc public func dataObjects(of dataType: NativeDataAssetType) -> [NativeData] {
        dataObjects.filter { $0.type == dataType.rawValue }
    }

    @objc public func images(of imageType: NativeImageAssetType) -> [NativeImage] {
        images.filter { $0.type == imageType.rawValue }
    }
    
    // MARK: - Property getters
    
    @objc public var title: String? {
        return titles.first?.text
    }
    
    @objc public var imageUrl: String? {
        return images(of: .main).first?.url
    }
    
    @objc public var iconUrl: String? {
        return images(of: .icon).first?.url
    }
    
    @objc public var sponsoredBy: String? {
        return dataObjects(of: .sponsored).first?.value
    }
    
    @objc public var text: String? {
        return dataObjects(of: .desc).first?.value
    }
    
    @objc public var callToAction: String? {
        return dataObjects(of: .ctaText).first?.value
    }
    
    public static func create(cacheId: String) -> NativeAd? {
        guard let bidString = CacheManager.shared.get(cacheId: cacheId),
              let bidDic = Utils.shared.getDictionaryFromString(bidString) else {
            Log.error("No bid response for provided cache id.")
            return nil
        }
        
        guard let rawBid = PBMORTBBid<PBMORTBBidExt>(jsonDictionary: bidDic, extParser: { extDic in
            return PBMORTBBidExt.init(jsonDictionary: extDic)
        }) else {
            return nil
        }
        
        let ad = NativeAd()
        
        let internalEventTracker = PrebidServerEventTracker()
        
        if let impURL = rawBid.ext.prebid?.events?.imp {
            let impEvent = ServerEvent(url: impURL, expectedEventType: .impression)
            internalEventTracker.addServerEvents([impEvent])
        }
        
        if let winURL = rawBid.ext.prebid?.events?.win {
            let winEvent = ServerEvent(url: winURL, expectedEventType: .prebidWin)
            internalEventTracker.addServerEvents([winEvent])
        }
        
        ad.eventManager.registerTracker(internalEventTracker)
        
        // Track win event immediately
        ad.eventManager.trackEvent(.prebidWin)
        
        guard let nativeAdMarkup = NativeAdMarkup(jsonString: rawBid.adm) else {
            Log.warn("Can't retrieve native ad markup from bid response.")
            return nil
        }
        
        ad.nativeAdMarkup = nativeAdMarkup
        
        CacheManager.shared.setDelegate(delegate: CacheExpiryDelegateWrapper(id: cacheId, delegate: ad))
        
        return ad
    }
    
    private override init() {
        super.init()
    }
    
    deinit {
        unregisterViewFromTracking()
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
    
    private func unregisterViewFromTracking() {
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
    
    private func invalidateTimer(_ timer :Timer?) {
        if let timer = timer, timer.isValid {
            timer.invalidate()
        }
    }
    
    
    //MARK: Impression Tracking
    private func setupViewabilityTracker() {
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
    
    private func trackImpression() {
        if !impressionHasBeenTracked {
            Log.debug("Firing impression trackers")
            fireEventTrackers()
            viewabilityTimer?.invalidate()
            eventManager.trackEvent(PBMTrackingEvent.impression)
            impressionHasBeenTracked = true
        }
    }
    
    private func fireEventTrackers() {
        if let eventTrackers = eventTrackers, eventTrackers.count > 0 {
            let eventTrackersUrls = eventTrackers.compactMap { $0.url }
            TrackerManager.shared.fireTrackerURLArray(arrayWithURLs: eventTrackersUrls) { [weak self] isTrackerFired in
                guard let strongSelf = self else {
                    Log.debug("FAILED TO ACQUIRE strongSelf for fireEventTrackers")
                    return
                }
                if isTrackerFired {
                    strongSelf.delegate?.adDidLogImpression?(ad: strongSelf)
                }
            }
        }
    }
    
    //MARK: Click handling
    private func attachGestureRecognizersToNativeView(nativeView: UIView, withClickableViews clickableViews: [UIView]?) {
        if let clickableViews = clickableViews, clickableViews.count > 0 {
            clickableViews.forEach { clickableView in
                attachGestureRecognizerToView(view: clickableView)
            }
        } else {
            attachGestureRecognizerToView(view: nativeView)
        }
    }
    
    private func attachGestureRecognizerToView(view: UIView) {
        view.isUserInteractionEnabled = true
        let record = NativeAdGestureRecognizerRecord.init()
        record.viewWithTracking = view
        if let button = view as? UIButton {
            button.addTarget(self, action: #selector(handleClick), for: .touchUpInside)
        } else {
            let clickRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(handleClick))
            view.addGestureRecognizer(clickRecognizer)
            record.gestureRecognizer = clickRecognizer
        }
        gestureRecognizerRecords.append(record)
    }
    
    private func detachAllGestureRecognizers() {
        gestureRecognizerRecords.forEach { record in
            if let view = record.viewWithTracking {
                if let button = view as? UIButton {
                    button.removeTarget(self, action: #selector(handleClick), for: .touchUpInside)
                } else if let gesture = record.gestureRecognizer as? UITapGestureRecognizer {
                    view.removeGestureRecognizer(gesture)
                }
            }
        }
        gestureRecognizerRecords.removeAll()
    }
    
    @objc private func handleClick() {
        self.delegate?.adWasClicked?(ad: self)
        if let clickUrl = nativeAdMarkup?.link?.url,
           let clickUrlString = clickUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: clickUrlString) {
            if openURLWithExternalBrowser(url: url) {
                if let clickTrackers = nativeAdMarkup?.link?.clicktrackers {
                    fireClickTrackers(clickTrackersUrls: clickTrackers)
                }
            } else {
                Log.debug("Could not open click URL: \(clickUrl)")
            }
        }
    }
    
    
    private func fireClickTrackers(clickTrackersUrls: [String]) {
        if clickTrackersUrls.count > 0 {
            TrackerManager.shared.fireTrackerURLArray(arrayWithURLs: clickTrackersUrls) {
                _ in
            }
        }
    }
    
    private func openURLWithExternalBrowser(url : URL) -> Bool {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return true
        } else {
            return false
        }
    }
    
}

private class NativeAdGestureRecognizerRecord : NSObject {
    weak var viewWithTracking: UIView?
    weak var gestureRecognizer: UIGestureRecognizer?
    
    override init() {
        super.init()
    }
    
    deinit {
        viewWithTracking = nil
        gestureRecognizer = nil
    }
}
