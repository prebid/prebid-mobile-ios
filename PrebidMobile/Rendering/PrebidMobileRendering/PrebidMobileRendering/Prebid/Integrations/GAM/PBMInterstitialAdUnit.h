//
//  PBMInterstitialAdUnit.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PBMBaseInterstitialAdUnit.h"

#import "PBMInterstitialAdUnitDelegate.h"

@protocol PBMInterstitialEventHandler;

NS_ASSUME_NONNULL_BEGIN

@interface PBMInterstitialAdUnit : PBMBaseInterstitialAdUnit<id<PBMInterstitialEventHandler>, id<PBMInterstitialAdUnitDelegate> >

@property (nonatomic) PBMAdFormat adFormat;

- (instancetype)initWithConfigId:(NSString *)configId minSizePercentage:(CGSize)minSizePercentage;
- (instancetype)initWithConfigId:(NSString *)configId
               minSizePercentage:(CGSize)minSizePercentage
                    eventHandler:(id<PBMInterstitialEventHandler>)eventHandler;

@end

NS_ASSUME_NONNULL_END
