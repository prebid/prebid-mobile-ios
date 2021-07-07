import CoreLocation

class MockLocationManagerSuccessful : PBMLocationManager {
    static let testCoord = CLLocationCoordinate2D(latitude: 34.149335, longitude: -118.1328249)
    static let testCoordsAreValid = true
    static let testCity = "Pasadena"
    static let testCountry = "USA"
    static let testState = "CA"
    static let testZipCode = "91601"
    
    override class var shared: MockLocationManagerSuccessful {
        return MockLocationManagerSuccessful(thread: Thread.current)
    }
    
    override var coordinatesAreValid:Bool {
        get {
            return MockLocationManagerSuccessful.testCoordsAreValid
        }
    }
    
    override var coordinates:CLLocationCoordinate2D {
        get {
            return MockLocationManagerSuccessful.testCoord
        }
    }
}

class MockLocationManagerUnSuccessful : PBMLocationManager {
    

}
