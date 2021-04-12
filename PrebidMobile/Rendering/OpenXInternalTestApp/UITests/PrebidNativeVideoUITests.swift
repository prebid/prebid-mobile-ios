//
//  PrebidVideoNativeUITests.swift
//  OpenXInternalTestAppUITests
//
//  Copyright © 2021 OpenX. All rights reserved.
//

import UIKit

class PrebidNativeVideoUITest: RepeatedUITestCase {
    
    private let waitingTimeout = 10.0
    private let videoDuration = TimeInterval(17) + 2
    
    override func setUp() {
        useMockServerOnSetup = true
        super.setUp()
    }
    
    func testMediaPlaybackEvents() {
        repeatTesting(times: 7) {
            navigateToExamplesSection()
            navigateToExample("Native Ad - Video with End Card (PPM)")
            
            waitAd()
            
            let endCardLink = app.links.firstMatch
            waitForExists(element: endCardLink, waitSeconds: videoDuration)
            
            XCTAssertTrue(app.buttons["onMediaLoadingFinishedButton called"].isEnabled)
            XCTAssertTrue(app.buttons["onMediaPlaybackStartedButton called"].isEnabled)
            XCTAssertTrue(app.buttons["onMediaPlaybackFinishedButton called"].isEnabled)
        }
    }
    
    // MARK: - Private methods
    private func waitAd() {
        let adReceivedButton = app.buttons["getNativeAd success"]
        let adFailedToLoadButton = app.buttons["getNativeAd failed"]
        waitForEnabled(element: adReceivedButton, failElement: adFailedToLoadButton, waitSeconds: waitingTimeout)
    }
}
