//
//  TrackerInfo.swift
//  PrebidMobile
//
//  Created by Akash.Verma on 06/11/20.
//  Copyright © 2020 AppNexus. All rights reserved.
//

import UIKit

class TrackerInfo: NSObject {

    var URL : String?
    var dateCreated : Date?
    var expired = false
    var numberOfTimesFired = 0
    private var expirationTimer : Timer?
    
    init(URL : String) {
        self.URL = URL
        self.dateCreated = Date()
        super.init()
        createExpirationTimer()
    }
    func createExpirationTimer(){
        expirationTimer = Timer.scheduledTimer(timeInterval: Constants.kANTrackerExpirationInterval, target: self, selector:#selector(fireTimer), userInfo: nil, repeats:false)
    }
    
    @objc func fireTimer(timer: Timer) {
        expired = true
        timer.invalidate()
    }
    
    deinit {
        expirationTimer?.invalidate()
    }
}
