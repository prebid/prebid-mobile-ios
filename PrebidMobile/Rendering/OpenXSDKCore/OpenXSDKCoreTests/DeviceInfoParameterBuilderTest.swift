
import AppTrackingTransparency
import UIKit
import XCTest
@testable import OpenXApolloSDK

class DeviceInfoParameterBuilderTest: XCTestCase {

    let initialDict = [String:String]()
    var deviceInfoParameterBuilder: DeviceInfoParameterBuilder!
    var bidRequest: OXMORTBBidRequest!

    override func setUp() {
        self.deviceInfoParameterBuilder = DeviceInfoParameterBuilder(deviceAccessManager: MockDeviceAccessManager(rootViewController: nil))
        self.bidRequest = OXMORTBBidRequest()
    }

    override func tearDown() {
        MockDeviceAccessManager.reset()
    }

    func testDeviceSize() {
        self.deviceInfoParameterBuilder.build(self.bidRequest)
        
        OXMAssertEq(self.bidRequest.device.w, 100)
        OXMAssertEq(self.bidRequest.device.h, 200)
    }

    func testAdTrackingEnabled() {
        MockDeviceAccessManager.mockAdvertisingTrackingEnabled = true
        if #available(iOS 14, *) {
            MockDeviceAccessManager.mockAppTrackingTransparencyStatus = .authorized
        }
        
        self.deviceInfoParameterBuilder.build(self.bidRequest)
        OXMAssertEq(self.bidRequest.device.lmt, 0)
        OXMAssertEq(self.bidRequest.device.ifa, MockDeviceAccessManager.mockAdvertisingIdentifier)
        XCTAssertNil(self.bidRequest.device.extAtts.ifv)
        
        if #available(iOS 14, *) {
            OXMAssertEq(self.bidRequest.device.extAtts.atts as? UInt, ATTrackingManager.AuthorizationStatus.authorized.rawValue)
        }
    }

    func testAdTrackingDisabled() {
        MockDeviceAccessManager.mockAdvertisingTrackingEnabled = false
        
        if #available(iOS 14, *) {
            MockDeviceAccessManager.mockAppTrackingTransparencyStatus = .notDetermined
        }
        
        self.deviceInfoParameterBuilder.build(self.bidRequest)

        OXMAssertEq(self.bidRequest.device.lmt, 1)
        OXMAssertEq(self.bidRequest.device.ifa, MockDeviceAccessManager.nullUUID)
        OXMAssertEq(self.bidRequest.device.extAtts.ifv, MockDeviceAccessManager.mockIdentifierForVendor)
        
        if #available(iOS 14, *) {
            OXMAssertEq(self.bidRequest.device.extAtts.atts as? UInt, ATTrackingManager.AuthorizationStatus.notDetermined.rawValue)
        }
    }

    func testDeviceDetails() {
        self.deviceInfoParameterBuilder.build(self.bidRequest)

        OXMAssertEq(self.bidRequest.device.make, "MockMake")
        OXMAssertEq(self.bidRequest.device.model, "MockModel")
        OXMAssertEq(self.bidRequest.device.os, "MockOS")
        OXMAssertEq(self.bidRequest.device.osv, "1.2.3")
        OXMAssertEq(self.bidRequest.device.language, "ml")
    }

    func testNilDeviceLanguage() {
        MockDeviceAccessManager.mockUserLanguageCode = nil
        self.deviceInfoParameterBuilder.build(self.bidRequest)

        XCTAssertNil(self.bidRequest.device.language)
    }
}
