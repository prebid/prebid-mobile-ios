//
//  PBMDisplayTransactionFactory.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMTransactionFactoryCallback.h"

@class PBMBid;
@class PBMAdConfiguration;
@class PBMAdUnitConfig;

@protocol PBMServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface PBMDisplayTransactionFactory : NSObject

- (instancetype)initWithBid:(PBMBid *)bid
            adConfiguration:(PBMAdUnitConfig *)adConfiguration
                 connection:(id<PBMServerConnectionProtocol>)connection
                   callback:(PBMTransactionFactoryCallback)callback;

- (BOOL)loadWithAdMarkup:(NSString *)adMarkup;

@end

NS_ASSUME_NONNULL_END
