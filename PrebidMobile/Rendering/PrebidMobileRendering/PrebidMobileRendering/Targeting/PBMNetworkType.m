//
//  PBMNetworkType.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNetworkType.h"

PBMNetworkTypeDescription const PBMNetworkTypeDescriptionUnknown = @"Unknown";
PBMNetworkTypeDescription const PBMNetworkTypeDescriptionOffline = @"offline";
PBMNetworkTypeDescription const PBMNetworkTypeDescriptionWifi = @"wifi";
PBMNetworkTypeDescription const PBMNetworkTypeDescriptionCell = @"cell";

PBMNetworkType pbmNetworkTypeFromDescription(PBMNetworkTypeDescription networkTypeDescription) {
    if ([networkTypeDescription isEqualToString:PBMNetworkTypeDescriptionOffline]) {
        return PBMNetworkTypeOffline;
    } else if ([networkTypeDescription isEqualToString:PBMNetworkTypeDescriptionWifi]) {
        return PBMNetworkTypeWifi;
    } else if ([networkTypeDescription isEqualToString:PBMNetworkTypeDescriptionCell]) {
        return PBMNetworkTypeCell;
    }
    
    return PBMNetworkTypeUnknown;
}

PBMNetworkTypeDescription pbmDescriptionOfNetworkType(PBMNetworkType networkType) {
    switch (networkType) {
        case PBMNetworkTypeOffline  : return PBMNetworkTypeDescriptionOffline;
        case PBMNetworkTypeWifi     : return PBMNetworkTypeDescriptionWifi;
        case PBMNetworkTypeCell     : return PBMNetworkTypeDescriptionCell;
            
        default                     : return PBMNetworkTypeDescriptionUnknown;
    }
}
