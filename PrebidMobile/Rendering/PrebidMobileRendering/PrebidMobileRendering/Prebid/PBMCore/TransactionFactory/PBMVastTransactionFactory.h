//
//  PBMVastTransactionFactory.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMTransactionFactoryCallback.h"

@class PBMAdConfiguration;
@protocol PBMServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface PBMVastTransactionFactory : NSObject

- (instancetype)initWithConnection:(id<PBMServerConnectionProtocol>)connection
                   adConfiguration:(PBMAdConfiguration *)adConfiguration
                          callback:(PBMTransactionFactoryCallback)callback;

- (BOOL)loadWithAdMarkup:(NSString *)adMarkup;

@end

NS_ASSUME_NONNULL_END
