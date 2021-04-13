//
//  OXAAdLoaderProtocol.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OXAAdUnitConfig;
@class OXABid;

@protocol OXAAdLoaderFlowDelegate;
@protocol OXAPrimaryAdRequesterProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol OXAAdLoaderProtocol <NSObject>

@property (nonatomic, weak, nullable) id<OXAAdLoaderFlowDelegate> flowDelegate;

@property (nonatomic, readonly) id<OXAPrimaryAdRequesterProtocol> primaryAdRequester;

- (void)createApolloAdWithBid:(OXABid *)bid
                 adUnitConfig:(OXAAdUnitConfig *)adUnitConfig
                adObjectSaver:(void (^)(id))adObjectSaver
            loadMethodInvoker:(void (^)(dispatch_block_t))loadMethodInvoker;

- (void)reportSuccessWithAdObject:(id)adObject adSize:(nullable NSValue *)adSize;

@end

NS_ASSUME_NONNULL_END
