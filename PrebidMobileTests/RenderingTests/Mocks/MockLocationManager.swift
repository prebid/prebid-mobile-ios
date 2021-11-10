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

import CoreLocation

@testable import PrebidMobile

class MockLocationManagerSuccessful: PBMLocationManager {

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

class MockLocationManagerUnSuccessful : PBMLocationManager {}
