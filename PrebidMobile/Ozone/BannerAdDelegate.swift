//
//  BannerAdDelegate.swift
//  20230329_github_mod
//
//  Created by Mark Birch on 29/03/2023.
//

import Foundation
import UIKit
import PrebidMobile
import GoogleMobileAds


/**
 * If you dont want to add the subview until the ad comes back you can use use an instance of this to be the GADBannerViewDelegate;
 * this ensures that when a bid comes back you render it into the correct view
 *
 * eg.
 * var bannerDelegate1: BannerAdDelegate(outView: self.outputView, outLabel: outputLabel)
 * var bannerDelegate2: BannerAdDelegate(outView: self.outputView2, outLabel: outputLabel)
 *
 */
class BannerAdDelegate: NSObject, GADBannerViewDelegate {

    @IBOutlet weak var outputView: UIView! // this stores a ref to the UIView we have to append our subview to
    @IBOutlet weak var outputLabel: UILabel!

    
    init(outView: UIView, outLabel: UILabel) {
        self.outputView = outView
        self.outputLabel = outLabel
    }

    func addBannerViewToView(_ bv: GADBannerView) { // was GAM originally
        bv.translatesAutoresizingMaskIntoConstraints = false
        self.outputView.addSubview(bv)
    }
    
    // MARK: - bannerView callbacks
    
    
    // dfp response
    func bannerViewDidReceiveAd(_ bv: GADBannerView) {
        print("bannerViewDidReceiveAd - going to add to view")
        print(bv)
        
        // NOTE that this is being called on the wrong response - it's looking for hb_size in the dfp response not the prebid auction response ...?
        // this should always be done (https://docs.prebid.org/prebid-mobile/pbm-api/ios/code-integration-ios.html)
        
        // get the content from the banner view - this will be the response from dfp
        // use this to debug print the content received back from dfp ads? request
        
        //        print("We will not try to resize because we always get a fatal error trying to find the size in the repsonse")
        AdViewUtils.findPrebidCreativeSize(bv,
                                           success: { (size) in
            guard let bv = bv as? GAMBannerView else {
                print("will not resize the ad")
                return
            }
            self.outputLabel.text = "Ad is good, found hb_ keys"
            print("resizing the ad")
            bv.resize(GADAdSizeFromCGSize(size))
            
        },
            failure: { (error) in
            self.outputLabel.text = "Ignore this ad - this one has no hb_ keys in it"
            print("resize error: \(error)");
        })
        
        // Add banner to view and add constraints as above.
        addBannerViewToView(bv)
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("bannerViewDidRecordImpression")
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillPresentScreen")
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillDIsmissScreen")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewDidDismissScreen")
    }
    
    
}

