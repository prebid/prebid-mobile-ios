//
//  PBMDisplayTransactionFactory.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMTransactionFactoryCallback.h"

@class AdUnitConfig;
@class PBMBid;
@class PBMAdConfiguration;

@protocol PBMServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface PBMDisplayTransactionFactory : NSObject

- (instancetype)initWithBid:(PBMBid *)bid
            adConfiguration:(AdUnitConfig *)adConfiguration
                 connection:(id<PBMServerConnectionProtocol>)connection
                   callback:(PBMTransactionFactoryCallback)callback;

- (BOOL)loadWithAdMarkup:(NSString *)adMarkup;

@end

NS_ASSUME_NONNULL_END
