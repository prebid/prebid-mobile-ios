/*   Copyright 2018-2019 Prebid.org, Inc.

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

import Foundation
import CoreLocation

class Location: NSObject, CLLocationManagerDelegate {

    /**
     * The class is created as a singleton object & used
     */
    static let shared = Location()

    private var locationManager: CLLocationManager?

    var location: CLLocation?

    /**
     * The initializer that needs to be created only once
     */
    private override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        locationManager!.distanceFilter = kCLDistanceFilterNone
        locationManager!.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager!.startMonitoringSignificantLocationChanges()
    }

    func startCapture () {
        let status = CLLocationManager.authorizationStatus()
        if (status == CLAuthorizationStatus.authorizedWhenInUse || status == CLAuthorizationStatus.authorizedAlways ) {
            locationManager!.startUpdatingLocation()
        }

    }

    func stopCapture () {
        locationManager?.stopUpdatingLocation()

    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last!
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Log.debug("Location cannot be fetched now")
    }

}
