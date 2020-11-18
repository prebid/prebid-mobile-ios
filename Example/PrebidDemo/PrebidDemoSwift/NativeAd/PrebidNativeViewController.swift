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

import UIKit
import GoogleMobileAds
import MoPub
import PrebidMobile

class PrebidNativeViewController: UIViewController,DFPBannerAdLoaderDelegate, GADNativeCustomTemplateAdLoaderDelegate {

    //MARK: : IBOutlet
    @IBOutlet weak var adContainerView: UIView!
    @IBOutlet weak var adContainerHeight: NSLayoutConstraint!
    
    //MARK: : Properties
    var adLoader: GADAdLoader?
    var mpNative:MPNativeAdRequest?
    var mpAd: MPNativeAd?
    var prebidNativeAd: PrebidNativeAd?
    var prebidNativeAdView: PrebidNativeAdView?
    var nativeUnit: NativeRequest!
    var eventTrackers: NativeEventTracker!
    
    var dummyMockData = "{\n" +
    "  \"ver\": \"1.2\",\n" +
    "  \"assets\": [\n" +
    "    {\n" +
    "      \"id\": 1,\n" +
    "      \"img\": {\n" +
    "        \"type\": 3,\n" +
    "        \"url\": \"https://helpx.adobe.com/content/dam/help/en/stock/how-to/visual-reverse-image-search-v2_297x176.jpg\",\n" +
    "        \"w\": 300,\n" +
    "        \"h\": 250,\n" +
    "        \"ext\": {\n" +
    "          \"appnexus\": {\n" +
    "            \"prevent_crop\": 0\n" +
    "          }\n" +
    "        }\n" +
    "      }\n" +
    "    },\n" +
    "    {\n" +
    "      \"data\": {\n" +
    "        \"type\": 1,\n" +
    "        \"value\": \"AppNexus\"\n" +
    "      }\n" +
    "    },\n" +
    "    {\n" +
    "      \"id\": 2,\n" +
    "      \"title\": {\n" +
    "        \"text\": \"This is a test ad for Prebid Native Native. Please check prebid.org\"\n" +
    "      }\n" +
    "    }\n" +
    "  ],\n" +
    "  \"link\": {\n" +
    "    \"url\": \"https://sin1-mobile.adnxs.com/click?AAAAAAAAFEAAAAAAAAAUQAAAAOB6FBRAAAAAAAAAFEAAAAAAAAAUQPMOEsNk_1IcCnsNaXSWPFKOfotcAAAAAAVDygC-AwAAvgMAAAIAAABALNsFy50TAAAAAABVU0QAVVNEAAEAAQARIAAAAAABAQQCAAAAAAAAsBIdJQAAAAA./bcr=AAAAAAAA8D8=/cnd=%21BQ5rlwj9694LEMDY7C4Yy7tOIAQoADEAAAAAAAAUQDoJU0lOMTozNTg0QNYISQAAAAAAAPA_UQAAAAAAAAAAWQAAAAAAAAAA/cca=OTU4I1NJTjE6MzU4NA==/bn=81577/referrer=itunes.apple.com%2Fus%2Fapp%2Fappnexus-sdk-app%2Fid736869833\"\n" +
    "  },\n" +
    "  \"eventtrackers\": [\n" +
    "    {\n" +
    "      \"event\": 1,\n" +
    "      \"method\": 1,\n" +
    "      \"url\": \"https://sin1-mobile.adnxs.com/it?referrer=itunes.apple.com%2Fus%2Fapp%2Fappnexus-sdk-app%2Fid736869833&e=wqT_3QLDB6DDAwAAAwDWAAUBCI79reQFEPOdyJjM7L-pHBiK9rXIxs6lnlIqNgkAAAECCBRAEQEHNAAAFEAZAAAA4HoUFEAhERIAKREJADERG6AwhYapBji-B0C-B0gCUMDY7C5Yy7tOYABokUB4qf0EgAEBigEDVVNEkgUG8GaYAQGgAQGoAQGwAQC4AQHAAQTIAQLQAQDYAQDgAQDwAQD6ARJ1bml2ZXJzYWxQbGFjZW1lbnSKAjt1ZignYScsIDE3OTc4NjUsIDE1NTI2NDU3NzQpO3VmKCdyJywgOTgyNDk3OTIsMh4A8JCSAvkBIVNqbTNJd2o5Njk0TEVNRFk3QzRZQUNETHUwNHdBRGdBUUFSSXZnZFFoWWFwQmxnQVlPSUhhQUJ3TW5pc3JnR0FBVEtJQWF5dUFaQUJBWmdCQWFBQkFhZ0JBN0FCQUxrQjg2MXFwQUFBRkVEQkFmT3RhcVFBQUJSQXlRRWFQY1U4QVpIeFA5a0JBQUFBAQMkOERfZ0FRRDFBUQEOQENZQWdDZ0F2X19fXzhQdFFJARUEQXYNCHx3QUlBeUFJQTRBSUE2QUlBLUFJQWdBTUJtQU1CcUFQOQHUgHVnTUpVMGxPTVRvek5UZzA0QVBXQ0EuLpoCYSFCUTVybDr8ACh5N3RPSUFRb0FERQVsGEFBQVVRRG8yRAAQUU5ZSVMFoBhBQUFQQV9VEQwMQUFBVx0MiNgC6AfgAsfTAeoCNGl0dW5lcy5hcHBsZS5jb20vdXMvYXBwAQQkbmV4dXMtc2RrLQER8LFpZDczNjg2OTgzM4ADAYgDAZADAJgDF6ADAaoDAMAD4KgByAMA0gMoCAASJDJhYjBkNmIwLWY1NTYtNGY1NC1iMzY3LWU0YzE5MDZlMzgxZtgD-aN64AMA6AMC-AMAgAQAkgQGL3V0L3YzmAQAogQLMTAuMTQuMTIuMTWoBI7sAbIEDAgAEAEYACAAMAA4ArgEAMAEAMgEANIEDTk1OCNTSU4xOjM1ODTaBAIIAeAEAfAEQdwMggUJNxG3IIgFAZgFAKAF_xEBFAHABQDJBWkiFPA_0gUJCQkMcAAA2AUB4AUB8AUB-gUECAAQAJAGAZgGALgGAMEGCSMo8D_IBgDaBhYKEAA6AQAYEAAYAOAGDA..&s=0652533731f0fabbda6eb54f4cad13e323bcd3b0\"\n" +
    "    }\n" +
    "  ]\n" +
    "}"
    
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    //MARK: : ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK: : IBActions
    @IBAction func loadDFPWithoutPrebid(_ sender: Any) {
        loadDFPCustomRendering(false)
    }
    
