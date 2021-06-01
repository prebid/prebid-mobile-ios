//
//  PBMBidRequester.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMBidRequesterProtocol.h"

@class AdUnitConfig;
@class PrebidRenderingConfig;
@class PrebidRenderingTargeting;
@protocol PBMServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface PBMBidRequester : NSObject <PBMBidRequesterProtocol>

- (instancetype)initWithConnection:(id<PBMServerConnectionProtocol>)connection
                  sdkConfiguration:(PrebidRenderingConfig *)sdkConfiguration
                         targeting:(PrebidRenderingTargeting *)targeting
               adUnitConfiguration:(AdUnitConfig *)adUnitConfiguration;

- (void)requestBidsWithCompletion:(void (^)(BidResponse * _Nullable, NSError * _Nullable))completion;

@end

NS_ASSUME_NONNULL_END
