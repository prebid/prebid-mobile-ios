//
//  NSDateExtensionsTest.swift
//  OpenXSDKCore
//
//  Copyright (c) 2015 OpenX. All rights reserved.
//

import XCTest
@testable import PrebidMobileRendering

class DateFormatServiceTest: XCTestCase {

	func testISO8601String() {
		
		var date:Date?
		
		//Basic
        date = DateFormatService.singleton().formatISO8601(strDate: "2015-07-30T02:26:54-0700")
		XCTAssert(date?.description == "2015-07-30 09:26:54 +0000",  "Parse failed, got \(String(describing: date?.description))")
		
		//Year Changed
        date = DateFormatService.singleton().formatISO8601(strDate:  "2016-07-30T02:26:54-0700")
		XCTAssert(date?.description == "2016-07-30 09:26:54 +0000",  "Parse failed got \(String(describing: date?.description))")

		//Time Zone
        date = DateFormatService.singleton().formatISO8601(strDate:  "2016-07-30T02:26:54-0000")
		XCTAssert(date?.description == "2016-07-30 02:26:54 +0000",  "Parse failed got \(String(describing: date?.description))")

		//24 Hour Time
        date = DateFormatService.singleton().formatISO8601(strDate:  "2016-07-30T22:26:54-0000")
		XCTAssert(date?.description == "2016-07-30 22:26:54 +0000",  "Parse failed got \(String(describing: date?.description))")

		//24 Hour time plus time zone (goes into tomorrow)
        date = DateFormatService.singleton().formatISO8601(strDate:  "2016-07-30T22:26:54-0700")
		XCTAssert(date?.description == "2016-07-31 05:26:54 +0000",  "Parse failed got \(String(describing: date?.description))")
		
		//Eastern Europe
        date = DateFormatService.singleton().formatISO8601(strDate:  "2016-07-30T22:26:54+0200")
		XCTAssert(date?.description == "2016-07-30 20:26:54 +0000",  "Parse failed got \(String(describing: date?.description))")
		
        //MRAID Example Date
        date = DateFormatService.singleton().formatISO8601(strDate:  "2013-12-21T00:00-05:00")
        XCTAssert(date?.description == "2013-12-21 05:00:00 +0000",  "Parse failed got \(String(describing: date?.description))")
        
		//Negative test
		date = DateFormatService.singleton().formatISO8601(strDate:  "foobarbaz")
		XCTAssert(date == nil,  "Expected failed parse")
	}
}
