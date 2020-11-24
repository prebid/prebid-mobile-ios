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
    
    //MARK: : Properties
    var adLoader: GADAdLoader?
    var mpNative:MPNativeAdRequest?
    var mpAd: MPNativeAd?
    var prebidNativeAd: PrebidNativeAd?
    var prebidNativeAdView: PrebidNativeAdView?
    var nativeUnit: NativeRequest!
    var eventTrackers: NativeEventTracker!
    var adServerName: String = ""

    
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    //MARK: : ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (adServerName == "DFP") {
            print("entered \(adServerName) loop" )
            loadPrebidNativeForDFP()
            
        } else if (adServerName == "MoPub") {
            print("entered \(adServerName) loop" )
            loadPrebidNativeForMoPub()
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
            self?.callMoPub(self?.mpNative)
        }
    }
    
    func callMoPub(_ mpNative: MPNativeAdRequest?){
        if let mpNative = mpNative{
            mpNative.start(completionHandler: { (request, response, error)->Void in
                if error == nil {
                    self.mpAd = response!
                    Utils.shared.delegate = self
                    Utils.shared.findNative(adObject: response!)
                }
            })
        }
    }
    
    //MARK: Prebid NativeAd DFP
    func loadPrebidNativeForDFP(){
        removePreviousAds()
        createPrebidNativeView()
        loadNativeAssets()
        let dfpRequest:DFPRequest = DFPRequest()
        nativeUnit.fetchDemand(adObject: dfpRequest) { [weak self] (resultCode: ResultCode) in
            self?.callDFP(dfpRequest)
        }
    }
    
    func callDFP(_ dfpRequest: DFPRequest){
        adLoader = GADAdLoader(adUnitID: "/19968336/Abhas_test_native_native_adunit",
                               rootViewController: self,
                               adTypes: [ GADAdLoaderAdType.dfpBanner, GADAdLoaderAdType.nativeCustomTemplate],
                               options: [ ])
        adLoader?.delegate  = self
        adLoader?.load(dfpRequest)
    }
    

    //MARK: : DFP Native Delegate
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print("Prebid GADAdLoader failed \(error)")
    }
    
    func nativeCustomTemplateIDs(for adLoader: GADAdLoader) -> [String] {
        return ["11963183"]
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
    
    func createPrebidNativeView(){
        let adNib = UINib(nibName: "PrebidNativeAdView", bundle: Bundle(for: type(of: self)))
        let array = adNib.instantiate(withOwner: self, options: nil)
        if let prebidNativeAdView = array.first as? PrebidNativeAdView{
            self.prebidNativeAdView = prebidNativeAdView
            prebidNativeAdView.frame = CGRect(x: 0, y: 0, width: self.adContainerView.frame.size.width, height: 150 + self.screenWidth * 400 / 600)
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
        print("prebidNativeAdLoaded")
        prebidNativeAd = ad
        registerPrebidNativeView()
        renderPrebidNativeAd()
    }
    
    func prebidNativeAdNotFound() {
        if (adServerName == "MoPub") {
            renderMoPubNativeAd( )
        }else {
            print("prebidNativeAdNotFound")
        }
        
    }
    func prebidNativeAdNotValid() {
        print("prebidNativeAdNotValid")
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
