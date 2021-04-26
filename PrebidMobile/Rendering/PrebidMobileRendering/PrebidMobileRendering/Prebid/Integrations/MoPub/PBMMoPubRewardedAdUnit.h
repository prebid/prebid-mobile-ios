//
//  PBMMoPubRewardedAdUnit.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMMoPubBaseInterstitialAdUnit.h"
#import "PBMMoPubInterstitialAdUnit.h"

NS_ASSUME_NONNULL_BEGIN

// A wrapper for passing prebid data to MoPub rewarded video loader
@interface PBMMoPubBidInfoWrapper: NSObject

@property (nonatomic, copy) NSString *keywords;
@property (nonatomic, copy) NSDictionary *localExtras;

@end

@interface PBMMoPubRewardedAdUnit : PBMMoPubBaseInterstitialAdUnit
@end

NS_ASSUME_NONNULL_END
