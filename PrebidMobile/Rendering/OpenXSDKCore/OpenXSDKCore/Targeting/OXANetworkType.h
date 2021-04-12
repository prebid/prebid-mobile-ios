//
//  OXANetworkType.h
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
typedef NS_ENUM(NSInteger, OXANetworkType) {
    OXANetworkTypeUnknown = 0,
    OXANetworkTypeWifi = 2,
    OXANetworkTypeCell = 3,
    OXANetworkTypeOffline,
};

typedef NSString * OXANetworkTypeDescription NS_TYPED_EXTENSIBLE_ENUM;

FOUNDATION_EXPORT OXANetworkTypeDescription const OXANetworkTypeDescriptionUnknown;
FOUNDATION_EXPORT OXANetworkTypeDescription const OXANetworkTypeDescriptionOffline;
FOUNDATION_EXPORT OXANetworkTypeDescription const OXANetworkTypeDescriptionWifi;
FOUNDATION_EXPORT OXANetworkTypeDescription const OXANetworkTypeDescriptionCell;

FOUNDATION_EXPORT OXANetworkType oxaNetworkTypeFromDescription(OXANetworkTypeDescription networkTypeDescription);
FOUNDATION_EXPORT OXANetworkTypeDescription oxaDescriptionOfNetworkType(OXANetworkType networkType);
