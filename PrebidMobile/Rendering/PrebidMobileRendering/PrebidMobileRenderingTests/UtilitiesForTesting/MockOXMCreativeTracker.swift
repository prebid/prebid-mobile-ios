//
//  MockoxmCreativeModel!.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import Foundation

@testable import PrebidMobileRendering

class MockPBMAdModelEventTracker: PBMAdModelEventTracker {
    
    var mock_trackEvent: ((PBMTrackingEvent) -> Void)?
    override func trackEvent(_ event: PBMTrackingEvent) {
        mock_trackEvent?(event)
    }
    
    var mock_trackVideoAdLoaded: ((PBMVideoVerificationParameters) -> Void)?
    override func trackVideoAdLoaded(_ parameters: PBMVideoVerificationParameters)  {
        mock_trackVideoAdLoaded?(parameters)
    }
    
    var mock_trackStartVideo: ((CGFloat, CGFloat) -> Void)?
    override func trackStartVideo(withDuration: CGFloat, volume:CGFloat) {
        mock_trackStartVideo?(withDuration, volume)
    }
    
    var mock_trackVolumeChanged: ((CGFloat, CGFloat) -> Void)?
    override func trackVolumeChanged(_ playerVolume: CGFloat, deviceVolume: CGFloat) {
        mock_trackVolumeChanged?(playerVolume, deviceVolume)
    }
}
