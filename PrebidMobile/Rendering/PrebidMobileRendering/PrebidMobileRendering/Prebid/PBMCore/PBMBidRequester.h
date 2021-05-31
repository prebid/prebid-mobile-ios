//
//  PBMBidRequester.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMBidRequesterProtocol.h"

@class AdUnitConfig;
@class PBMSDKConfiguration;
@class PBMTargeting;
@protocol PBMServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface PBMBidRequester : NSObject <PBMBidRequesterProtocol>

- (instancetype)initWithConnection:(id<PBMServerConnectionProtocol>)connection
                  sdkConfiguration:(PBMSDKConfiguration *)sdkConfiguration
                         targeting:(PBMTargeting *)targeting
               adUnitConfiguration:(AdUnitConfig *)adUnitConfiguration;

- (void)requestBidsWithCompletion:(void (^)(BidResponse * _Nullable, NSError * _Nullable))completion;

@end

NS_ASSUME_NONNULL_END
