//
//  CellularService.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation
import CoreTelephony


/// Class that represents information about cellular service.
@objc(MPCellularService)
public class CellularService: NSObject {
    /// All of the cellular services on this device, or an empty array if there are no cellular services.
    static let services: [CellularService] = {
        if #available(iOS 12.0, *) {
            guard let carriers = telephonyNetworkInformation.serviceSubscriberCellularProviders else {
                return []
            }
            
            var result: [CellularService] = []
            
            for carrierDict in carriers {
                let service = CellularService(carrier: carrierDict.value, key: carrierDict.key)
                result.append(service)
            }
            
            return result
        } else {
            guard let carrier = telephonyNetworkInformation.subscriberCellularProvider else {
                return []
            }
            
            return [CellularService(carrier: carrier, key: nil)]
        }
    }()
    
    /// The carrier of this cellular service.
    @objc public let carrier: CTCarrier
    
    /// The key for this cellular service in the system.
    private let key: String?
    
    init(carrier: CTCarrier, key: String?) {
        self.carrier = carrier
        self.key = key
    }
    
    /// The current radio technology used by this service to connect to the internet.
    @objc public var currentRadioAccessTechnology: NetworkStatus {
        // The determination of 2G/3G/4G technology is a best-effort.
        switch radioAccessTechnologyString {
        case CTRadioAccessTechnologyLTE: // Source: https://en.wikipedia.org/wiki/LTE_(telecommunication)
            return .reachableViaCellularNetwork4G
        case CTRadioAccessTechnologyCDMAEVDORev0, // Source: https://www.phonescoop.com/glossary/term.php?gid=151
             CTRadioAccessTechnologyCDMAEVDORevA, // Source: https://www.phonescoop.com/glossary/term.php?gid=151
             CTRadioAccessTechnologyCDMAEVDORevB, // Source: https://www.phonescoop.com/glossary/term.php?gid=151
             CTRadioAccessTechnologyWCDMA, // Source: https://www.techopedia.com/definition/24282/wideband-code-division-multiple-access-wcdma
             CTRadioAccessTechnologyHSDPA, // Source: https://en.wikipedia.org/wiki/High_Speed_Packet_Access#High_Speed_Downlink_Packet_Access_(HSDPA)
             CTRadioAccessTechnologyHSUPA: // Source: https://en.wikipedia.org/wiki/High_Speed_Packet_Access#High_Speed_Uplink_Packet_Access_(HSUPA)
            return .reachableViaCellularNetwork3G
        case CTRadioAccessTechnologyCDMA1x, // Source: In testing, this mode showed up when the phone was in Verizon 1x mode
             CTRadioAccessTechnologyGPRS, // Source: https://en.wikipedia.org/wiki/General_Packet_Radio_Service
             CTRadioAccessTechnologyEdge, // Source: https://en.wikipedia.org/wiki/2G#2.75G_(EDGE)
             CTRadioAccessTechnologyeHRPD: // Source: https://www.phonescoop.com/glossary/term.php?gid=155
            return .reachableViaCellularNetwork2G
        default:
            if #available(iOS 14.1, *) {
                switch radioAccessTechnologyString {
                    case CTRadioAccessTechnologyNR,
                         CTRadioAccessTechnologyNRNSA:
                        return .reachableViaCellularNetwork5G
                default:
                    return .reachableViaCellularNetworkUnknownGeneration
                }
            }
            return .reachableViaCellularNetworkUnknownGeneration
        }
    }
}

// MARK: - Private
private extension CellularService {
    static let telephonyNetworkInformation = CTTelephonyNetworkInfo()
    
    /// A string representing the current cellular radio access technology.
    private var radioAccessTechnologyString: String? {
        if #available(iOS 12.0, *) {
            guard let key = key else {
                return nil
            }
            
            return Self.telephonyNetworkInformation.serviceCurrentRadioAccessTechnology?[key]
        } else {
            return Self.telephonyNetworkInformation.currentRadioAccessTechnology
        }
    }
}
