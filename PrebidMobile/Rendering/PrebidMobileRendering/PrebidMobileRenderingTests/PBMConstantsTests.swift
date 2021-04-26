//
//  PBMConstantsTests.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest
@testable import PrebidMobileRendering

class PBMConstantsTests: XCTestCase {
    
    func testLocationParamKeys() {
        XCTAssertEqual(LocationParamKeys.Latitude       , "lat")
        XCTAssertEqual(LocationParamKeys.Longitude      , "lon")
        XCTAssertEqual(LocationParamKeys.Country        , "cnt")
        XCTAssertEqual(LocationParamKeys.City           , "cty")
        XCTAssertEqual(LocationParamKeys.State          , "stt")
        XCTAssertEqual(LocationParamKeys.Zip            , "zip")
        XCTAssertEqual(LocationParamKeys.LocationSource , "lt")
    }
    
    func testPBMParseKey() {
        XCTAssertEqual(ParseKey.ADUNIT          , "adUnit")
        XCTAssertEqual(ParseKey.HEIGHT          , "height")
        XCTAssertEqual(ParseKey.WIDTH           , "width")
        XCTAssertEqual(ParseKey.HTML            , "html")
        XCTAssertEqual(ParseKey.IMAGE           , "image")
        XCTAssertEqual(ParseKey.NETWORK_UID     , "network_uid")
        XCTAssertEqual(ParseKey.REVENUE         , "revenue")
        XCTAssertEqual(ParseKey.SSM_TYPE        , "apihtml")
    }
    
    func testPBMAutoRefresh() {
        XCTAssertEqual(PBMAutoRefresh.AUTO_REFRESH_DELAY_DEFAULT    , 60)
        XCTAssertEqual(PBMAutoRefresh.AUTO_REFRESH_DELAY_MIN        , 15)
        XCTAssertEqual(PBMAutoRefresh.AUTO_REFRESH_DELAY_MAX        , 125)
    }
    
    func testPBMTimeInterval() {
        XCTAssertEqual(PBMTimeInterval.VAST_LOADER_TIMEOUT          , 3)
        XCTAssertEqual(PBMTimeInterval.AD_CLICKED_ALLOWED_INTERVAL  , 5)
        XCTAssertEqual(PBMTimeInterval.CONNECTION_TIMEOUT_DEFAULT   , 3)
        XCTAssertEqual(PBMTimeInterval.CLOSE_DELAY_MIN              , 2)
        XCTAssertEqual(PBMTimeInterval.CLOSE_DELAY_MAX              , 30)
        XCTAssertEqual(PBMTimeInterval.FIRE_AND_FORGET_TIMEOUT      , 3)
    }
    
    func testPBMTimeScale() {
        XCTAssertEqual(PBMTimeScale.VIDEO_TIMESCALE, 1000)
    }
    
    func testPBMGeoLocationConstants() {
        XCTAssertEqual(GeoLocationConstants.DISTANCE_FILTER, 50.0)
    }
    
    func testPBMSupportedVideoMimeTypes() {
        
        let types = PBMConstants.supportedVideoMimeTypes
        let expected = ["video/mp4",
                        "video/quicktime",
                        "video/x-m4v",
                        "video/3gpp",
                        "video/3gpp2",
        ]
        
        XCTAssertEqual(types, expected)
    }
}
