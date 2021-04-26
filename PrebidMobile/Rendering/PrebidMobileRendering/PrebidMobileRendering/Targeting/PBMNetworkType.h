//
//  PBMNetworkType.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

// Values chosen to match the IAB Connection Type Spec:
// Unknown: 0
// Ethernet: 1 (skipped because it's not possible on a phone)
// Wifi: 2
// Cellular Unknown: 3
typedef NS_ENUM(NSInteger, PBMNetworkType) {
    PBMNetworkTypeUnknown = 0,
    PBMNetworkTypeWifi = 2,
    PBMNetworkTypeCell = 3,
    PBMNetworkTypeOffline,
};

typedef NSString * PBMNetworkTypeDescription NS_TYPED_EXTENSIBLE_ENUM;

FOUNDATION_EXPORT PBMNetworkTypeDescription const PBMNetworkTypeDescriptionUnknown;
FOUNDATION_EXPORT PBMNetworkTypeDescription const PBMNetworkTypeDescriptionOffline;
FOUNDATION_EXPORT PBMNetworkTypeDescription const PBMNetworkTypeDescriptionWifi;
FOUNDATION_EXPORT PBMNetworkTypeDescription const PBMNetworkTypeDescriptionCell;

FOUNDATION_EXPORT PBMNetworkType pbmNetworkTypeFromDescription(PBMNetworkTypeDescription networkTypeDescription);
FOUNDATION_EXPORT PBMNetworkTypeDescription pbmDescriptionOfNetworkType(PBMNetworkType networkType);
