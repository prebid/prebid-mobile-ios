//
//  PBMDFPInterstitial.h
//  OpenXApolloGAMEventHandlers
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "PBMDFPRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMDFPInterstitial : NSObject

@property (nonatomic, class, readonly) BOOL classesFound;
@property (nonatomic, strong, readonly) NSObject *boxedInterstitial;

// Boxed properties
@property (nonatomic, readonly) BOOL isReady;
@property (nonatomic, weak, nullable) id<GADInterstitialDelegate> delegate;
@property (nonatomic, weak, nullable) id<GADAppEventDelegate> appEventDelegate;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAdUnitID:(NSString *)adUnitID NS_DESIGNATED_INITIALIZER;

- (void)loadRequest:(nullable PBMDFPRequest *)request;
- (void)presentFromRootViewController:(nonnull UIViewController *)rootViewController;

@end

NS_ASSUME_NONNULL_END
