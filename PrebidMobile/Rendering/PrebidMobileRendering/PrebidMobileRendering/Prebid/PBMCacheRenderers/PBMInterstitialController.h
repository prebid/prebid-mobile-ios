//
//  PBMInterstitialController.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMAdFormat.h"
#import "PBMInterstitialControllerLoadingDelegate.h"
#import "PBMInterstitialControllerInteractionDelegate.h"

@class PBMAdUnitConfig;
@class PBMBid;

NS_ASSUME_NONNULL_BEGIN

@interface PBMInterstitialController : NSObject

@property (nonatomic) PBMAdFormat adFormat;

/**
 Sets a video interstitial ad unit as an opt-in video
 */
@property (nonatomic) BOOL isOptIn;

@property (atomic, weak, nullable) id<PBMInterstitialControllerLoadingDelegate> loadingDelegate;
@property (atomic, weak, nullable) id<PBMInterstitialControllerInteractionDelegate> interactionDelegate;

- (instancetype)initWithBid:(PBMBid *)bid configId:(NSString *)configId;
- (instancetype)initWithBid:(PBMBid *)bid adConfiguration:(PBMAdUnitConfig *)adConfiguration;

- (void)loadAd;
- (void)show;

@end

NS_ASSUME_NONNULL_END
