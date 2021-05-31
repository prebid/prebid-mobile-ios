//
//  PBMTransactionFactory.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMTransactionFactoryCallback.h"

@class AdUnitConfig;
@class Bid;
@class PBMAdConfiguration;

@protocol PBMServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface PBMTransactionFactory : NSObject

- (instancetype)initWithBid:(Bid *)bid
            adConfiguration:(AdUnitConfig *)adConfiguration
                 connection:(id<PBMServerConnectionProtocol>)connection
                   callback:(PBMTransactionFactoryCallback)callback;

- (BOOL)loadWithAdMarkup:(NSString *)adMarkup;

@end

NS_ASSUME_NONNULL_END
