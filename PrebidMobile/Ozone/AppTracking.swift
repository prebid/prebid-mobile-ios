//
//  AppTracking.swift
//  ozone20230308
//
//  Created by Mark Birch on 09/03/2023.
//

import Foundation
import AppTrackingTransparency
import AdSupport
import UIKit


class AppTracking: NSObject {
    
    
    //NEWLY ADDED PERMISSIONS FOR iOS 14
    func requestPermission(vc: ViewController?) {
        var outLabel: String = ""
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    // Tracking authorization dialog was shown
                    // and we are authorized
                    // Now that we are authorized we can get the IDFA
                    let idfa = ASIdentifierManager.shared().advertisingIdentifier
                    outLabel = "Authorized: \(idfa)"
                    print(idfa)
                case .denied:
                    // Tracking authorization dialog was
                    // shown and permission is denied
                    outLabel = "Denied"
                case .notDetermined:
                    // Tracking authorization dialog has not been shown
                    outLabel = "Not Determined"
                case .restricted:
                    outLabel = "Restricted"
                @unknown default:
                    outLabel = "Unknown"
                }
            }
        } else {
            outLabel = "requestPermission iOS 14 not available"
        }
        print("ATTrackingManager \(outLabel)")
        DispatchQueue.global(qos: .background).async {
                    DispatchQueue.main.async {
                        vc?.setOutLabel(txt: "AppTrackingTransparency: \(outLabel)")
                    }
                }

    }
}
