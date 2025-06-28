//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
import UIKit
import CoreLocation

extension CLLocationManager: LocationManagerProtocol {}

@objc(PBMLocationManager) @objcMembers
public class LocationManager: NSObject {
    
    public static let shared = LocationManager()
    
    public var locationUpdatesEnabled = true {
        didSet {
            if locationUpdatesEnabled {
                startLocationUpdates()
            } else {
                stopLocationUpdates()
                location = nil
            }
        }
    }
    
    public var coordinates: CLLocationCoordinate2D {
        guard let location else { return kCLLocationCoordinate2DInvalid }
        return coordinatesAreValid ? location.coordinate : kCLLocationCoordinate2DInvalid
    }
    
    public var coordinatesAreValid: Bool {
        return location?.isValid ?? false
    }
    
    public var horizontalAccuracy: CLLocationAccuracy {
        guard let location else { return -1 }
        return coordinatesAreValid ? location.horizontalAccuracy : -1
    }
    
    public var timestamp: Date? {
        coordinatesAreValid ? location?.timestamp : nil;
    }
    
    private var internalLocationManager: LocationManagerProtocol?
    
    private var _authorizationStatus: CLAuthorizationStatus = .notDetermined
    var latestAuthorizationStatus: CLAuthorizationStatus {
        get {
            queue.sync {
                _authorizationStatus
            }
        }
        set {
            queue.async(flags: .barrier) {
                self._authorizationStatus = newValue
            }
        }
    }
    
    private var _location: CLLocation?
    var location: CLLocation? {
        get {
            queue.sync {
                _location
            }
        }
        set {
            queue.async(flags: .barrier) {
                self._location = newValue
            }
        }
    }
    
    private var _isLocationUpdating = false
    private var isLocationUpdating: Bool {
        get {
            queue.sync {
                _isLocationUpdating
            }
        }
        set {
            queue.async(flags: .barrier) {
                self._isLocationUpdating = newValue
            }
        }
    }
    
    private let queue = DispatchQueue(label: "PBMLocationManager", attributes: .concurrent)
    
    override init() {
        super.init()
        
        DispatchQueue.main.async {
            self.setup(with: CLLocationManager())
        }
    }
    
    // NOTE: Used for tests only
    // `locationManager` should be initialized from main thread only.
    init(locationManager: LocationManagerProtocol) {
        super.init()
        setup(with: locationManager)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didEnterBackgroundNotification,
            object: UIApplication.shared
        )
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.willEnterForegroundNotification,
            object: UIApplication.shared
        )
    }
    
    @objc func startLocationUpdates() {
        guard !isLocationUpdating else {
            return
        }
        
        guard locationUpdatesEnabled else {
            return
        }
        
        guard latestAuthorizationStatus.isAuthorized else {
            return
        }
        
        isLocationUpdating = true
        
        DispatchQueue.main.async {
            self.internalLocationManager?.startUpdatingLocation()
        }
    }
    
    @objc func stopLocationUpdates() {
        guard isLocationUpdating else {
            return
        }
        
        isLocationUpdating = false
        
        DispatchQueue.main.async {
            self.internalLocationManager?.stopUpdatingLocation()
        }
    }
    
    private func setup(with locationManager: LocationManagerProtocol) {
        internalLocationManager = locationManager
        internalLocationManager?.distanceFilter = PrebidConstants.DISTANCE_FILTER
        internalLocationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        internalLocationManager?.delegate = self
        
        startLocationUpdates()
        
        // CLLocationManager's `location` property may already contain location data upon
        // initialization (for example, if the application uses significant location updates).
        if let existingLocation = internalLocationManager?.location, existingLocation.isValid {
            location = existingLocation
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: UIApplication.shared,
            queue: .main
        ) { [weak self] _ in
            self?.stopLocationUpdates()
        }
        
        // Re-activate location updates when the application comes back to the foreground.
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: UIApplication.shared,
            queue: .main
        ) { [weak self] _ in
            self?.startLocationUpdates()
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last
        if newLocation?.isValid == true {
            self.location = newLocation
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        stopLocationUpdates()
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        latestAuthorizationStatus = status
        
        if latestAuthorizationStatus.isAuthorized {
            startLocationUpdates()
        }
    }
}
