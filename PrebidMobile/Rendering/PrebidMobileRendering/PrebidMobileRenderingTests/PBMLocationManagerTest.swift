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
@testable import PrebidMobileRendering

class PBMLocationManagerTest: XCTestCase {

    let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 34.149335, longitude: -118.1328249), altitude: 10, horizontalAccuracy: 10, verticalAccuracy: 10, timestamp: Date())
    let mockPlacemark = MockCLPlacemark(country: "USA", state: "CA", city: "Pasadena", zipCode: "91601")
    let mockGeoCoder = MockGeoCoder()
    let expectationTimeout: TimeInterval = 1

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.mockGeoCoder.mockPlacemarks = [self.mockPlacemark]
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        MockCLLocationManager.reset()
        super.tearDown()
    }

    func testSingletonCreation() {
        let locationManagerSingleton = PBMLocationManager.singleton
        XCTAssertNotNil(locationManagerSingleton)
        XCTAssert(locationManagerSingleton === PBMLocationManager.singleton)
    }
    
    func testInitializationFromBackground() {
        
        //Expect 2 fulfillments because hitting the singleton will run initializeInternalLocationManager and so will 
        
        
        let expectationCheckThread = self.expectation(description: "Check thread expectation")
        expectationCheckThread.expectedFulfillmentCount = 1
        let thread = PBMThread { isCalledFromMainThread in
            expectationCheckThread.fulfill()
        }
        
        
        let _ = PBMLocationManager(thread:thread)
        

        waitForExpectations(timeout: 4)
    }

    func testRegisterWithLocationServicesDisabled() {
        let startUpdatingExpectation = self.expectation(description: "Should not have called `startUpdatingLocation` with location services disabled")
        startUpdatingExpectation.isInverted = true

        let mockCLLocationManager = MockCLLocationManager(enableLocationServices: false)
        mockCLLocationManager.startUpdatingLocationHandler = { () -> Void in
            startUpdatingExpectation.fulfill()
        }

        let locationManager = PBMLocationManager(locationManager: mockCLLocationManager)
        locationManager.locationUpdatesEnabled = true

        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }

    func testRegisterWithLocationServicesEnabled() {
        let startUpdatingExpectation = self.expectation(description: "Should have called `startUpdatingLocation` with location sevices enabled")

        let mockCLLocationManager = MockCLLocationManager(enableLocationServices: true, authorizationStatus: .authorizedAlways)
        mockCLLocationManager.startUpdatingLocationHandler = { () -> Void in
            startUpdatingExpectation.fulfill()
        }

        let locationManager = PBMLocationManager(locationManager: mockCLLocationManager)
        locationManager.locationUpdatesEnabled = true

        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }

    func testRegisterWithUnsupportedAuthorizationStatus() {
        let startUpdatingExpectation = self.expectation(description: "Should not have called `startUpdatingLocation` with unsupported authorization status")
        startUpdatingExpectation.isInverted = true

        let mockCLLocationManager = MockCLLocationManager(enableLocationServices: true)
        mockCLLocationManager.startUpdatingLocationHandler = { () -> Void in
            let status = MockCLLocationManager.authorizationStatusString()
            XCTFail("Should not have called `startUpdatingLocation` with status of '\(status)'")
            startUpdatingExpectation.fulfill()
        }

        let locationManager = PBMLocationManager(locationManager: mockCLLocationManager)

        MockCLLocationManager.mock_authorizationStatus = .notDetermined
        locationManager.locationUpdatesEnabled = true

        MockCLLocationManager.mock_authorizationStatus = .restricted
        locationManager.locationUpdatesEnabled = true

        MockCLLocationManager.mock_authorizationStatus = .denied
        locationManager.locationUpdatesEnabled = true

        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }

    func testRegisterWithSupportedAuthorizationStatus() {
        let startUpdatingExpectation = self.expectation(description: "Should have called `startUpdatingLocation` with supported authorization statuses")

        let expectedStatuses: [CLAuthorizationStatus] = [.authorizedAlways, .authorizedWhenInUse]
        var actualStatuses = [CLAuthorizationStatus]()
        
        let mockCLLocationManager = MockCLLocationManager(enableLocationServices: true)
        mockCLLocationManager.startUpdatingLocationHandler = { () -> Void in
            actualStatuses.append(MockCLLocationManager.authorizationStatus())
            if actualStatuses.count >= expectedStatuses.count {
                startUpdatingExpectation.fulfill()
            }
        }
        
        MockCLLocationManager.mock_authorizationStatus = .authorizedAlways
        let locationManagerAuthorizedAlways = PBMLocationManager(locationManager: mockCLLocationManager)
        locationManagerAuthorizedAlways.locationUpdatesEnabled = true

        MockCLLocationManager.mock_authorizationStatus = .authorizedWhenInUse
        let locationManagerAuthorizedWhenInUse = PBMLocationManager(locationManager: mockCLLocationManager)
        locationManagerAuthorizedWhenInUse.locationUpdatesEnabled = true
        
        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
        PBMAssertEq(actualStatuses, expectedStatuses)
    }

    func testRegisterStartsUpdatingLocationOnce() {
        let startUpdatingExpectation = self.expectation(description: "Should have called `startUpdatingLocation` once")
        startUpdatingExpectation.isInverted = true

        var startUpdatingCallCount = 0

        let mockCLLocationManager = MockCLLocationManager(enableLocationServices: true, authorizationStatus: .authorizedAlways)
        mockCLLocationManager.startUpdatingLocationHandler = { () -> Void in
            startUpdatingCallCount += 1
            if startUpdatingCallCount > 1 {
                startUpdatingExpectation.fulfill()
            }
        }

        let locationManager = PBMLocationManager(locationManager: mockCLLocationManager)
        locationManager.locationUpdatesEnabled = true
        locationManager.locationUpdatesEnabled = true

        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
        PBMAssertEq(startUpdatingCallCount, 1)
    }

    func testUnregisterStopsUpdatingLocation() {
        let stopUpdatingExpection = self.expectation(description: "Should have called `stopUpdatingLocation` once")
        stopUpdatingExpection.isInverted = true

        let expectedCallCount = 1
        var actualCallCount = 0

        let mockCLLocationManager = MockCLLocationManager(enableLocationServices: true, authorizationStatus: .authorizedAlways)
        mockCLLocationManager.stopUpdatingLocationHandler = { () -> Void in
            actualCallCount += 1
            if actualCallCount > expectedCallCount {
                stopUpdatingExpection.fulfill()
            }
        }

        let locationManager = PBMLocationManager(locationManager: mockCLLocationManager)
        locationManager.locationUpdatesEnabled = true
        locationManager.locationUpdatesEnabled = true

        locationManager.locationUpdatesEnabled = false
        PBMAssertEq(actualCallCount, expectedCallCount)

        locationManager.locationUpdatesEnabled = false
        locationManager.locationUpdatesEnabled = false
        PBMAssertEq(actualCallCount, expectedCallCount)

        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
    }

    func testCoordinatesAreInitiallyInvalid() {
        let mockCLLocationManager = MockCLLocationManager(enableLocationServices: true, authorizationStatus: .authorizedAlways)

        let locationManager = PBMLocationManager(locationManager: mockCLLocationManager)
        locationManager.locationUpdatesEnabled = true

        XCTAssertFalse(locationManager.coordinatesAreValid)
        PBMAssertEq(locationManager.coordinates.latitude, kCLLocationCoordinate2DInvalid.latitude)
        PBMAssertEq(locationManager.coordinates.longitude, kCLLocationCoordinate2DInvalid.longitude)
    }

    func testCoordinatesAreValid() {
        let mockCLLocationManager = MockCLLocationManager(enableLocationServices: true, authorizationStatus: .authorizedAlways)

        let locationManager = PBMLocationManager(locationManager: mockCLLocationManager)
        locationManager.locationUpdatesEnabled = true
        mockCLLocationManager.delegate?.locationManager?(CLLocationManager(), didUpdateLocations: [self.location])

        XCTAssert(locationManager.coordinatesAreValid)
        PBMAssertEq(locationManager.coordinates.latitude, self.location.coordinate.latitude)
        PBMAssertEq(locationManager.coordinates.longitude, self.location.coordinate.longitude)
        PBMAssertEq(locationManager.horizontalAccuracy, self.location.horizontalAccuracy)
        PBMAssertEq(locationManager.timestamp, self.location.timestamp)
    }

    func testInternalLocationManagerFailure() {
        let stopUpdatingExpection = self.expectation(description: "Should have called `stopUpdatingLocation` internal location manager failed")

        let mockCLLocationManager = MockCLLocationManager(enableLocationServices: true, authorizationStatus: .authorizedAlways)
        mockCLLocationManager.stopUpdatingLocationHandler = { () -> Void in
            stopUpdatingExpection.fulfill()
        }

        let locationManager = PBMLocationManager(locationManager: mockCLLocationManager)
        locationManager.locationUpdatesEnabled = true

        enum ErrorError: Error { case Error }
        mockCLLocationManager.delegate?.locationManager?(CLLocationManager(), didFailWithError: ErrorError.Error)

        self.waitForExpectations(timeout: expectationTimeout, handler: nil)
        XCTAssertFalse(locationManager.coordinatesAreValid)
        PBMAssertEq(locationManager.coordinates.latitude, kCLLocationCoordinate2DInvalid.latitude)
        PBMAssertEq(locationManager.coordinates.longitude, kCLLocationCoordinate2DInvalid.longitude)
    }

    func testInternalLocationManagerFailureRetainsPreviousLocationData() {
        let mockCLLocationManager = MockCLLocationManager(enableLocationServices: true, authorizationStatus: .authorizedAlways)
        let locationManager = PBMLocationManager(locationManager: mockCLLocationManager)
        locationManager.locationUpdatesEnabled = true

        mockCLLocationManager.delegate?.locationManager?(CLLocationManager(), didUpdateLocations: [self.location])

        XCTAssert(locationManager.coordinatesAreValid)
        PBMAssertEq(locationManager.coordinates.latitude, self.location.coordinate.latitude)
        PBMAssertEq(locationManager.coordinates.longitude, self.location.coordinate.longitude)

        enum ErrorError: Error { case Error }
        mockCLLocationManager.delegate?.locationManager?(CLLocationManager(), didFailWithError: ErrorError.Error)

        XCTAssert(locationManager.coordinatesAreValid)
        PBMAssertEq(locationManager.coordinates.latitude, self.location.coordinate.latitude)
        PBMAssertEq(locationManager.coordinates.longitude, self.location.coordinate.longitude)
    }
    
    func testValidLocation() {
        let invalidLocation = CLLocation(latitude: 0, longitude: 0)
        let locationManagerSingleton = PBMLocationManager.singleton
        XCTAssertTrue(locationManagerSingleton.locationIsValid(location))
        XCTAssertFalse(locationManagerSingleton.locationIsValid(invalidLocation))
        XCTAssertFalse(locationManagerSingleton.locationIsValid(nil))
        XCTAssertFalse(locationManagerSingleton.locationIsValid(NSObject() as? CLLocation))
    }
}


