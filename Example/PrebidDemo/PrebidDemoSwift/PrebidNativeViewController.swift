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

class PrebidNativeViewController: UIViewController,DFPBannerAdLoaderDelegate, GADNativeCustomTemplateAdLoaderDelegate {

    //MARK: : IBOutlet
    @IBOutlet weak var adContainerView: UIView!
    
    //MARK: : Properties
    var adLoader: GADAdLoader?
    var adContainer: UIView?
    var mpNative:MPNativeAdRequest?
    var mpAd: MPNativeAd?
    
    var dummyCacheData = "{\"title\":\"Test title\",\"description\":\"This is a test ad for Prebid Native Native. Please check prebid.org\",\"cta\":\"Learn More\",\"iconUrl\":\"https://dummyimage.com/40x40/000/fff\",\"imageUrl\":\"https://dummyimage.com/600x400/000/fff\",\"clickUrl\":\"https://prebid.org/\"}"
    
    var dummyMockData = "{\n" +
    "  \"ver\": \"1.2\",\n" +
    "  \"assets\": [\n" +
    "    {\n" +
    "      \"id\": 1,\n" +
    "      \"img\": {\n" +
    "        \"type\": 3,\n" +
    "        \"url\": \"https://vcdn.adnxs.com/p/creative-image/7e/71/90/27/7e719027-80ef-4664-9b6d-a763da4cea4e.png\",\n" +
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
    "        \"text\": \"This is an RTB ad\"\n" +
    "      }\n" +
    "    }\n" +
    "  ],\n" +
    "  \"link\": {\n" +
    "    \"url\": \"https://nym1-ib.adnxs.com/click?mpmZmZmZqT-amZmZmZmpPwAAAAAAAOA_mpmZmZmZqT-amZmZmZmpP8GRp4bdjMle__________8UQVpfAAAAAHu99gBuJwAAbicAAAIAAACRL6wJ-MwcAAAAAABVU0QAVVNEAAEAAQDILwAAAAABAgMCAAAAAMYAfyvwMQAAAAA./bcr=AAAAAAAA8D8=/pp=${AUCTION_PRICE}/cnd=%211BKZHAiFzYATEJHfsE0Y-JlzIAQoADGamZmZmZmpPzoJTllNMjo0MDU2QKYkSQAAAAAAAPA_UQAAAAAAAAAAWQAAAAAAAAAAYQAAAAAAAAAAaQAAAAAAAAAAcQAAAAAAAAAAeAA./cca=MTAwOTQjTllNMjo0MDU2/bn=77455/clickenc=http%3A%2F%2Fappnexus.com\"\n" +
    "  },\n" +
    "  \"eventtrackers\": [\n" +
    "    {\n" +
    "      \"event\": 1,\n" +
    "      \"method\": 1,\n" +
    "      \"url\": \"https://nym1-ib.adnxs.com/it?an_audit=0&e=wqT_3QLhCWzhBAAAAwDWAAUBCJSC6foFEMGjnrXYm-PkXhj_EQEUASo2CZqZAQEIqT8REQkEGQAFAQjgPyEREgApEQkAMQUauADgPzD7-toHOO5OQO5OSAJQkd-wTVj4mXNgAGjI34wBeI_dBIABAYoBA1VTRJIBAQbwVZgBAaABAagBAbABALgBAsABA8gBAtABANgBAOABAPABAIoCPHVmKCdhJywgMzM5MzUyMCwgMTU5OTc1MDQyMCk7dWYoJ3InLCAxNjIyNzkzMTMsIDE1GR_0DgGSAvkDIWdGazdGZ2lGellBVEVKSGZzRTBZQUNENG1YTXdBRGdBUUFSSTdrNVEtX3JhQjFnQVlQX19fXzhQYUFCd0FYZ0JnQUVCaUFFQmtBRUJtQUVCb0FFQnFBRURzQUVBdVFGMXF3MXNtcG1wUDhFQmRhc05iSnFacVRfSkFYd2xrdlZtdVBBXzJRRUFBQUFBQUFEd1AtQUJBUFVCQUFBQUFKZ0NBS0FDQUxVQ0FBQUFBTDBDQUFBQUFNQUNBY2dDQWRBQ0FkZ0NBZUFDQU9nQ0FQZ0NBSUFEQVpnREFhZ0RoYzJBRTdvRENVNVpUVEk2TkRBMU51QURwaVNJQkFDUUJBQ1lCQUhCQkFBQUFBCYMIeVFRCQkBARhOZ0VBUEVFAQsJASBDSUJkZ2ZxUVUJDxhBRHdQN0VGDQ0UQUFBREJCHT8AeRUoDEFBQU4yKAAAWi4oAPBANEFXSUpfQUY0djN4QV9nRjhJX1BBWUlHQTFWVFJJZ0dBSkFHQVpnR0FLRUdtcG1abVptWnFULW9CZ0d5QmlRSkEBYAkBAFIJBwUBAFoFBgkBAGgJBwEBQEM0QmdvLpoCiQEhMUJLWkhBNv0BMC1KbHpJQVFvQURHYW0Fa1htcFB6b0pUbGxOTWpvME1EVTJRS1lrUxHpDFBBX1URDAxBQUFXHQwAWR0MAGEdDABjHQzwpGVBQS7YAgDgAsqoTYADAYgDAJADAJgDFKADAaoDAMAD4KgByAMA2AMA4AMA6AMC-AMAgAQAkgQJL29wZW5ydGIymAQAqAQAsgQMCAAQABgAIAAwADgAuAQAwAQAyAQA0gQPMTAwOTQjTllNMjo0MDU22gQCCAHgBADwBJHfsE2CBRpvcmcucHJlYmlkLm1vYmlsZS5hcGkxZGVtb4gFAZgFAKAF_3X8sKoFJDZhZjFlZmQ3LWJlNmMtNDlmMS04MTk2LWViNjI0NWI5ZWFjZsAFAMkFAGX5FPA_0gUJCQULOAAAANgFAeAFAfAFAfoFBAGwKJAGAZgGALgGAMEGAR8wAADwP9AG1jPaBhYKEAkRGQFcEAAYAOAGDPIGAggAgAcBiAcAoAdBugcOAUgEGAAJ-CRAAMgHj90E0gcNFXMwEAAYANoHBggAEAAYAA..&s=46d93f84d8459a2ca773485e5721255200b9f0ed&pp=${AUCTION_PRICE}\"\n" +
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

    
    //MARK: : Helper functions
    func removePreviousAds() {
        if adContainer != nil {
            adContainer!.removeFromSuperview()
            adContainer = nil
        }
    }
    
