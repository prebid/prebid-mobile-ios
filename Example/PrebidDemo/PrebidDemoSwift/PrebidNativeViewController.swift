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
    @IBOutlet weak var adContainerHeight: NSLayoutConstraint!
    
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
                    if data != nil {
                    icon.image = UIImage(data:data!)
                    }
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
                    if data != nil {
                     image.image = UIImage(data:data!)
                    }
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
                if data != nil {
                icon.image = UIImage(data:data!)
                }
            }
        }
        let description = UITextView(frame: CGRect(x: 0, y: 50, width: self.screenWidth, height: 50))
        description.text = properties["text"] as? String
        let image = UIImageView(frame: CGRect(x: 0, y: 100, width: self.screenWidth, height: self.screenWidth * 400 / 600))
        let imageUrl = URL(string: properties["mainimage"] as! String)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: imageUrl!)
            DispatchQueue.main.async {
                if data != nil {
                image.image = UIImage(data:data!)
                }
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

extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}
