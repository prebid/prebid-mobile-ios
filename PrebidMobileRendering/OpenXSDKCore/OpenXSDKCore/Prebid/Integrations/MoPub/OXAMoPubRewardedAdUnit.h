//
//  OXAMoPubRewardedAdUnit.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXAMoPubBaseInterstitialAdUnit.h"
#import "OXAMoPubInterstitialAdUnit.h"

NS_ASSUME_NONNULL_BEGIN

// A wrapper for passing prebid data to MoPub rewarded video loader
@interface OXAMoPubBidInfoWrapper: NSObject

@property (nonatomic, copy) NSString *keywords;
@property (nonatomic, copy) NSDictionary *localExtras;

@end

@interface OXAMoPubRewardedAdUnit : OXAMoPubBaseInterstitialAdUnit
@end

NS_ASSUME_NONNULL_END
