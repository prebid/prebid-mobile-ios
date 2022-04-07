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
import MoPubSDK
import PrebidMobile

class NativeInAppViewController: UIViewController, GAMBannerAdLoaderDelegate, GADCustomNativeAdLoaderDelegate {

    //MARK: : IBOutlet
    @IBOutlet weak var adContainerView: UIView!
    
    //MARK: : Properties
    var adLoader: GADAdLoader?
    var mpNative:MPNativeAdRequest?
    var mpAd: MPNativeAd?
    var nativeAd:NativeAd?
    var nativeAdView: NativeAdView?
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
        
        Prebid.shared.shouldAssignNativeAssetID = true
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers =
       ["f2a7d257f84db8b1c4d7dd441323ad98"]
        
        if (adServerName == "DFP") {
            print("entered \(adServerName) loop" )
            setupAndLoadNativeInAppForDFP()
            
        } else if (adServerName == "MoPub") {
            print("entered \(adServerName) loop" )
            setupAndLoadNativeInAppForMoPub()
        }
    }
    
    //MARK: Setup NativeAd
    func setupAndLoadNativeInAppForDFP() {
        setupPBNativeInApp(host: .Custom, accountId: "9325", configId: "24659163")
        loadNativeInAppForDFP()
    }

    func setupAndLoadNativeInAppForMoPub() {
        setupPBNativeInApp(host: .Custom, accountId: "9325", configId: "24659163")
        loadNativeInAppForMoPub()
    }
    
    func setupPBNativeInApp(host: PrebidHost, accountId: String, configId: String) {
//        Prebid.shared.prebidServerHost = host
//        Prebid.shared.prebidServerAccountId = accountId
        
        createNativeInAppView()
        loadNativeAssets(configId)
    }
    
    //MARK: : Native functions
    func loadNativeAssets(_ configId: String){
        
        let image = NativeAssetImage(minimumWidth: 200, minimumHeight: 200, required: true)
        image.type = ImageAsset.Main
        
        let icon = NativeAssetImage(minimumWidth: 20, minimumHeight: 20, required: true)
        icon.type = ImageAsset.Icon
        
        let title = NativeAssetTitle(length: 90, required: true)
        
        let body = NativeAssetData(type: DataAsset.description, required: true)
        
        let cta = NativeAssetData(type: DataAsset.ctatext, required: true)
        
        let sponsored = NativeAssetData(type: DataAsset.sponsored, required: true)
        
        nativeUnit = NativeRequest(configId: configId, assets: [icon,title,image,body,cta,sponsored])
        
        nativeUnit.context = ContextType.Social
        nativeUnit.placementType = PlacementType.FeedContent
        nativeUnit.contextSubType = ContextSubType.Social
        
        let event1 = EventType.Impression
        eventTrackers = NativeEventTracker(event: event1, methods: [EventTracking.Image,EventTracking.js])
        nativeUnit.eventtrackers = [eventTrackers]
    }
    
    func createNativeInAppView(){
        removePreviousAds()
        let adNib = UINib(nibName: "NativeAdView", bundle: Bundle(for: type(of: self)))
        let array = adNib.instantiate(withOwner: self, options: nil)
        if let NativeAdView = array.first as? NativeAdView{
            self.nativeAdView = NativeAdView
            NativeAdView.frame = CGRect(x: 0, y: 0, width: self.adContainerView.frame.size.width, height: 150 + self.screenWidth * 400 / 600)
            self.adContainerView.addSubview(NativeAdView)
        }
    }
    
    //MARK: Prebid NativeAd MoPub
    func loadNativeInAppForMoPub(){
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
    func loadNativeInAppForDFP(){
        let dfpRequest = GAMRequest()
        nativeUnit.fetchDemand(adObject: dfpRequest) { [weak self] (resultCode: ResultCode) in
            self?.callDFP(dfpRequest)
        }
    }
    
    func callDFP(_ dfpRequest: GAMRequest){
        adLoader = GADAdLoader(adUnitID: "/19968336/PSP_M22_Abhishek_Native",
                               rootViewController: self,
                               adTypes: [ GADAdLoaderAdType.gamBanner, GADAdLoaderAdType.customNative],
                               options: [ ])
        adLoader?.delegate  = self
        adLoader?.load(dfpRequest)
    }
    

    //MARK: : DFP Native Delegate
    func adLoader(_ adLoader: GADAdLoader, didReceive bannerView: GAMBannerView) {
        nativeAdView?.addSubview(bannerView)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("Prebid GADAdLoader failed \(error)")
    }
    
    func validBannerSizes(for adLoader: GADAdLoader) -> [NSValue] {
        return [NSValueFromGADAdSize(GADAdSizeBanner)];
    }
    
    //MARK: GADCustomNativeAdLoaderDelegate
    func customNativeAdFormatIDs(for adLoader: GADAdLoader) -> [String] {
        return ["12103713"]
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive customNativeAd: GADCustomNativeAd) {
        print("Prebid GADAdLoader received customTemplageAd")
        Utils.shared.delegate = self
        Utils.shared.findNative(adObject: customNativeAd)
    }
    
    //MARK: Rendering Prebid Native
    func renderNativeInAppAd() {
        nativeAdView?.titleLabel.text = nativeAd?.title
        nativeAdView?.bodyLabel.text = nativeAd?.text
        if let iconString = nativeAd?.iconUrl, let iconUrl = URL(string: iconString) {
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: iconUrl)
                DispatchQueue.main.async {
                    if data != nil {
                        self.nativeAdView?.iconImageView.image = UIImage(data:data!)
                    }
                }
            }
        }
        if let imageString = nativeAd?.imageUrl,let imageUrl = URL(string: imageString) {
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: imageUrl)
                DispatchQueue.main.async {
                    if data != nil {
                     self.nativeAdView?.mainImageView.image = UIImage(data:data!)
                    }
                }
            }
        }
        nativeAdView?.callToActionButton.setTitle(nativeAd?.callToAction, for: .normal)
        nativeAdView?.sponsoredLabel.text = nativeAd?.sponsoredBy
    }
    
    func renderMoPubNativeAd( ) {
        if let mpAd = mpAd, let properties = mpAd.properties {
            nativeAdView?.titleLabel.text = properties["title"] as? String
            nativeAdView?.bodyLabel.text = properties["text"] as? String
            if let iconString = properties["iconimage"] as? String, let iconUrl = URL(string: iconString) {
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: iconUrl)
                    DispatchQueue.main.async {
                        if data != nil {
                            self.nativeAdView?.iconImageView.image = UIImage(data:data!)
                        }
                    }
                }
            }
            if let imageString = properties["mainimage"] as? String,let imageUrl = URL(string: imageString) {
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: imageUrl)
                    DispatchQueue.main.async {
                        if data != nil {
                            self.nativeAdView?.mainImageView.image = UIImage(data:data!)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: : Helper functions
    
    func registerNativeInAppView(){
        nativeAd?.delegate = self
        if  let nativeAdView = nativeAdView {
            nativeAd?.registerView(view: nativeAdView, clickableViews: [nativeAdView.callToActionButton])
        }
    }
    
    func removePreviousAds() {
        if nativeAdView != nil {
            nativeAdView?.iconImageView = nil
            nativeAdView?.mainImageView = nil
            nativeAdView!.removeFromSuperview()
            nativeAdView = nil
        }
        if nativeAd != nil {
            nativeAd = nil
        }
    }
}

extension NativeInAppViewController : NativeAdDelegate{
    
    func nativeAdLoaded(ad:NativeAd) {
        print("nativeAdLoaded")
        nativeAd = ad
        registerNativeInAppView()
        renderNativeInAppAd()
    }
    
    func nativeAdNotFound() {
        if (adServerName == "MoPub") {
            renderMoPubNativeAd( )
        }else {
            print("nativeAdNotFound")
        }
        
    }
    func nativeAdNotValid() {
        print("nativeAdNotValid")
    }
}

extension NativeInAppViewController : NativeAdEventDelegate{
    
    func adDidExpire(ad:NativeAd){
        print("adDidExpire")
    }
    func adWasClicked(ad:NativeAd){
        print("adWasClicked")
    }
    func adDidLogImpression(ad:NativeAd){
        print("adDidLogImpression")
    }
}
