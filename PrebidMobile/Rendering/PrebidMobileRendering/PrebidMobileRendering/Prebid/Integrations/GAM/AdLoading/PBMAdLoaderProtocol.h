//
//  PBMAdLoaderProtocol.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Bid;
@class AdUnitConfig;

@protocol PBMAdLoaderFlowDelegate;
@protocol PBMPrimaryAdRequesterProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol PBMAdLoaderProtocol <NSObject>

@property (nonatomic, weak, nullable) id<PBMAdLoaderFlowDelegate> flowDelegate;

@property (nonatomic, readonly) id<PBMPrimaryAdRequesterProtocol> primaryAdRequester;

- (void)createPrebidAdWithBid:(Bid *)bid
                 adUnitConfig:(AdUnitConfig *)adUnitConfig
                adObjectSaver:(void (^)(id))adObjectSaver
            loadMethodInvoker:(void (^)(dispatch_block_t))loadMethodInvoker;

- (void)reportSuccessWithAdObject:(id)adObject adSize:(nullable NSValue *)adSize;

@end

NS_ASSUME_NONNULL_END
