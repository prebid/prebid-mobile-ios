//
//  PBMBidRequesterFactory.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMBidRequesterFactoryBlock.h"

@class PrebidRenderingConfig;
@class PrebidRenderingTargeting;
@protocol PBMServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface PBMBidRequesterFactory : NSObject

@property (nonatomic, class, readonly) PBMBidRequesterFactoryBlock requesterFactoryWithSingletons;

+ (PBMBidRequesterFactoryBlock)requesterFactoryWithConnection:(id<PBMServerConnectionProtocol>)connection
                                             sdkConfiguration:(PrebidRenderingConfig *)sdkConfiguration
                                                    targeting:(PrebidRenderingTargeting *)targeting;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
