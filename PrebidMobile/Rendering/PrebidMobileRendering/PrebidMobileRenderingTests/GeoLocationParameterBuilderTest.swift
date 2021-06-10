import UIKit
import XCTest
import CoreLocation

@testable import PrebidMobileRendering

class GeoLocationParameterBuilderTest : XCTestCase {

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
