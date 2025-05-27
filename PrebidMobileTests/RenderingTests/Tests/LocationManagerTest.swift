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

class LocationManagerTest: XCTestCase {

    let location = CLLocation(
        coordinate: CLLocationCoordinate2D(
            latitude: 34.149335,
            longitude: -118.1328249
        ),
        altitude: 10,
        horizontalAccuracy: 10,
        verticalAccuracy: 10,
        timestamp: Date()
    )
    
    let expectationTimeout: TimeInterval = 1

    override func tearDown() {
        MockCLLocationManagerRendering.reset()
        super.tearDown()
    }

    func testSharedCreation() {
        let locationManagerShared = LocationManager.shared
        XCTAssertNotNil(locationManagerShared)
        XCTAssert(locationManagerShared === LocationManager.shared)
    }

    func testRegisterWithLocationServicesDisabled() {
        let startUpdatingExpectation = self.expectation(description: "Should not have called `startUpdatingLocation` with location services disabled")
        startUpdatingExpectation.isInverted = true

        let mockCLLocationManager = MockCLLocationManagerRendering(enableLocationServices: false)
        mockCLLocationManager.startUpdatingLocationHandler = { () -> Void in
            startUpdatingExpectation.fulfill()
        }

        let locationManager = LocationManager(locationManager: mockCLLocationManager)
        locationManager.locationUpdatesEnabled = true

        self.waitForExpectations(timeout: self.expectationTimeout, handler: nil)
    }

    func testRegisterWithLocationServicesEnabled() {
        let startUpdatingExpectation = self.expectation(description: "Should have called `startUpdatingLocation` with location sevices enabled")

        let mockCLLocationManager = MockCLLocationManagerRendering(enableLocationServices: true, authorizationStatus: .authorizedAlways)
        mockCLLocationManager.startUpdatingLocationHandler = { () -> Void in
            startUpdatingExpectation.fulfill()
        }

        let locationManager = LocationManager(locationManager: mockCLLocationManager)
        locationManager.latestAuthorizationStatus = .authorizedAlways
        locationManager.locationUpdatesEnabled = true

        self.waitForExpectations(timeout: self.expectationTimeout, handler: nil)
    }

    func testRegisterWithUnsupportedAuthorizationStatus() {
        let startUpdatingExpectation = self.expectation(description: "Should not have called `startUpdatingLocation` with unsupported authorization status")
        startUpdatingExpectation.isInverted = true

        let mockCLLocationManager = MockCLLocationManagerRendering(enableLocationServices: true)
        mockCLLocationManager.startUpdatingLocationHandler = { () -> Void in
            let status = MockCLLocationManagerRendering.authorizationStatusString()
            XCTFail("Should not have called `startUpdatingLocation` with status of '\(status)'")
            startUpdatingExpectation.fulfill()
        }

        let locationManager = LocationManager(locationManager: mockCLLocationManager)

        MockCLLocationManagerRendering.mock_authorizationStatus = .notDetermined
        locationManager.latestAuthorizationStatus = .notDetermined
        locationManager.locationUpdatesEnabled = true

        MockCLLocationManagerRendering.mock_authorizationStatus = .restricted
        locationManager.latestAuthorizationStatus = .restricted
        locationManager.locationUpdatesEnabled = true

        MockCLLocationManagerRendering.mock_authorizationStatus = .denied
        locationManager.latestAuthorizationStatus = .denied
        locationManager.locationUpdatesEnabled = true

        self.waitForExpectations(timeout: self.expectationTimeout, handler: nil)
    }

    func testRegisterWithSupportedAuthorizationStatus() {
        let startUpdatingExpectation = self.expectation(description: "Should have called `startUpdatingLocation` with supported authorization statuses")
        startUpdatingExpectation.expectedFulfillmentCount = 2
        
        let mockCLLocationManager = MockCLLocationManagerRendering(enableLocationServices: true)
        let locationManager = LocationManager(locationManager: mockCLLocationManager)
       
        locationManager.latestAuthorizationStatus = .authorizedAlways
        mockCLLocationManager.startUpdatingLocationHandler = { () -> Void in
            XCTAssert(locationManager.latestAuthorizationStatus == .authorizedAlways)
            startUpdatingExpectation.fulfill()
        }
        locationManager.locationUpdatesEnabled = true
        
        locationManager.locationUpdatesEnabled = false
        
        locationManager.latestAuthorizationStatus = .authorizedWhenInUse
        mockCLLocationManager.startUpdatingLocationHandler = { () -> Void in
            XCTAssert(locationManager.latestAuthorizationStatus == .authorizedWhenInUse)
            startUpdatingExpectation.fulfill()
        }
        locationManager.locationUpdatesEnabled = true
       
        self.waitForExpectations(timeout: self.expectationTimeout, handler: nil)
    }

