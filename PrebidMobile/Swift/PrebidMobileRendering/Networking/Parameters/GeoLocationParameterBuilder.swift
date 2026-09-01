/*   Copyright 2018-2021 Prebid.org, Inc.

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
import Foundation

class GeoLocationParameterBuilder: NSObject, ParameterBuilder {

    private let locationManager: LocationManager

    init(locationManager: LocationManager) {
        self.locationManager = locationManager
        super.init()
    }

    func build(_ bidRequest: ORTBBidRequest) {
        guard Prebid.shared.shareGeoLocation else {
            return
        }

        guard locationManager.coordinatesAreValid else {
            return
        }

        bidRequest.device.geo.type = NSNumber(value: PrebidConstants.LOCATION_SOURCE_GPS)
        bidRequest.device.geo.setRoundedCoordinates(
            locationManager.coordinates,
            precision: Targeting.shared.locationPrecision
        )
    }
}

extension ORTBGeo {

    /// Writes `coordinates` into `lat`/`lon`, rounded to `precision`.
    ///
    /// Shared by `GeoLocationParameterBuilder` (`device.geo`) and
    /// `ParameterBuilderService.createORTBBidRequest(with:)` (`user.geo`) so that a change to the
    /// rounding rule lands in one place rather than two.
    ///
    /// - Parameter precision: the number of decimal places to keep; `nil` leaves the coordinates
    ///                        unrounded.
    func setRoundedCoordinates(_ coordinates: CLLocationCoordinate2D, precision: NSNumber?) {
        let rounded = Utils.shared.round(coordinates: coordinates, precision: precision)
        lat = NSNumber(value: rounded.latitude)
        lon = NSNumber(value: rounded.longitude)
    }
}
