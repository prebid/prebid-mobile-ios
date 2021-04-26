//
//  PBMORTBDeviceExtPrebid.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBAbstract.h"

@class PBMORTBDeviceExtPrebidInterstitial;

NS_ASSUME_NONNULL_BEGIN

@interface PBMORTBDeviceExtPrebid : PBMORTBAbstract

@property (nonatomic, strong, nonnull) PBMORTBDeviceExtPrebidInterstitial *interstitial;

@end

NS_ASSUME_NONNULL_END
