//
//  OXATrackingURLVisitors.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXATrackingURLVisitorBlock.h"
#import "OXMServerConnectionProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXATrackingURLVisitors : NSObject

+ (OXATrackingURLVisitorBlock)connectionAsTrackingURLVisitor:(id<OXMServerConnectionProtocol>)connection;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
