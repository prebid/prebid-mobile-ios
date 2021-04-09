//
//  OXAInterstitialAdUnit.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OXABaseInterstitialAdUnit.h"

#import "OXAInterstitialAdUnitDelegate.h"

@protocol OXAInterstitialEventHandler;

NS_ASSUME_NONNULL_BEGIN

@interface OXAInterstitialAdUnit : OXABaseInterstitialAdUnit<id<OXAInterstitialEventHandler>, id<OXAInterstitialAdUnitDelegate> >

@property (nonatomic) OXAAdFormat adFormat;

- (instancetype)initWithConfigId:(NSString *)configId minSizePercentage:(CGSize)minSizePercentage;
- (instancetype)initWithConfigId:(NSString *)configId
               minSizePercentage:(CGSize)minSizePercentage
                    eventHandler:(id<OXAInterstitialEventHandler>)eventHandler;

@end

NS_ASSUME_NONNULL_END