    @IBAction func loadDFPWithPrebid(_ sender: Any) {
        loadDFPCustomRendering(true)
    }
    
    @IBAction func loadMoPubWithoutPrebid(_ sender: Any) {
        loadMoPubNative(usePrebid: false)
    }
    @IBAction func loadMoPubWithPrebid(_ sender: Any) {
        loadMoPubNative(usePrebid: true)
    }
    
    @IBAction func loadPrebidNativeNativeWithDFP(_ sender: Any) {
        loadPrebidNativeForDFP()
    }
    
    @IBAction func loadPrebidNativeNativeWithMoPub(_ sender: Any) {
        loadPrebidNativeForMoPub()
    }
    
    
    @IBAction func scrollEnabled(_ sender: UISwitch) {
        if sender.isOn{
            let newConstraint = adContainerHeight.constraintWithMultiplier(1.2)
            view.removeConstraint(adContainerHeight)
            view.addConstraint(newConstraint)
            view.layoutIfNeeded()
            adContainerHeight = newConstraint
        }else{
            let newConstraint = adContainerHeight.constraintWithMultiplier(0.6)
            view.removeConstraint(adContainerHeight)
            view.addConstraint(newConstraint)
            view.layoutIfNeeded()
            adContainerHeight = newConstraint
        }
    }
    
    //MARK: Prebid NativeAd MoPub
    func loadPrebidNativeForMoPub(){
        removePreviousAds()
        createPrebidNativeView()
        loadNativeAssets()
        
        let settings: MPStaticNativeAdRendererSettings = MPStaticNativeAdRendererSettings.init()
        let config:MPNativeAdRendererConfiguration = MPStaticNativeAdRenderer.rendererConfiguration(with: settings)
        self.mpNative = MPNativeAdRequest.init(adUnitIdentifier: "2674981035164b2db5ef4b4546bf3d49", rendererConfigurations: [config])

        let targeting:MPNativeAdRequestTargeting = MPNativeAdRequestTargeting.init()
        self.mpNative?.targeting = targeting
        
        nativeUnit.fetchDemand(adObject: mpNative!) { [weak self] (resultCode: ResultCode) in
            print("Prebid demand fetch for AdManager \(resultCode.name())")
            self?.loadMoPub(self?.mpNative)
        }
    }
    
