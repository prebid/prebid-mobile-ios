//
//  UserCentricsHelper.swift
//  ozone20230308
//
//  Created by Mark Birch on 09/03/2023.
//

import Foundation
import Usercentrics
import UsercentricsUI
import UIKit


class UserCentricsHelper: NSObject {

    public var tcString:String = ""
    
    public static let shared = UserCentricsHelper() // always use this to get a shared reference
    
    public func tryCmp(outLabel: UILabel?) {
        /**
         * NOTE - make sure this code runs after networking has been set up - there will be an error if this is in, eg, AppDelegate.didFinishLaunchingWithOptions
         */
        print("going to configure usercentrics")
        
        let options = UsercentricsOptions(settingsId: "WCxxFhip98YKKI") // Rupesh 20230329 - CCPA
//        let options = UsercentricsOptions(settingsId: "x1Y_PNLY58mmMO") // TCF2.0
//        let options = UsercentricsOptions(settingsId: "SK7PP6qyLnU_P9") // not TCF2.0 selected
        UsercentricsCore.configure(options: options)
        // pop up the usercentrics cmp
        UsercentricsCore.isReady { [weak self] status in
            guard let self = self else { return }
            
            // unconditionally pop up the cmp:
            outLabel?.text = "Unconditionally popup the cmp"
            self.collectConsent()

            // you can conditionally popup the cmp like this:
//            if status.shouldCollectConsent {
//                print("we should collect consent")
//                outLabel?.text = "CMP we need to collect consents"
//                self.collectConsent()
//            } else {
//                // Apply consent with status.consents
//                print("no need to collect consents - apply these already collected consents now ... \(status)")
//                print(status.consents)
//                outLabel?.text = "CMP no need to collect consents"
//            }
        } onFailure: { error in
            print("onFailure ... \(error)")
            // Handle non-localized error
            outLabel?.text = "CMP Error: \(error)"
        }
    }
    
    /**
     * common code you can call from anywhere, to show the cmp & handle the response
     */
    private func collectConsent() {
        print("in collectConsent")
        let banner = UsercentricsBanner()
        banner.showFirstLayer() { userResponse in
            // Handle userResponse - see https://docs.usercentrics.com/cmp_in_app_sdk/latest/integration/usercentrics-ui/
//            userResponse.consents // List of the user's consent choices needed to apply consent.
//            userResponse.userInteraction // Response given by user: AcceptAll: User accepted all services, DenyAll: User denied all service. Granular: User gave a granular choice, No Interaction: User dismissed the Banner with no response.
//            userResponse.controllerId // A Usercentrics generated ID, used to identify a specific user. This value is required when using Cross-Device Consent Sharing.
            UsercentricsCore.shared.getTCFData() { tcfData in
                self.tcString = tcfData.tcString // store this, so we can access it later
                print("tcString stored: \(self.tcString)")
            }
            print("user response to firstLayer")
            print("userResponse.consents \(userResponse.consents)")
            print("userResponse.userInteraction \(userResponse.userInteraction)")
            print("userResponse.controllerId \(userResponse.controllerId)")
        }
    }
    
    /**
     * get the TC String (if set inside userResponse earlier)
     * @todo - check what happens when we change views 
     */
    public func getTcString() -> String {
        return (self.tcString)
    }

    
}