// MARK: - Mocks

class MockReachability: PBMReachability {
    
    override func currentReachabilityStatus() -> PBMNetworkType {
        return .wifi
    }    
}

class MockCLPlacemark: CLPlacemark {

    var mock_isoCountryCode: String?
    var mock_administrativeArea: String?
    var mock_locality: String?
    var mock_postalCode: String?

    convenience init(country: String, state: String, city: String, zipCode: String) {
        self.init()
        self.mock_isoCountryCode = country
        self.mock_administrativeArea = state
        self.mock_locality = city
        self.mock_postalCode = zipCode
    }

    override var isoCountryCode: String? { return self.mock_isoCountryCode }
    override var administrativeArea: String? { return self.mock_administrativeArea }
    override var locality: String? { return self.mock_locality }
    override var postalCode: String? { return self.mock_postalCode }

}

class MockGeoCoder: CLGeocoder {

    var mockPlacemarks: [CLPlacemark]?

    override func reverseGeocodeLocation(_ location: CLLocation, completionHandler: @escaping CLGeocodeCompletionHandler) {
        completionHandler(self.mockPlacemarks, nil)
    }

}


class MockCLLocationManager: NSObject, PBMLocationManagerProtocol {    
    
    weak var delegate: CLLocationManagerDelegate?
    var distanceFilter: CLLocationDistance = 0
    var desiredAccuracy: CLLocationAccuracy = 0
    var location: CLLocation?
    
