//
//  ViewController.swift
//  iOSTestNativeNative
//
//  Created by Wei Zhang on 11/6/19.
//  Copyright © 2019 AppNexus. All rights reserved.
//

import UIKit
import GoogleMobileAds
import MoPub
import PrebidMobile

class NativeNativeViewController: UIViewController,DFPBannerAdLoaderDelegate, GADNativeCustomTemplateAdLoaderDelegate{

    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    // Screen height.
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    var buttonHeight: CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
//         Do any additional setup after loading the view.
        buttonHeight = buttonHeight + self.view.viewWithTag(1)!.frame.minY
        buttonHeight = buttonHeight + self.view.viewWithTag(1)!.frame.height
        buttonHeight = buttonHeight + self.view.viewWithTag(2)!.frame.height
        buttonHeight = buttonHeight + self.view.viewWithTag(3)!.frame.height
        buttonHeight = buttonHeight + self.view.viewWithTag(4)!.frame.height
    }
    
    
    func removePreviousAds() {
        if adContainer != nil {
            adContainer!.removeFromSuperview()
            adContainer = nil
        }
    }
    
    class UrlButton : UIButton{
        var urlString: String?
    }
    
    @objc func ctaButtonClicked(sender: UIButton){
        if (sender is UrlButton) {
            let urlButton = sender as! UrlButton
            guard let url = URL(string:urlButton.urlString!) else {
                return
            }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func renderPrebidNativeAd(ad: PrebidNativeAd) {
        let title = UITextView(frame: CGRect(x: 50, y:0  , width: self.screenWidth - 50 , height:50.0))
        title.text = ad.title
        let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 50 , height: 50))
        let iconUrl = URL(string: ad.iconUrl!)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: iconUrl!)
            DispatchQueue.main.async {
                icon.image = UIImage(data:data!)
            }
        }
        let description = UITextView(frame: CGRect(x: 0, y: 50, width: self.screenWidth, height: 50))
        description.text = ad.text
        let image = UIImageView(frame: CGRect(x: 0, y: 100, width: self.screenWidth, height: self.screenWidth * 400 / 600))
        let imageUrl = URL(string: ad.imageUrl!)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: imageUrl!)
            DispatchQueue.main.async {
                image.image = UIImage(data:data!)
            }
        }
        let cta = UrlButton(frame: CGRect(x: self.screenWidth - 100, y:  100 + self.screenWidth * 400 / 600, width: 100, height: 50))
        cta.setTitle(ad.callToAction, for: .normal)
        cta.urlString = ad.clickUrl
        cta.backgroundColor = UIColor.blue
        cta.addTarget(self, action: #selector(ctaButtonClicked), for: .touchUpInside)
        self.adContainer = UIView(frame: CGRect(x: 0, y: self.buttonHeight + 50, width: self.screenWidth, height: 150 + self.screenWidth * 400 / 600))
        self.adContainer?.addSubview(title)
        self.adContainer?.addSubview(icon)
        self.adContainer?.addSubview(description)
        self.adContainer?.addSubview(image)
        self.adContainer?.addSubview(cta)
        self.view.addSubview(self.adContainer!)
    }
    
    
    var adLoader: GADAdLoader?
    
    func loadDFPCustomRendering(_ usePrebid: Bool) {
        removePreviousAds()
        adLoader = GADAdLoader(adUnitID: "/19968336/Wei_test_native_native",
                               rootViewController: self,
                               adTypes: [ GADAdLoaderAdType.dfpBanner, GADAdLoaderAdType.nativeCustomTemplate],
                               options: [ ])
        adLoader!.delegate  = self
    
        let dfpRequest:DFPRequest = DFPRequest()
        if usePrebid {
            dfpRequest.customTargeting = ["hb_cache_id":"testId","hb_pb":"0.80"]
        }
        adLoader?.load(dfpRequest)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print("Prebid GADAdLoader failed \(error)")
    }
    
    func nativeCustomTemplateIDs(for adLoader: GADAdLoader) -> [String] {
        return ["11885766"]
    }

    func adLoader(_ adLoader: GADAdLoader,
                  didReceive nativeCustomTemplateAd: GADNativeCustomTemplateAd){
          print("Prebid GADAdLoader received customTemplageAd")
        let prebidDFPListener: PrebidDFPAdListenr = PrebidDFPAdListenr()
        prebidDFPListener.ref = self
        Util.shared.findNative(adObject: nativeCustomTemplateAd, listener: prebidDFPListener)
    }
    
    func validBannerSizes(for adLoader: GADAdLoader) -> [NSValue] {
        return [NSValueFromGADAdSize(kGADAdSizeBanner)]
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive bannerView: DFPBannerView) {
        self.adContainer = UIView(frame: CGRect(x: 0, y: self.buttonHeight + 50, width: self.screenWidth, height:50))
        self.adContainer?.addSubview(bannerView)
        self.view.addSubview(self.adContainer!)
    }
    var adContainer: UIView?
    
    class PrebidDFPAdListenr: PrebidNativeAdListener {
        weak var ref: NativeNativeViewController!
        func onPrebidNativeLoaded(ad: PrebidNativeAd) {
            // display ad
            ref.renderPrebidNativeAd(ad: ad)
        }
        
        func onPrebidNativeNotFound() {
            
            
        }
        func onPrebidNativeNotValid() {
            
        }
    }
    

    class PrebidMoPubAdListener: PrebidNativeAdListener {
        weak var ref: NativeNativeViewController!
        func onPrebidNativeNotValid() {
            
        }
        func onPrebidNativeNotFound() {
            
            ref.renderMoPubNativeAd()
        }
        func onPrebidNativeLoaded(ad:PrebidNativeAd) {
            ref.renderPrebidNativeAd(ad: ad)
        }
    }
    
    func renderMoPubNativeAd( ) {
        let title = UITextView(frame: CGRect(x: 50, y:0  , width: self.screenWidth - 50 , height:50.0))
        let properties: [AnyHashable: Any] = mpAd!.properties!
        print("Prebid \(properties)")
        title.text = properties["title"] as! String
        let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 50 , height: 50))
        let iconUrl = URL(string: properties["iconimage"] as! String)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: iconUrl!)
            DispatchQueue.main.async {
                icon.image = UIImage(data:data!)
            }
        }
        let description = UITextView(frame: CGRect(x: 0, y: 50, width: self.screenWidth, height: 50))
        description.text = properties["text"] as! String
        let image = UIImageView(frame: CGRect(x: 0, y: 100, width: self.screenWidth, height: self.screenWidth * 400 / 600))
        let imageUrl = URL(string: properties["mainimage"] as! String)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: imageUrl!)
            DispatchQueue.main.async {
                image.image = UIImage(data:data!)
            }
        }
