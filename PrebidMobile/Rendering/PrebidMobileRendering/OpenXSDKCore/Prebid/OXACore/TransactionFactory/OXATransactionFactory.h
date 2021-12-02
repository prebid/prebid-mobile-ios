//
//  OXATransactionFactory.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXATransactionFactoryCallback.h"

@class OXABid;
@class OXMAdConfiguration;
@class OXAAdUnitConfig;

@protocol OXMServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface OXATransactionFactory : NSObject

- (instancetype)initWithBid:(OXABid *)bid
            adConfiguration:(OXAAdUnitConfig *)adConfiguration
                 connection:(id<OXMServerConnectionProtocol>)connection
                   callback:(OXATransactionFactoryCallback)callback;

- (BOOL)loadWithAdMarkup:(NSString *)adMarkup;

@end

NS_ASSUME_NONNULL_END
