/*   Copyright 2018-2021 Prebid.org, Inc.
 
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
 
  http://www.apache.org/licenses/LICENSE-2.0
 
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

import XCTest
@testable import PrebidMobile

class DateFormatServiceTest: XCTestCase {
    
    func testISO8601String() {
        
        var date:Date?
        
        //Basic
        date = DateFormatService.shared.formatISO8601(for: "2015-07-30T02:26:54-0700")
        XCTAssert(date?.description == "2015-07-30 09:26:54 +0000",  "Parse failed, got \(String(describing: date?.description))")
        
        //Year Changed
        date = DateFormatService.shared.formatISO8601(for:  "2016-07-30T02:26:54-0700")
        XCTAssert(date?.description == "2016-07-30 09:26:54 +0000",  "Parse failed got \(String(describing: date?.description))")
        
        //Time Zone
        date = DateFormatService.shared.formatISO8601(for:  "2016-07-30T02:26:54-0000")
        XCTAssert(date?.description == "2016-07-30 02:26:54 +0000",  "Parse failed got \(String(describing: date?.description))")
        
        //24 Hour Time
        date = DateFormatService.shared.formatISO8601(for:  "2016-07-30T22:26:54-0000")
        XCTAssert(date?.description == "2016-07-30 22:26:54 +0000",  "Parse failed got \(String(describing: date?.description))")
        
        //24 Hour time plus time zone (goes into tomorrow)
        date = DateFormatService.shared.formatISO8601(for:  "2016-07-30T22:26:54-0700")
        XCTAssert(date?.description == "2016-07-31 05:26:54 +0000",  "Parse failed got \(String(describing: date?.description))")
        
        //Eastern Europe
        date = DateFormatService.shared.formatISO8601(for:  "2016-07-30T22:26:54+0200")
        XCTAssert(date?.description == "2016-07-30 20:26:54 +0000",  "Parse failed got \(String(describing: date?.description))")
        
        //MRAID Example Date
        date = DateFormatService.shared.formatISO8601(for:  "2013-12-21T00:00-05:00")
        XCTAssert(date?.description == "2013-12-21 05:00:00 +0000",  "Parse failed got \(String(describing: date?.description))")
        
        //Negative test
        date = DateFormatService.shared.formatISO8601(for:  "foobarbaz")
        XCTAssert(date == nil,  "Expected failed parse")
    }
}
