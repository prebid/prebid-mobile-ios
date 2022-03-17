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

import UIKit
import XCTest
import CoreLocation

@testable import PrebidMobile

class GeoLocationParameterBuilderTest : XCTestCase {
    
    override func setUp() {
        Prebid.shared.shareGeoLocation = true
    }
    
    func testBasic() {
        let mockLocationManagerSuccessful: MockLocationManagerSuccessful = MockLocationManagerSuccessful.shared
        let builder = GeoLocationParameterBuilder(locationManager:mockLocationManagerSuccessful)
        let bidRequest = PBMORTBBidRequest()
        
        builder.build(bidRequest)
        
        PBMAssertEq(bidRequest.device.geo.type, 1)
        PBMAssertEq(bidRequest.device.geo.lat!.doubleValue, mockLocationManagerSuccessful.coordinates.latitude)
        PBMAssertEq(bidRequest.device.geo.lon!.doubleValue, mockLocationManagerSuccessful.coordinates.longitude)
    }
    
    //Show that user values do not interact with GPS values.
    func testUserAndDevice() {
        
        let mockLocationManagerSuccessful = MockLocationManagerSuccessful.shared
        let builder = GeoLocationParameterBuilder(locationManager:mockLocationManagerSuccessful)
        
        
        let bidRequest = PBMORTBBidRequest()
        bidRequest.user.geo.type = 3
        bidRequest.user.geo.lat = 123.0
        bidRequest.user.geo.lon = 456.0
        bidRequest.user.geo.city = "UserCity"
        bidRequest.user.geo.region = "UserRegion"
        bidRequest.user.geo.zip = "UserZip"
        bidRequest.user.geo.country = "UserCountry"
        
        builder.build(bidRequest)
        
        PBMAssertEq(bidRequest.device.geo.type, 1)
        PBMAssertEq(bidRequest.device.geo.lat!.doubleValue, mockLocationManagerSuccessful.coordinates.latitude)
        PBMAssertEq(bidRequest.device.geo.lon!.doubleValue, mockLocationManagerSuccessful.coordinates.longitude)
        
        PBMAssertEq(bidRequest.user.geo.type, 3)
        PBMAssertEq(bidRequest.user.geo.lat, 123.0)
        PBMAssertEq(bidRequest.user.geo.lon, 456.0)
        PBMAssertEq(bidRequest.user.geo.city, "UserCity")
        PBMAssertEq(bidRequest.user.geo.region, "UserRegion")
        PBMAssertEq(bidRequest.user.geo.zip, "UserZip")
        PBMAssertEq(bidRequest.user.geo.country, "UserCountry")
    }
}
