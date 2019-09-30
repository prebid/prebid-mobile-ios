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
import GoogleInteractiveMediaAds

@objcMembers
public class VideoImaView: UIView, VideoImaLoaderDelegate, VideoImaDelegate  {

    public weak var pbVideoAdDelegate: PBVideoAdDelegate? {
        didSet {
            imaAdapter.pbVideoAdDelegate = pbVideoAdDelegate
        }
    }
    
    var muteSwitcher: UIButton!
    
    private let imaAdapter = ImaAdapter()
    private var adsLoader: IMAAdsLoader?
    private var adsManager: IMAAdsManager?
    
    private var adCanBePlayed: Bool = false
    
    //initWithFrame to init view from code
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialization()
    }
    
    //initWithCode to init view from xib or storyboard
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialization()
    }
    
    // MARK: - Public API
    public func loadAd(videoAdUnit: VideoAdUnit, adUnitId: String) {

        loadAdAndAutoPlay(adUnit: videoAdUnit, adUnitId: adUnitId)
    }
    
    public func reset() {
        
        resetAdsManager()
        resetAdsLoader()
        resetView()
    }
    
    // MARK: - internal API
    func add(videoImaDelegate: VideoImaDelegate) {
        imaAdapter.videoImaDelegateStorage.add(videoImaDelegate)
    }
    
    func remove(videoImaDelegate: VideoImaDelegate) {
        imaAdapter.videoImaDelegateStorage.remove(videoImaDelegate)
    }
    
    func loadAdAndAutoPlay(adUnit: AdUnit, adUnitId: String) {
        adCanBePlayed = true
        
        makeAuctionAndLoadAd(adUnit: adUnit, adUnitId: adUnitId)
    }
    
    func loadAdWithoutAutoPlay(adUnit: AdUnit, adUnitId: String) {
        adCanBePlayed = false
        
        makeAuctionAndLoadAd(adUnit: adUnit, adUnitId: adUnitId)
    }
    
    private func makeAuctionAndLoadAd(adUnit: AdUnit, adUnitId: String) {
        
        reset()
        setup()
        
        let targetingDict = NSMutableDictionary()
        
        adUnit.fetchDemand(adObject: targetingDict) { [weak self] (resultCode: ResultCode) in
            
            let resultCodeName = resultCode.name()
            
            if (resultCode == .prebidDemandFetchSuccess) {
                
                let keywords = targetingDict as! Dictionary<String, String>
                
                let adSlotSize = adUnit.adSizes[0]
                let adTagUrl = VideoUtils.buildAdTagUrl(adUnitId: adUnitId, adSlotSize: "\(Int(adSlotSize.width))x\(Int(adSlotSize.height))", targeting: keywords)
                
                self?.loadAd(adTagUrl: adTagUrl)
                //                self?.loadAd(adTagUrl: "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dskippablelinear&correlator=1")
                
            } else {
                self?.pbVideoAdDelegate?.videoAd(event: VideoAdEventFactory.getAdLoadFail(typeString: resultCodeName))
            }
        }
        
    }
    
    func setAutoPlayAndShowAd() {
        adCanBePlayed = true
        checkAutoPlayAndShowAd()
    }
    
    // MARK: - private API
    private func initialization() {
        initMuteSwitcher()
        
        initImaAdapter()
    }
    
    private func initImaAdapter() {
        
        add(videoImaDelegate: self)
        imaAdapter.videoImaLoaderDelegate = self
        
    }
    
    private func getStatusBarHeight() -> CGFloat {
        let statusBarSize = UIApplication.shared.statusBarFrame.size
        return Swift.min(statusBarSize.width, statusBarSize.height)
    }
    
    private func initMuteSwitcher() {
        muteSwitcher = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        muteSwitcher.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        muteSwitcher.layer.cornerRadius = 5
        muteSwitcher.setTitle("Unmute", for: .normal)
        muteSwitcher.sizeToFit()
        muteSwitcher.setTitleColor(UIColor.white, for: .normal)
        muteSwitcher.titleLabel?.font = .systemFont(ofSize: 15)
        
        muteSwitcher.addTarget(self, action: #selector(onMuteSwitcherPress), for: .touchUpInside)
    }
    
    @objc
    private func onMuteSwitcherPress(sender: UIButton!) {
        if (adsManager?.volume == 0) {
            //Unmute
            sender.setTitle("Mute", for: .normal)
            adsManager?.volume = 1
        } else {
            //Mute
            sender.setTitle("Unmute", for: .normal)
            adsManager?.volume = 0
        }
        
    }
    
    //common func to init our view
    private func setup() {
        setupAdsLoader()
    }
    
    private func setupAdsLoader() {
        adsLoader = IMAAdsLoader(settings: nil)
        adsLoader!.delegate = imaAdapter
        
    }
    
    private func setupAdsManager(adsLoadedData: IMAAdsLoadedData) {
        adsManager = adsLoadedData.adsManager
        adsManager!.delegate = imaAdapter
        

        let adsRenderingSettings = IMAAdsRenderingSettings()
        //        tell the SDK to use the in-app browser.
        //        adsRenderingSettings.webOpenerPresentingController = self
        
        adsManager!.initialize(with: adsRenderingSettings)
        
        adsManager!.volume = 0

    }
    
    private func loadAd(adTagUrl: String) {
        
        // Create ad display container for ad rendering.
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: self)
        // Create an ad request with our ad tag, display container, and optional user context.
        let request = IMAAdsRequest(
            adTagUrl: adTagUrl,
            adDisplayContainer: adDisplayContainer,
            contentPlayhead: nil,
            userContext: nil)
        
        adsLoader?.requestAds(with: request)
        
    }
    
    private func checkAutoPlayAndShowAd() {
        
        if (adCanBePlayed == true) {
            adsManager?.start()
        }
        
    }
    
    private func showMuteSwitcher() {
        self.addSubview(muteSwitcher)
    }
    
    private func resetAdsManager() {
        if (adsManager != nil) {
            adsManager!.delegate = nil
            adsManager!.destroy()
            adsManager = nil
        }
    }
    
    private func resetAdsLoader() {
        if (adsLoader != nil) {
            adsLoader!.delegate = nil
            adsLoader = nil
        }
    }
    
    private func resetView() {
        
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        
    }
    
    //MARK: - ImaAdsLoaderDelegate
    func adDidLoad(adsLoadedData: IMAAdsLoadedData) {
        
        setupAdsManager(adsLoadedData: adsLoadedData)
    }
    
    //MARK: - VideoImaDelegate
    func adLoaded() {
        checkAutoPlayAndShowAd()
    }
    
    func adStarted() {
        showMuteSwitcher()
    }
    
    func allAdsCompleted() {
        resetView()
    }

}

