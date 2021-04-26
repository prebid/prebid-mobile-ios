//
//  PBMORTBImpExtSkadn.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBAbstract.h"

NS_ASSUME_NONNULL_BEGIN

//This object includes signals necessary for support SKAdNetwork
//https://github.com/InteractiveAdvertisingBureau/openrtb/blob/master/extensions/community_extensions/skadnetwork.md
@interface PBMORTBImpExtSkadn : PBMORTBAbstract

// ID of publisher app in Apple’s App Store.
@property (nonatomic, copy, nullable) NSString *sourceapp;

//A subset of SKAdNetworkItem entries in the publisher app’s Info.plist that are relevant to the DSP.
@property (nonatomic, copy) NSArray<NSString *> *skadnetids;

//Placeholder for exchange-specific extensions to OpenRTB.
//Note: ext object is not supported.

- (instancetype )init;

@end

NS_ASSUME_NONNULL_END