    func loadMoPub(_ mpNative: MPNativeAdRequest?){
        mpNative!.start(completionHandler: { (request, response, error)->Void in
            if error == nil {
                self.mpAd = response!
                Utils.shared.delegate = self
                Utils.shared.findNative(adObject: response!)
            }
        })
    }
    
    //MARK: Prebid NativeAd DFP
    func loadPrebidNativeForDFP(){
        removePreviousAds()
        createPrebidNativeView()
        loadNativeAssets()
        let dfpRequest:DFPRequest = DFPRequest()
        nativeUnit.fetchDemand(adObject: dfpRequest) { [weak self] (resultCode: ResultCode) in
            self?.loadDFP(dfpRequest)
        }
    }
    
    func loadDFP(_ dfpRequest: DFPRequest){
        adLoader = GADAdLoader(adUnitID: "/19968336/Wei_test_native_native",
                               rootViewController: self,
                               adTypes: [ GADAdLoaderAdType.dfpBanner, GADAdLoaderAdType.nativeCustomTemplate],
                               options: [ ])
        adLoader?.delegate  = self
        adLoader?.load(dfpRequest)
    }
    
    func loadNativeAssets(){
        
        let image = NativeAssetImage(minimumWidth: 200, minimumHeight: 200, required: true)
        image.type = ImageAsset.Main
        
        let icon = NativeAssetImage(minimumWidth: 20, minimumHeight: 20, required: true)
        icon.type = ImageAsset.Icon
        
        let title = NativeAssetTitle(length: 90, required: true)
        
        let body = NativeAssetData(type: DataAsset.description, required: true)
        
        let cta = NativeAssetData(type: DataAsset.ctatext, required: true)
        
        let sponsored = NativeAssetData(type: DataAsset.sponsored, required: true)
        
        nativeUnit = NativeRequest(configId: "25e17008-5081-4676-94d5-923ced4359d3", assets: [icon,title,image,body,cta,sponsored])
        
        nativeUnit.context = ContextType.Social
        nativeUnit.placementType = PlacementType.FeedContent
        nativeUnit.contextSubType = ContextSubType.Social
        
        let event1 = EventType.Impression
        eventTrackers = NativeEventTracker(event: event1, methods: [EventTracking.Image,EventTracking.js])
        nativeUnit.eventtrackers = [eventTrackers]
    }
    
    //MARK: DFP
    func loadDFPCustomRendering(_ usePrebid: Bool) {
        removePreviousAds()
        createPrebidNativeView()
        adLoader = GADAdLoader(adUnitID: "/19968336/Wei_test_native_native",
                               rootViewController: self,
                               adTypes: [ GADAdLoaderAdType.dfpBanner, GADAdLoaderAdType.nativeCustomTemplate],
                               options: [ ])
        adLoader?.delegate  = self
    
        let dfpRequest:DFPRequest = DFPRequest()
        
        if let cacheId = CacheManager.shared.save(content: dummyMockData), !cacheId.isEmpty &&  usePrebid {
            dfpRequest.customTargeting = ["hb_cache_id":cacheId,"hb_pb":"0.80"]
        }
        adLoader?.load(dfpRequest)
    }
    
