//
//  OXAInterstitialController.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXAAdFormat.h"
#import "OXAInterstitialControllerLoadingDelegate.h"
#import "OXAInterstitialControllerInteractionDelegate.h"

@class OXAAdUnitConfig;
@class OXABid;

NS_ASSUME_NONNULL_BEGIN

@interface OXAInterstitialController : NSObject

@property (nonatomic) OXAAdFormat adFormat;

/**
 Sets a video interstitial ad unit as an opt-in video
 */
@property (nonatomic) BOOL isOptIn;

@property (atomic, weak, nullable) id<OXAInterstitialControllerLoadingDelegate> loadingDelegate;
@property (atomic, weak, nullable) id<OXAInterstitialControllerInteractionDelegate> interactionDelegate;

- (instancetype)initWithBid:(OXABid *)bid configId:(NSString *)configId;
- (instancetype)initWithBid:(OXABid *)bid adConfiguration:(OXAAdUnitConfig *)adConfiguration;

- (void)loadAd;
- (void)show;

@end

NS_ASSUME_NONNULL_END