    func renderPrebidNativeAd(ad: PrebidNativeAd) {
        ad.delegate = self
        ad.registerView(view: adContainerView, withRootViewController: self, clickableViews: nil)
        
        let title = UITextView(frame: CGRect(x: 50, y:0  , width: self.screenWidth - 50 , height:50.0))
        title.isEditable = false
        title.text = ad.title ?? ""
        let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 50 , height: 50))
        if let iconString = ad.iconUrl, let iconUrl = URL(string: iconString) {
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: iconUrl)
                DispatchQueue.main.async {
                    icon.image = UIImage(data:data!)
                }
            }
        }
        let description = UITextView(frame: CGRect(x: 0, y: 50, width: self.screenWidth, height: 50))
        description.text = ad.text ?? ""
        let image = UIImageView(frame: CGRect(x: 0, y: 100, width: self.screenWidth, height: self.screenWidth * 400 / 600))
        if let imageString = ad.imageUrl,let imageUrl = URL(string: imageString) {
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: imageUrl)
                DispatchQueue.main.async {
                    image.image = UIImage(data:data!)
                }
            }
        }
        let cta = UrlButton(frame: CGRect(x: self.screenWidth - 100, y:  100 + self.screenWidth * 400 / 600, width: 100, height: 50))
        cta.setTitle(ad.callToAction, for: .normal)
        cta.urlString = ad.clickUrl
        cta.backgroundColor = UIColor.blue
        cta.addTarget(self, action: #selector(ctaButtonClicked), for: .touchUpInside)
        self.adContainer = UIView(frame: CGRect(x: 0, y: 0, width: self.screenWidth, height: 150 + self.screenWidth * 400 / 600))
        self.adContainer?.addSubview(title)
        self.adContainer?.addSubview(icon)
        self.adContainer?.addSubview(description)
        self.adContainer?.addSubview(image)
        self.adContainer?.addSubview(cta)
        self.adContainerView.addSubview(self.adContainer!)
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
    
    func renderMoPubNativeAd( ) {
        let title = UITextView(frame: CGRect(x: 50, y:0  , width: self.screenWidth - 50 , height:50.0))
        let properties: [AnyHashable: Any] = mpAd!.properties!
        print("Prebid \(properties)")
        title.text = properties["title"] as? String
        let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 50 , height: 50))
        let iconUrl = URL(string: properties["iconimage"] as! String)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: iconUrl!)
            DispatchQueue.main.async {
                icon.image = UIImage(data:data!)
            }
        }
        let description = UITextView(frame: CGRect(x: 0, y: 50, width: self.screenWidth, height: 50))
        description.text = properties["text"] as? String
        let image = UIImageView(frame: CGRect(x: 0, y: 100, width: self.screenWidth, height: self.screenWidth * 400 / 600))
        let imageUrl = URL(string: properties["mainimage"] as! String)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: imageUrl!)
            DispatchQueue.main.async {
                image.image = UIImage(data:data!)
            }
        }
        self.adContainer = UIView(frame: CGRect(x: 0, y: 0, width: self.screenWidth, height: 150 + self.screenWidth * 400 / 600))
        self.adContainer?.addSubview(title)
        self.adContainer?.addSubview(icon)
        self.adContainer?.addSubview(description)
        self.adContainer?.addSubview(image)
        self.adContainerView.addSubview(self.adContainer!)
    }
    
    //MARK: : DFP Load function
    func loadDFPCustomRendering(_ usePrebid: Bool) {
        removePreviousAds()
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
        self.adContainer = UIView(frame: CGRect(x: 0, y: 0, width: self.screenWidth, height:50))
        self.adContainer?.addSubview(bannerView)
        self.adContainerView.addSubview(self.adContainer!)
    }
    
    func validBannerSizes(for adLoader: GADAdLoader) -> [NSValue] {
        return [NSValueFromGADAdSize(kGADAdSizeBanner)]
    }
    
    //MARK: : Mopub Native Closure
    func loadMoPubNative(usePrebid: Bool){
        self.removePreviousAds()
        let settings: MPStaticNativeAdRendererSettings = MPStaticNativeAdRendererSettings.init()
        let config:MPNativeAdRendererConfiguration = MPStaticNativeAdRenderer.rendererConfiguration(with: settings)
        self.mpNative = MPNativeAdRequest.init(adUnitIdentifier: "2674981035164b2db5ef4b4546bf3d49", rendererConfigurations: [config])
         if let cacheId = CacheManager.shared.save(content: dummyCacheData), !cacheId.isEmpty &&  usePrebid
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
}

extension PrebidNativeViewController : PrebidNativeAdDelegate{
    
    func prebidNativeAdLoaded(ad: PrebidNativeAd) {
        // display ad
        renderPrebidNativeAd(ad: ad)
    }
    
    func prebidNativeAdNotFound() {
        renderMoPubNativeAd()
        
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