    static var mock_locationServicesEnabled = false
    static var mock_authorizationStatus = CLAuthorizationStatus.denied

    var startUpdatingLocationHandler: (() -> Void)?
    var stopUpdatingLocationHandler: (() -> Void)?

    override init() { }

    convenience init(enableLocationServices: Bool = false, authorizationStatus: CLAuthorizationStatus = .denied) {
        self.init()
        MockCLLocationManager.mock_locationServicesEnabled = enableLocationServices
        MockCLLocationManager.mock_authorizationStatus = authorizationStatus
    }

    class func reset() {
        MockCLLocationManager.mock_locationServicesEnabled = false
        MockCLLocationManager.mock_authorizationStatus = .denied
    }

    @objc class func locationServicesEnabled() -> Bool {
        return self.mock_locationServicesEnabled
    }

    @objc class func authorizationStatus() -> CLAuthorizationStatus {
        return self.mock_authorizationStatus
    }

    class func authorizationStatusString() -> String {
        switch self.mock_authorizationStatus {
        case .notDetermined:
            return "NotDetermined"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .authorizedAlways:
            return "AuthorizedAlways"
        case .authorizedWhenInUse:
            return "AuthorizedWhenInUse"
        @unknown default:
            return "Unknown"
        }
    }

    func startUpdatingLocation() {
        self.startUpdatingLocationHandler?()
    }

    func stopUpdatingLocation() {
        self.stopUpdatingLocationHandler?()
    }
}
