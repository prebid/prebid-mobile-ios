//
//  PBMTransactionFactory.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMTransactionFactoryCallback.h"

@class PBMBid;
@class PBMAdConfiguration;
@class PBMAdUnitConfig;

@protocol PBMServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface PBMTransactionFactory : NSObject

- (instancetype)initWithBid:(PBMBid *)bid
            adConfiguration:(PBMAdUnitConfig *)adConfiguration
                 connection:(id<PBMServerConnectionProtocol>)connection
                   callback:(PBMTransactionFactoryCallback)callback;

- (BOOL)loadWithAdMarkup:(NSString *)adMarkup;

@end

NS_ASSUME_NONNULL_END