    //MARK: : DFP Native Delegate
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print("Prebid GADAdLoader failed \(error)")
    }
    
    func nativeCustomTemplateIDs(for adLoader: GADAdLoader) -> [String] {
        return ["11885766"]
    }

    func adLoader(_ adLoader: GADAdLoader,
                  didReceive nativeCustomTemplateAd: GADNativeCustomTemplateAd){
        print("Prebid GADAdLoader received customTemplageAd")
        Utils.shared.delegate = self
        Utils.shared.findNative(adObject: nativeCustomTemplateAd)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive bannerView: DFPBannerView) {
        prebidNativeAdView?.addSubview(bannerView)
    }
    
    func validBannerSizes(for adLoader: GADAdLoader) -> [NSValue] {
        return [NSValueFromGADAdSize(kGADAdSizeBanner)]
    }
    
    //MARK: Mopub
    func loadMoPubNative(usePrebid: Bool){
        removePreviousAds()
        createPrebidNativeView()
        let settings: MPStaticNativeAdRendererSettings = MPStaticNativeAdRendererSettings.init()
        let config:MPNativeAdRendererConfiguration = MPStaticNativeAdRenderer.rendererConfiguration(with: settings)
        self.mpNative = MPNativeAdRequest.init(adUnitIdentifier: "2674981035164b2db5ef4b4546bf3d49", rendererConfigurations: [config])
         if let cacheId = CacheManager.shared.save(content: dummyMockData), !cacheId.isEmpty &&  usePrebid
         {
            let targeting:MPNativeAdRequestTargeting = MPNativeAdRequestTargeting.init()
            targeting.keywords = "hb_pb:0.50,hb_cache_id:\(cacheId)"
            self.mpNative?.targeting = targeting
        }
        
        self.mpNative?.start(completionHandler: { (request, response, error)->Void in
            if error == nil {
                self.mpAd = response!
                Utils.shared.delegate = self
                Utils.shared.findNative(adObject: response!)
            }
        })
    }
    
    //MARK: Rendering Prebid Native
    func renderPrebidNativeAd() {
        prebidNativeAdView?.titleLabel.text = prebidNativeAd?.title
        prebidNativeAdView?.bodyLabel.text = prebidNativeAd?.text
        if let iconString = prebidNativeAd?.iconUrl, let iconUrl = URL(string: iconString) {
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: iconUrl)
                DispatchQueue.main.async {
                    if data != nil {
                        self.prebidNativeAdView?.iconImageView.image = UIImage(data:data!)
                    }
                }
            }
        }
        if let imageString = prebidNativeAd?.imageUrl,let imageUrl = URL(string: imageString) {
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: imageUrl)
                DispatchQueue.main.async {
                    if data != nil {
                     self.prebidNativeAdView?.mainImageView.image = UIImage(data:data!)
                    }
                }
            }
        }
        prebidNativeAdView?.callToActionButton.setTitle(prebidNativeAd?.callToAction, for: .normal)
        prebidNativeAdView?.sponsoredLabel.text = prebidNativeAd?.sponsoredBy
    }
    
    func renderMoPubNativeAd( ) {
        if let mpAd = mpAd, let properties = mpAd.properties {
            prebidNativeAdView?.titleLabel.text = properties["title"] as? String
            prebidNativeAdView?.bodyLabel.text = properties["text"] as? String
            if let iconString = properties["iconimage"] as? String, let iconUrl = URL(string: iconString) {
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: iconUrl)
                    DispatchQueue.main.async {
                        if data != nil {
                            self.prebidNativeAdView?.iconImageView.image = UIImage(data:data!)
                        }
                    }
                }
            }
            if let imageString = properties["mainimage"] as? String,let imageUrl = URL(string: imageString) {
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: imageUrl)
                    DispatchQueue.main.async {
                        if data != nil {
                            self.prebidNativeAdView?.mainImageView.image = UIImage(data:data!)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: : Native functions
    func createPrebidNativeView(){
        let adNib = UINib(nibName: "PrebidNativeAdView", bundle: Bundle(for: type(of: self)))
        let array = adNib.instantiate(withOwner: self, options: nil)
        if let prebidNativeAdView = array.first as? PrebidNativeAdView{
            self.prebidNativeAdView = prebidNativeAdView
            prebidNativeAdView.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: 150 + self.screenWidth * 400 / 600)
            self.adContainerView.addSubview(prebidNativeAdView)
        }
    }
    
    func registerPrebidNativeView(){
        prebidNativeAd?.delegate = self
        if  let prebidNativeAdView = prebidNativeAdView {
            prebidNativeAd?.registerView(view: prebidNativeAdView, clickableViews: [prebidNativeAdView.callToActionButton])
        }
    }
    
    //MARK: : Helper functions
    func removePreviousAds() {
        if prebidNativeAdView != nil {
            prebidNativeAdView?.iconImageView = nil
            prebidNativeAdView?.mainImageView = nil
            prebidNativeAdView!.removeFromSuperview()
            prebidNativeAdView = nil
        }
        if prebidNativeAd != nil {
            prebidNativeAd = nil
        }
    }
}

extension PrebidNativeViewController : PrebidNativeAdDelegate{
    
    func prebidNativeAdLoaded(ad: PrebidNativeAd) {
        // display ad
        prebidNativeAd = ad
        registerPrebidNativeView()
        renderPrebidNativeAd()
    }
    
    func prebidNativeAdNotFound() {
       // renderMoPubNativeAd()
        
    }
    func prebidNativeAdNotValid() {
        
    }
}

extension PrebidNativeViewController : PrebidNativeAdEventDelegate{
    
    func adDidExpire(ad:PrebidNativeAd){
        print("adDidExpire")
    }
    func adWasClicked(ad:PrebidNativeAd){
        print("adWasClicked")
    }
    func adDidLogImpression(ad:PrebidNativeAd){
        print("adDidLogImpression")
    }
}

extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}


