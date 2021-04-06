//
//  OXABidRequesterFactory.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXABidRequesterFactoryBlock.h"

@class OXASDKConfiguration;
@class OXATargeting;
@protocol OXMServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface OXABidRequesterFactory : NSObject

@property (nonatomic, class, readonly) OXABidRequesterFactoryBlock requesterFactoryWithSingletons;

+ (OXABidRequesterFactoryBlock)requesterFactoryWithConnection:(id<OXMServerConnectionProtocol>)connection
                                             sdkConfiguration:(OXASDKConfiguration *)sdkConfiguration
                                                    targeting:(OXATargeting *)targeting;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
