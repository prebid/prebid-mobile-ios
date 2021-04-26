//
//  PBMMoPubInterstitialAdUnit.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import UIKit;

#import "PBMFetchDemandResult.h"
#import "PBMAdFormat.h"

#import "PBMMoPubBaseInterstitialAdUnit.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMMoPubInterstitialAdUnit : PBMMoPubBaseInterstitialAdUnit

@property (nonatomic, copy, readonly) NSString *configId;
@property (nonatomic) PBMAdFormat adFormat;

- (instancetype)initWithConfigId:(NSString *)configId minSizePercentage:(CGSize)minSizePercentage;
- (instancetype)initWithConfigId:(NSString *)configId;

@end

NS_ASSUME_NONNULL_END
