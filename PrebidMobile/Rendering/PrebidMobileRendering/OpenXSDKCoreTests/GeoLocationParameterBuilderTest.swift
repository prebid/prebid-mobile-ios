import UIKit
import XCTest
import CoreLocation

@testable import PrebidMobileRendering

class GeoLocationParameterBuilderTest : XCTestCase {

    func testBasic() {
        let mockLocationManagerSuccessful: MockLocationManagerSuccessful = MockLocationManagerSuccessful.singleton
        let builder = GeoLocationParameterBuilder(locationManager:mockLocationManagerSuccessful)
        let bidRequest = OXMORTBBidRequest()
        
        builder.build(bidRequest)
        
        OXMAssertEq(bidRequest.device.geo.type, 1)
        OXMAssertEq(bidRequest.device.geo.lat!.doubleValue, mockLocationManagerSuccessful.coordinates.latitude)
        OXMAssertEq(bidRequest.device.geo.lon!.doubleValue, mockLocationManagerSuccessful.coordinates.longitude)
    }
    
    //Show that user values do not interact with GPS values.
    func testUserAndDevice() {
        
        let mockLocationManagerSuccessful = MockLocationManagerSuccessful.singleton
        let builder = GeoLocationParameterBuilder(locationManager:mockLocationManagerSuccessful)
        
    
        let bidRequest = OXMORTBBidRequest()
        bidRequest.user.geo.type = 3
        bidRequest.user.geo.lat = 123.0
        bidRequest.user.geo.lon = 456.0
        bidRequest.user.geo.city = "UserCity"
        bidRequest.user.geo.region = "UserRegion"
        bidRequest.user.geo.zip = "UserZip"
        bidRequest.user.geo.country = "UserCountry"
        
        builder.build(bidRequest)
        
        OXMAssertEq(bidRequest.device.geo.type, 1)
        OXMAssertEq(bidRequest.device.geo.lat!.doubleValue, mockLocationManagerSuccessful.coordinates.latitude)
        OXMAssertEq(bidRequest.device.geo.lon!.doubleValue, mockLocationManagerSuccessful.coordinates.longitude)
        
        OXMAssertEq(bidRequest.user.geo.type, 3)
        OXMAssertEq(bidRequest.user.geo.lat, 123.0)
        OXMAssertEq(bidRequest.user.geo.lon, 456.0)
        OXMAssertEq(bidRequest.user.geo.city, "UserCity")
        OXMAssertEq(bidRequest.user.geo.region, "UserRegion")
        OXMAssertEq(bidRequest.user.geo.zip, "UserZip")
        OXMAssertEq(bidRequest.user.geo.country, "UserCountry")
    }
}
