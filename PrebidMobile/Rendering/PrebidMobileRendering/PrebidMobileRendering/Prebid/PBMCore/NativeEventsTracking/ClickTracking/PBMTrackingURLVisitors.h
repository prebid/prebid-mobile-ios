//
//  PBMTrackingURLVisitors.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMTrackingURLVisitorBlock.h"
#import "PBMServerConnectionProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMTrackingURLVisitors : NSObject

+ (PBMTrackingURLVisitorBlock)connectionAsTrackingURLVisitor:(id<PBMServerConnectionProtocol>)connection;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
