//
//  MockoxmCreativeModel!.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import Foundation
@testable import OpenXApolloSDK

class MockOXMAdModelEventTracker: OXMAdModelEventTracker {
    
    var mock_trackEvent: ((OXMTrackingEvent) -> Void)?
    override func trackEvent(_ event: OXMTrackingEvent) {
        mock_trackEvent?(event)
    }
    
    var mock_trackVideoAdLoaded: ((OXMVideoVerificationParameters) -> Void)?
    override func trackVideoAdLoaded(_ parameters: OXMVideoVerificationParameters)  {
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