//        let cta = UrlButton(frame: CGRect(x: self.screenWidth - 100, y:  100 + self.screenWidth * 400 / 600, width: 100, height: 50))
//        cta.setTitle(properties["ctatext"] as! String, for: .normal)
//        cta.urlString = properties["clk"] as! String
//        cta.backgroundColor = UIColor.blue
//        cta.addTarget(self, action: #selector(ctaButtonClicked), for: .touchUpInside)
        self.adContainer = UIView(frame: CGRect(x: 0, y: self.buttonHeight + 50, width: self.screenWidth, height: 150 + self.screenWidth * 400 / 600))
        self.adContainer?.addSubview(title)
        self.adContainer?.addSubview(icon)
        self.adContainer?.addSubview(description)
        self.adContainer?.addSubview(image)
//        self.adContainer?.addSubview(cta)
        self.view.addSubview(self.adContainer!)
    }
    var mpNative:MPNativeAdRequest?
    var mpAd: MPNativeAd?
    func loadMoPubNative(usePrebid: Bool){
        self.removePreviousAds()
        let settings: MPStaticNativeAdRendererSettings = MPStaticNativeAdRendererSettings.init()
        let config:MPNativeAdRendererConfiguration = MPStaticNativeAdRenderer.rendererConfiguration(with: settings)
        self.mpNative = MPNativeAdRequest.init(adUnitIdentifier: "2674981035164b2db5ef4b4546bf3d49", rendererConfigurations: [config])
        if usePrebid {
            let targeting:MPNativeAdRequestTargeting = MPNativeAdRequestTargeting.init()
            targeting.keywords = "hb_pb:0.50,hb_cache_id:testid"
            self.mpNative?.targeting = targeting
        }
        
        self.mpNative?.start(completionHandler: { (request, response, error)->Void in
            if error == nil {
                self.mpAd = response!
                let prebidListener: PrebidMoPubAdListener = PrebidMoPubAdListener()
                prebidListener.ref  = self
                Util.shared.findNative(adObject: response!, listener: prebidListener)
            }
        })
    }

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
}

