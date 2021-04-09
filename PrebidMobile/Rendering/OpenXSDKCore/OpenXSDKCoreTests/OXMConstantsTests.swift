//
//  OXMConstantsTests.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest
@testable import OpenXApolloSDK

class OXMConstantsTests: XCTestCase {
    
    func testLocationParamKeys() {
        XCTAssertEqual(LocationParamKeys.Latitude       , "lat")
        XCTAssertEqual(LocationParamKeys.Longitude      , "lon")
        XCTAssertEqual(LocationParamKeys.Country        , "cnt")
        XCTAssertEqual(LocationParamKeys.City           , "cty")
        XCTAssertEqual(LocationParamKeys.State          , "stt")
        XCTAssertEqual(LocationParamKeys.Zip            , "zip")
        XCTAssertEqual(LocationParamKeys.LocationSource , "lt")
    }
    
    func testOXMParseKey() {
        XCTAssertEqual(ParseKey.ADUNIT          , "adUnit")
        XCTAssertEqual(ParseKey.HEIGHT          , "height")
        XCTAssertEqual(ParseKey.WIDTH           , "width")
        XCTAssertEqual(ParseKey.HTML            , "html")
        XCTAssertEqual(ParseKey.IMAGE           , "image")
        XCTAssertEqual(ParseKey.NETWORK_UID     , "network_uid")
        XCTAssertEqual(ParseKey.REVENUE         , "revenue")
        XCTAssertEqual(ParseKey.SSM_TYPE        , "apihtml")
    }
    
    func testOXMAutoRefresh() {
        XCTAssertEqual(OXMAutoRefresh.AUTO_REFRESH_DELAY_DEFAULT    , 60)
        XCTAssertEqual(OXMAutoRefresh.AUTO_REFRESH_DELAY_MIN        , 15)
        XCTAssertEqual(OXMAutoRefresh.AUTO_REFRESH_DELAY_MAX        , 125)
    }
    
    func testOXMTimeInterval() {
        XCTAssertEqual(OXMTimeInterval.VAST_LOADER_TIMEOUT          , 3)
        XCTAssertEqual(OXMTimeInterval.AD_CLICKED_ALLOWED_INTERVAL  , 5)
        XCTAssertEqual(OXMTimeInterval.CONNECTION_TIMEOUT_DEFAULT   , 3)
        XCTAssertEqual(OXMTimeInterval.CLOSE_DELAY_MIN              , 2)
        XCTAssertEqual(OXMTimeInterval.CLOSE_DELAY_MAX              , 30)
        XCTAssertEqual(OXMTimeInterval.FIRE_AND_FORGET_TIMEOUT      , 3)
    }
    
    func testOXMTimeScale() {
        XCTAssertEqual(OXMTimeScale.VIDEO_TIMESCALE, 1000)
    }
    
    func testOXMGeoLocationConstants() {
        XCTAssertEqual(GeoLocationConstants.DISTANCE_FILTER, 50.0)
    }
    
    func testOXMSupportedVideoMimeTypes() {
        
        let types = OXMConstants.supportedVideoMimeTypes
        let expected = ["video/mp4",
                        "video/quicktime",
                        "video/x-m4v",
                        "video/3gpp",
                        "video/3gpp2",
        ]
        
        XCTAssertEqual(types, expected)
    }
}
