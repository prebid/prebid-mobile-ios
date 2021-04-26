//
//  PBMAdLoaderFlowDelegate.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PBMAdLoaderProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol PBMAdLoaderFlowDelegate <NSObject>

- (void)adLoader:(id<PBMAdLoaderProtocol>)adLoader loadedPrimaryAd:(id)adObject adSize:(nullable NSValue *)adSize;
- (void)adLoader:(id<PBMAdLoaderProtocol>)adLoader failedWithPrimarySDKError:(nullable NSError *)error;

- (void)adLoaderDidWinPrebid:(id<PBMAdLoaderProtocol>)adLoader;

- (void)adLoaderLoadedPrebidAd:(id<PBMAdLoaderProtocol>)adLoader;
- (void)adLoader:(id<PBMAdLoaderProtocol>)adLoader failedWithPrebidError:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
