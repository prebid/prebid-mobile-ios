//
//  OXAMoPubInterstitialAdUnit.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import UIKit;

#import "OXAFetchDemandResult.h"
#import "OXAAdFormat.h"

#import "OXAMoPubBaseInterstitialAdUnit.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXAMoPubInterstitialAdUnit : OXAMoPubBaseInterstitialAdUnit

@property (nonatomic, copy, readonly) NSString *configId;
@property (nonatomic) OXAAdFormat adFormat;

- (instancetype)initWithConfigId:(NSString *)configId minSizePercentage:(CGSize)minSizePercentage;
- (instancetype)initWithConfigId:(NSString *)configId;

@end

NS_ASSUME_NONNULL_END
