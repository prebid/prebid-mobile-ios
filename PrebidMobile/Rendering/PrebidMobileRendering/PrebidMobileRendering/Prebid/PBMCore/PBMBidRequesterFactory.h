//
//  PBMBidRequesterFactory.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMBidRequesterFactoryBlock.h"

@class PBMSDKConfiguration;
@class PBMTargeting;
@protocol PBMServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface PBMBidRequesterFactory : NSObject

@property (nonatomic, class, readonly) PBMBidRequesterFactoryBlock requesterFactoryWithSingletons;

+ (PBMBidRequesterFactoryBlock)requesterFactoryWithConnection:(id<PBMServerConnectionProtocol>)connection
                                             sdkConfiguration:(PBMSDKConfiguration *)sdkConfiguration
                                                    targeting:(PBMTargeting *)targeting;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