// MARK: - IMA IMAAdsLoaderDelegate
private protocol VideoImaLoaderDelegate: AnyObject {
    func adDidLoad(adsLoadedData: IMAAdsLoadedData)
}

// MARK: - IMA IMAAdsManagerDelegate
@objc
protocol VideoImaDelegate: AnyObject {
    
    @objc
    optional func adLoaded()
    @objc
    optional func adStarted()
    @objc
    optional func adSkipped()
    @objc
    optional func adFinished()
    @objc
    optional func adPlayingFailed()
    @objc
    optional func allAdsCompleted()
}

private class ImaAdapter: NSObject, IMAAdsLoaderDelegate, IMAAdsManagerDelegate {
    
    fileprivate weak var videoImaLoaderDelegate: VideoImaLoaderDelegate?
    fileprivate let videoImaDelegateStorage = NSHashTable<VideoImaDelegate>.weakObjects()
    fileprivate weak var pbVideoAdDelegate: PBVideoAdDelegate?
    
    override init() {
    }
    
    // MARK: - IMAAdsLoaderDelegate
    public func adsLoader(_ loader: IMAAdsLoader!, adsLoadedWith adsLoadedData: IMAAdsLoadedData!) {
        
        videoImaLoaderDelegate?.adDidLoad(adsLoadedData: adsLoadedData)
    }
    
    public func adsLoader(_ loader: IMAAdsLoader!, failedWith adErrorData: IMAAdLoadingErrorData!) {
        
        let errorMessage = adErrorData.adError.message
        pbVideoAdDelegate?.videoAd(event: VideoAdEventFactory.getAdLoadFail(typeString: errorMessage))
        
        Log.error("adsLoader failed:\(errorMessage ?? "")")
    }

    // MARK: - IMAAdsManagerDelegate
    public func adsManager(_ adsManager: IMAAdsManager!, didReceive event: IMAAdEvent!) {

        let message = event.typeString
        Log.debug("adsManager eventType:\(message ?? "")")
        
        let eventString = event.typeString
        //Event handler
        switch (event.type) {
        case IMAAdEventType.LOADED:
            
            iterateVideoImaDelegates { (videoImaDelegate) in
                videoImaDelegate.adLoaded?()
            }
            pbVideoAdDelegate?.videoAd(event: VideoAdEventFactory.getAdLoadSuccess(typeString: eventString))
            break
            
        case IMAAdEventType.STARTED:
            
            iterateVideoImaDelegates { (videoImaDelegate) in
                videoImaDelegate.adStarted?()
            }
            pbVideoAdDelegate?.videoAd(event: VideoAdEventFactory.getAdStarted(typeString: eventString))
            break
            
        case IMAAdEventType.COMPLETE:
            
            iterateVideoImaDelegates { (videoImaDelegate) in
                videoImaDelegate.adFinished?()
            }
            pbVideoAdDelegate?.videoAd(event: VideoAdEventFactory.getAdDidReachEnd(typeString: eventString))
            break
            
        case IMAAdEventType.CLICKED:
            pbVideoAdDelegate?.videoAd(event: VideoAdEventFactory.getAdClicked(typeString: eventString))
            break
            
        case IMAAdEventType.SKIPPED:
            iterateVideoImaDelegates { (videoImaDelegate) in
                videoImaDelegate.adSkipped?()
            }
            break
            
        case IMAAdEventType.ALL_ADS_COMPLETED:
            iterateVideoImaDelegates { (videoImaDelegate) in
                videoImaDelegate.allAdsCompleted?()
            }
            break
            
        default:
            break
        }
    }
    
    public func adsManager(_ adsManager: IMAAdsManager!, didReceive error: IMAAdError!) {
        // Something went wrong with the ads manager after ads were loaded. Log the error and play the
        // content.
        let errorMessage = error.message
        Log.error("AdsManager error:\(errorMessage ?? "")")
        
        iterateVideoImaDelegates { (videoImaDelegate) in
            videoImaDelegate.adPlayingFailed!()
        }
        
        pbVideoAdDelegate?.videoAd(event: VideoAdEventFactory.getAdLoadFail(typeString: errorMessage))
    }
    
    public func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager!) {
        // The SDK is going to play ads.
    }
    
    public func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager!) {
        // The SDK is done playing ads (at least for now)
    }
    
    private func iterateVideoImaDelegates(closure: (VideoImaDelegate) -> ())  {
        for delegate in videoImaDelegateStorage.objectEnumerator() {
            closure(delegate as! VideoImaDelegate)
        }
    }
}