    func testRegisterStartsUpdatingLocationOnce() {
        let startUpdatingExpectation = self.expectation(description: "Should have called `startUpdatingLocation` once")
        startUpdatingExpectation.isInverted = true

        var startUpdatingCallCount = 0

        let mockCLLocationManager = MockCLLocationManagerRendering(enableLocationServices: true, authorizationStatus: .authorizedAlways)
        mockCLLocationManager.startUpdatingLocationHandler = { () -> Void in
            startUpdatingCallCount += 1
            if startUpdatingCallCount > 1 {
                startUpdatingExpectation.fulfill()
            }
        }

        let locationManager = LocationManager(locationManager: mockCLLocationManager)
        locationManager.latestAuthorizationStatus = .authorizedAlways
        locationManager.locationUpdatesEnabled = true
        locationManager.locationUpdatesEnabled = true

        self.waitForExpectations(timeout: self.expectationTimeout, handler: nil)
        PBMAssertEq(startUpdatingCallCount, 1)
    }

    func testUnregisterStopsUpdatingLocation() {
        let stopUpdatingExpection = self.expectation(description: "Should have called `stopUpdatingLocation` once")
        stopUpdatingExpection.expectedFulfillmentCount = 1

        let mockCLLocationManager = MockCLLocationManagerRendering(enableLocationServices: true, authorizationStatus: .authorizedAlways)
        mockCLLocationManager.stopUpdatingLocationHandler = { () -> Void in
            stopUpdatingExpection.fulfill()
        }

        let locationManager = LocationManager(locationManager: mockCLLocationManager)
        locationManager.latestAuthorizationStatus = .authorizedAlways
        locationManager.locationUpdatesEnabled = true
        locationManager.locationUpdatesEnabled = true

        locationManager.locationUpdatesEnabled = false

        locationManager.locationUpdatesEnabled = false
        locationManager.locationUpdatesEnabled = false

        self.waitForExpectations(timeout: self.expectationTimeout, handler: nil)
    }

    func testCoordinatesAreInitiallyInvalid() {
        let locationManager = LocationManager()
        locationManager.locationUpdatesEnabled = true

        XCTAssertFalse(locationManager.coordinatesAreValid)
        PBMAssertEq(locationManager.coordinates.latitude, kCLLocationCoordinate2DInvalid.latitude)
        PBMAssertEq(locationManager.coordinates.longitude, kCLLocationCoordinate2DInvalid.longitude)
    }

    func testCoordinatesAreValid() {
        let mockCLLocationManager = MockCLLocationManagerRendering(
            enableLocationServices: true,
            authorizationStatus: .authorizedAlways
        )

        let locationManager = LocationManager(locationManager: mockCLLocationManager)
        locationManager.latestAuthorizationStatus = .authorizedAlways
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

        let mockCLLocationManager = MockCLLocationManagerRendering(enableLocationServices: true, authorizationStatus: .authorizedAlways)
        mockCLLocationManager.stopUpdatingLocationHandler = { () -> Void in
            stopUpdatingExpection.fulfill()
        }

        let locationManager = LocationManager(locationManager: mockCLLocationManager)
        locationManager.latestAuthorizationStatus = .authorizedAlways
        locationManager.locationUpdatesEnabled = true

        enum ErrorError: Error { case Error }
        mockCLLocationManager.delegate?.locationManager?(CLLocationManager(), didFailWithError: ErrorError.Error)

        self.waitForExpectations(timeout: self.expectationTimeout, handler: nil)
        XCTAssertFalse(locationManager.coordinatesAreValid)
        PBMAssertEq(locationManager.coordinates.latitude, kCLLocationCoordinate2DInvalid.latitude)
        PBMAssertEq(locationManager.coordinates.longitude, kCLLocationCoordinate2DInvalid.longitude)
    }

    func testInternalLocationManagerFailureRetainsPreviousLocationData() {
        let mockCLLocationManager = MockCLLocationManagerRendering(enableLocationServices: true, authorizationStatus: .authorizedAlways)
        let locationManager = LocationManager(locationManager: mockCLLocationManager)
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
        XCTAssertTrue(location.isValid)
        
        let invalidLocation = CLLocation(latitude: 0, longitude: 0)
        XCTAssertFalse(invalidLocation.isValid)
    }
    
    func testConcurrentLocationPropertyAccessDoesNotCrash() {
        let locationManager = LocationManager()
        locationManager.latestAuthorizationStatus = .authorizedAlways
        locationManager.locationUpdatesEnabled = true
        
        let exp = expectation(description: "Concurrent location property access completes without crashes")
        
        let group = DispatchGroup()
        
        for _ in 0...1000 {
            group.enter()
            locationManager.location = self.location
            DispatchQueue.global(qos: .background).async {
                _ = locationManager.coordinates
                _ = locationManager.coordinatesAreValid
                _ = locationManager.horizontalAccuracy
                _ = locationManager.timestamp
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3.0)
    }
}


// MARK: - Mocks

class MockReachability: Reachability {
    
    override var currentReachabilityStatus: NetworkType {
        return .wifi
    }
}

class MockCLLocationManagerRendering: NSObject, LocationManagerProtocol {
    
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
        MockCLLocationManagerRendering.mock_locationServicesEnabled = enableLocationServices
        MockCLLocationManagerRendering.mock_authorizationStatus = authorizationStatus
    }

    class func reset() {
        MockCLLocationManagerRendering.mock_locationServicesEnabled = false
        MockCLLocationManagerRendering.mock_authorizationStatus = .denied
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
