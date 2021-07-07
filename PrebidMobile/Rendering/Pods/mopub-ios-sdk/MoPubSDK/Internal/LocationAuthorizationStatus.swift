//
//  LocationAuthorizationStatus.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation


@objc(MPLocationAuthorizationStatus)
public enum LocationAuthorizationStatus: Int {
    /// The user has not chosen whether the app can use location services.
    /// This maps directly to `kCLAuthorizationStatusNotDetermined`
    case notDetermined
    
    /// The app is not authorized to use location services. The user cannot change this app’s status, possibly due to active restrictions such as parental controls being in place.
    /// This maps directly to `kCLAuthorizationStatusRestricted`
    case restricted
    
    /// The user denied the use of location services for the app.
    /// This is an aggregation of `kCLAuthorizationStatusDenied` and `CLLocationManager.locationServicesEnabled` is set to `true`
    case userDenied
    
    /// The system denied the use of location services for the app.
    /// This is an aggregation of `kCLAuthorizationStatusDenied` and `CLLocationManager.locationServicesEnabled` is set to `false`
    case settingsDenied
    
    /// The publisher has denied the use of location services for the app by setting `MoPub.locationUpdatesEnabled` to `false`.
    /// The system and user denied statuses take precedence over this value.
    case publisherDenied
    
    /// The user authorized the app to start location services at any time.
    /// This maps directly to `kCLAuthorizationStatusAuthorizedAlways`
    case authorizedAlways
    
    /// The user authorized the app to start location services while it is in use.
    /// This maps directly to `kCLAuthorizationStatusAuthorizedWhenInUse`
    case authorizedWhenInUse
    
    /// The status is unknown.
    case unknown
    
    var stringValue: String? {
        switch self {
        case .notDetermined: return "unknown"
        case .restricted: return "restricted"
        case .userDenied: return "user-denied"
        case .settingsDenied: return "system-denied"
        case .publisherDenied: return "publisher-denied"
        case .authorizedAlways: return "authorized-always"
        case .authorizedWhenInUse: return "authorized-while-in-use"
        case .unknown: return nil
        }
    }
}
