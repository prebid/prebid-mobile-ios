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
import StoreKit
import WebKit

/// Represents a native ad and handles its various properties and functionalities.
@objcMembers
public class NativeAd: NSObject, CacheExpiryDelegate {
    
    // MARK: - Public properties
    
    /// The native ad markup containing the ad assets.
    public var nativeAdMarkup: NativeAdMarkup?
    
    /// The delegate to receive native ad events.
    public weak var delegate: NativeAdEventDelegate?
    
    // MARK: - Internal properties
    
    var bid: Bid?
    
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
    
    private var productControllerPresenter: SKStoreProductViewControllerPresenter?
    
    // MARK: - Array getters
    
    /// Returns an array of titles from the native ad markup.
    @objc public var titles: [NativeTitle] {
        nativeAdMarkup?.assets?.compactMap { return $0.title } ?? []
    }
    
    /// Returns an array of data objects from the native ad markup.
    @objc public var dataObjects: [NativeData] {
        nativeAdMarkup?.assets?.compactMap { return $0.data } ?? []
    }
    
    /// Returns an array of images from the native ad markup.
    @objc public var images: [NativeImage] {
        nativeAdMarkup?.assets?.compactMap { return $0.img } ?? []
    }
    
    /// Returns an array of event trackers from the native ad markup.
    @objc public var eventTrackers: [NativeEventTrackerResponse]? {
        return nativeAdMarkup?.eventtrackers
    }
    
    public var privacyUrl: String? {
        set { nativeAdMarkup?.privacy = newValue }
        get { nativeAdMarkup?.privacy }
    }
    
    // MARK: - Filtered array getters
    
    /// Returns an array of data objects filtered by the specified data type.
    @objc public func dataObjects(of dataType: NativeDataAssetType) -> [NativeData] {
        dataObjects.filter { $0.type == dataType.rawValue }
    }

    /// Returns an array of images filtered by the specified image type.
    @objc public func images(of imageType: NativeImageAssetType) -> [NativeImage] {
        images.filter { $0.type == imageType.rawValue }
    }
    
    // MARK: - Property getters
    
    /// Returns the first title text from the native ad markup.
    @objc public var title: String? {
        return titles.first?.text
    }
    
    /// Returns the URL of the main image from the native ad markup.
    @objc public var imageUrl: String? {
        return images(of: .main).first?.url
    }
    
    /// Returns the URL of the icon image from the native ad markup.
    @objc public var iconUrl: String? {
        return images(of: .icon).first?.url
    }
    
    /// Returns the sponsored by text from the native ad markup.
    @objc public var sponsoredBy: String? {
        return dataObjects(of: .sponsored).first?.value
    }
    
    /// Returns the description text from the native ad markup.
    @objc public var text: String? {
        return dataObjects(of: .desc).first?.value
    }
    
    /// Returns the call-to-action text from the native ad markup.
    @objc public var callToAction: String? {
        return dataObjects(of: .ctaText).first?.value
    }
    
    /// Returns landing URL of the clickable link.
    @objc public var clickURL: String? {
        nativeAdMarkup?.link?.url
    }
    /// Creates a `NativeAd` instance from the given cache ID.
    /// - Parameter cacheId: The cache ID to retrieve the bid response.
    /// - Returns: A `NativeAd` instance if successful, otherwise `nil`.
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
        
        let bid = Bid(bid: rawBid)
        
        let ad = NativeAd()
        ad.bid = bid
        
        let internalEventTracker = PrebidServerEventTracker()
        
        if let impURL = bid.events?.imp {
            let impEvent = ServerEvent(url: impURL, expectedEventType: .impression)
            internalEventTracker.addServerEvents([impEvent])
        }
        
        if let burl = bid.burl {
            let billingEvent = ServerEvent(url: burl, expectedEventType: .impression)
            internalEventTracker.addServerEvents([billingEvent])
        }
        
        if let winURL = bid.events?.win {
            let winEvent = ServerEvent(url: winURL, expectedEventType: .prebidWin)
            internalEventTracker.addServerEvents([winEvent])
        }
        
        if let nurl = bid.nurl {
            let noticeEvent = ServerEvent(url: nurl, expectedEventType: .prebidWin)
            internalEventTracker.addServerEvents([noticeEvent])
        }
        
        ad.eventManager.registerTracker(internalEventTracker)
        
        if #available(iOS 14.5, *) {
            if let skadn = bid.skadn, let imp = SkadnParametersManager.getSkadnImpression(for: skadn) {
                let skadnEventTracker = SkadnEventTracker(with: imp)
                ad.eventManager.registerTracker(skadnEventTracker)
            }
        }
        
        // Track win event immediately
        ad.eventManager.trackEvent(.prebidWin)
        
        guard let nativeAdMarkup = NativeAdMarkup(jsonString: rawBid.adm) else {
            Log.error("SDK couldn't retrieve native ad markup from bid response.")
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
    
    /// Registers a view for tracking viewability and click events.
    /// - Parameters:
    ///   - view: The view to register.
    ///   - clickableViews: An array of views that should be clickable.
    /// - Returns: `true` if the view was successfully registered, otherwise `false`.
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
        if (viewForTracking != nil || impressionHasBeenTracked) {
            return false
        } else {
            viewForTracking = view
            setupViewabilityTracker()
            attachGestureRecognizersToNativeView(nativeView: view, withClickableViews: clickableViews)
            return true
        }
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
            if (strongSelf.viewForTracking == nil) {
                timer.invalidate()
            }
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
            eventManager.trackEvent(.impression)
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
        delegate?.adWasClicked?(ad: self)
        
        guard let clickUrl = nativeAdMarkup?.link?.url,
              let url = clickUrl.encodedURL(with: .urlQueryAllowed) else {
            return
        }
        
        // SKAdN
        if let skadn = bid?.skadn,
           let productParameters = SkadnParametersManager.getSkadnProductParameters(for: skadn) {
            HiddenWebViewManager(
                frame: .zero,
                landingPageString: url
            ).openHiddenWebView()
            
            if let viewControllerForPresentingModals = viewForTracking?.parentViewController ?? UIApplication.topViewController() {
                productControllerPresenter = SKStoreProductViewControllerPresenter()
                productControllerPresenter?.present(
                    from: viewControllerForPresentingModals,
                    using: productParameters
                )
            } else {
                Log.error("SDK couldn't find a view controller to present the SKStoreProductViewController from.")
            }
            
            fireClickTrackers()
        }
        // Normal clickthrough
        else if UIApplication.shared.openExternalURL(url) {
            fireClickTrackers()
        } else {
            Log.debug("Could not open click URL: \(clickUrl)")
        }
    }
    
    private func fireClickTrackers() {
        guard let clickTrackersURLs = nativeAdMarkup?.link?.clicktrackers,
              clickTrackersURLs.count > 0 else {
            return
        }
        
        TrackerManager.shared.fireTrackerURLArray(arrayWithURLs: clickTrackersURLs) { _ in }
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
