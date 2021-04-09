//
//  OXABidRequester.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXABidRequesterProtocol.h"

@class OXAAdUnitConfig;
@class OXASDKConfiguration;
@class OXATargeting;
@protocol OXMServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface OXABidRequester : NSObject <OXABidRequesterProtocol>

- (instancetype)initWithConnection:(id<OXMServerConnectionProtocol>)connection
                  sdkConfiguration:(OXASDKConfiguration *)sdkConfiguration
                         targeting:(OXATargeting *)targeting
               adUnitConfiguration:(OXAAdUnitConfig *)adUnitConfiguration;

- (void)requestBidsWithCompletion:(void (^)(OXABidResponse * _Nullable, NSError * _Nullable))completion;

@end

NS_ASSUME_NONNULL_END
