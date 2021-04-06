//
//  OXANetworkType.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANetworkType.h"

OXANetworkTypeDescription const OXANetworkTypeDescriptionUnknown = @"Unknown";
OXANetworkTypeDescription const OXANetworkTypeDescriptionOffline = @"offline";
OXANetworkTypeDescription const OXANetworkTypeDescriptionWifi = @"wifi";
OXANetworkTypeDescription const OXANetworkTypeDescriptionCell = @"cell";

OXANetworkType oxaNetworkTypeFromDescription(OXANetworkTypeDescription networkTypeDescription) {
    if ([networkTypeDescription isEqualToString:OXANetworkTypeDescriptionOffline]) {
        return OXANetworkTypeOffline;
    } else if ([networkTypeDescription isEqualToString:OXANetworkTypeDescriptionWifi]) {
        return OXANetworkTypeWifi;
    } else if ([networkTypeDescription isEqualToString:OXANetworkTypeDescriptionCell]) {
        return OXANetworkTypeCell;
    }
    
    return OXANetworkTypeUnknown;
}

OXANetworkTypeDescription oxaDescriptionOfNetworkType(OXANetworkType networkType) {
    switch (networkType) {
        case OXANetworkTypeOffline  : return OXANetworkTypeDescriptionOffline;
        case OXANetworkTypeWifi     : return OXANetworkTypeDescriptionWifi;
        case OXANetworkTypeCell     : return OXANetworkTypeDescriptionCell;
            
        default                     : return OXANetworkTypeDescriptionUnknown;
    }
}
