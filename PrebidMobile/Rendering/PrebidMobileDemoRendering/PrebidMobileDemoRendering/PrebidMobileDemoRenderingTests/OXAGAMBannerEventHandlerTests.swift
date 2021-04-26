//
//  PBMGAMBannerEventHandlerTests.swift
//  OpenXInternalTestAppTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation
import XCTest

import GoogleMobileAds

import PrebidMobileGAMEventHandlers

class PBMGAMBannerEventHandlerTests: XCTestCase {
    
    func testAdSizesConversion() {
     
        // Static sizes
        runSizeCheck(kGADAdSizeBanner           , CGSize(width: 320, height: 50))
        runSizeCheck(kGADAdSizeLargeBanner      , CGSize(width: 320, height: 100))
        runSizeCheck(kGADAdSizeMediumRectangle  , CGSize(width: 300, height: 250))
        runSizeCheck(kGADAdSizeFullBanner       , CGSize(width: 468, height: 60))
        runSizeCheck(kGADAdSizeLeaderboard      , CGSize(width: 728, height: 90))
        runSizeCheck(kGADAdSizeSkyscraper       , CGSize(width: 120, height: 600))

        // Dynamic sizes: need to test with iPhone 11

        /// An ad size that spans the full width of the application in portrait orientation. The height is
        /// typically 50 points on an iPhone/iPod UI, and 90 points tall on an iPad UI.
        runSizeCheck(kGADAdSizeSmartBannerPortrait, CGSize(width: 414, height: 50))


        /// An ad size that spans the full width of the application in landscape orientation. The height is
        /// typically 32 points on an iPhone/iPod UI, and 90 points tall on an iPad UI.
        runSizeCheck(kGADAdSizeSmartBannerLandscape, CGSize(width: 896, height: 32))


        /// An ad size that spans the full width of its container, with a height dynamically determined by
        /// the ad.
        runSizeCheck(kGADAdSizeFluid, CGSize(width: 414, height: 1))


        // Invalid ad size marker.
        runSizeCheck(kGADAdSizeInvalid, CGSize(width: 0, height: 0))
    }
    
    func testAdSizesArray() {
        
        let GADSizes = [    NSValueFromGADAdSize(kGADAdSizeBanner),
                            NSValueFromGADAdSize(kGADAdSizeMediumRectangle),
                            NSValueFromGADAdSize(kGADAdSizeInvalid)]
        
        let eventHandler = PBMGAMBannerEventHandler(adUnitID: "some_id", validGADAdSizes: GADSizes);
        
        XCTAssertEqual(eventHandler.adSizes.count, 3)
        
        XCTAssertEqual(eventHandler.adSizes[0].cgSizeValue  , CGSize(width: 320, height: 50))
        XCTAssertEqual(eventHandler.adSizes[1].cgSizeValue  , CGSize(width: 300, height: 250))
        XCTAssertEqual(eventHandler.adSizes[2].cgSizeValue  , CGSize(width: 0, height: 0))
    }
    
    func testInvalidValue() {
        runCheckInvalidValue(NSValue(nonretainedObject:42))
        runCheckInvalidValue(NSValue(pointer:"Do not panic!"))
    }
    
    
    func runSizeCheck(_ GADSize: GADAdSize, _ size: CGSize, file: StaticString = #file, line: UInt = #line) {
        
        let eventHandler = PBMGAMBannerEventHandler(adUnitID: "some_id", validGADAdSizes: [NSValueFromGADAdSize(GADSize)]);
        let val = eventHandler.adSizes.first!
        
        XCTAssertEqual(val.cgSizeValue, size, file: file, line: line)
    }
    
    func runCheckInvalidValue(_ value: NSValue, file: StaticString = #file, line: UInt = #line) {
        
        let eventHandler = PBMGAMBannerEventHandler(adUnitID: "some_id", validGADAdSizes: [value]);
        let val = eventHandler.adSizes.first!
        
        XCTAssertEqual(val.cgSizeValue, CGSize(width: 0, height: 0), file: file, line: line)
    }
}

