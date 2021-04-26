//
//  PBMORTBDeviceExtAtts.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBAbstract.h"

NS_ASSUME_NONNULL_BEGIN

// If the IDFA is not available, DSPs require an alternative, limited-scope identifier in order to
//provide basic frequency capping functionality to advertisers
// https://github.com/InteractiveAdvertisingBureau/openrtb/blob/master/extensions/community_extensions/skadnetwork.md#device-extension

@interface PBMORTBDeviceExtAtts : PBMORTBAbstract

// An integer passed to represent the app's app tracking authorization status, where
//0 = not determined
//1 = restricted
//2 = denied
//3 = authorized
@property (nonatomic, strong, nullable) NSNumber *atts;

//IDFV of the device in that publisher. Only passed when IDFA (BidRequest.device.ifa) is unavailable or all zeros
@property (nonatomic, copy, nullable) NSString *ifv;
@end

NS_ASSUME_NONNULL_END
