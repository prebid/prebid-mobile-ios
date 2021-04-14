//
//  OXAVastTransactionFactory.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXATransactionFactoryCallback.h"

@class OXMAdConfiguration;
@protocol OXMServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface OXAVastTransactionFactory : NSObject

- (instancetype)initWithConnection:(id<OXMServerConnectionProtocol>)connection
                   adConfiguration:(OXMAdConfiguration *)adConfiguration
                          callback:(OXATransactionFactoryCallback)callback;

- (BOOL)loadWithAdMarkup:(NSString *)adMarkup;

@end

NS_ASSUME_NONNULL_END
