//
//  OXAORTBBidExtSkadn.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBAbstract.h"

NS_ASSUME_NONNULL_BEGIN

//https://github.com/InteractiveAdvertisingBureau/openrtb/blob/master/extensions/community_extensions/skadnetwork.md

@interface OXAORTBBidExtSkadn : OXMORTBAbstract

// Version of SKAdNetwork desired. Must be 2.0 or above
@property (nonatomic, copy, nullable) NSString *version;
// Ad network identifier used in signature
@property (nonatomic, copy, nullable) NSString *network;
// Campaign ID compatible with Apple’s spec
@property (nonatomic, copy, nullable) NSNumber *campaign;
// ID of advertiser’s app in Apple’s app store
@property (nonatomic, copy, nullable) NSNumber *itunesitem;
// An id unique to each ad response
@property (nonatomic, copy, nullable) NSUUID   *nonce;
// ID of publisher’s app in Apple’s app store
@property (nonatomic, copy, nullable) NSNumber *sourceapp;
// Unix time in millis used at the time of signature
@property (nonatomic, copy, nullable) NSNumber *timestamp;
// SKAdNetwork signature as specified by Apple
@property (nonatomic, copy, nullable) NSString *signature;

//Placeholder for exchange-specific extensions to OpenRTB.
//Note: ext object not supported.

@end

NS_ASSUME_NONNULL_END
