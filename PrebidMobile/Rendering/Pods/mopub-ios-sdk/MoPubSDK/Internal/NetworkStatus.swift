//
//  NetworkStatus.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation

// Values chosen to match the IAB Connection Type Spec, where:
// Unknown: 0
// Ethernet: 1 (skipped because it's not possible on a phone)
// Wifi: 2
// Cellular Unknown: 3
// Cellular 2G: 4
// Cellular 3G: 5
// Cellular 4G: 6
// Cellular 5G: 7

@objc(MPNetworkStatus)
public enum NetworkStatus: Int, CustomStringConvertible {
    case notReachable = 0
    case reachableViaWiFi = 2
    case reachableViaCellularNetworkUnknownGeneration
    case reachableViaCellularNetwork2G
    case reachableViaCellularNetwork3G
    case reachableViaCellularNetwork4G
    case reachableViaCellularNetwork5G

    // MARK: - CustomStringConvertible
    public var description: String {
        switch self {
        case .notReachable: return "notReachable"
        case .reachableViaWiFi: return "reachableViaWiFi"
        case .reachableViaCellularNetworkUnknownGeneration: return "reachableViaCellularNetworkUnknownGeneration"
        case .reachableViaCellularNetwork2G: return "reachableViaCellularNetwork2G"
        case .reachableViaCellularNetwork3G: return "reachableViaCellularNetwork3G"
        case .reachableViaCellularNetwork4G: return "reachableViaCellularNetwork4G"
        case .reachableViaCellularNetwork5G: return "reachableViaCellularNetwork5G"
        }
    }
}
