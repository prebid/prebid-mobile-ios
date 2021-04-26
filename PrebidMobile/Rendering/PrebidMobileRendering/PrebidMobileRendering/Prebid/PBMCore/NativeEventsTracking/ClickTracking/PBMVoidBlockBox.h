//
//  PBMVoidBlockBox.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMVoidBlock.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMVoidBlockBox : NSObject

- (instancetype)initWithBlock:(PBMVoidBlock)block;

- (instancetype)init NS_UNAVAILABLE;

- (void)invoke;

@end

NS_ASSUME_NONNULL_END
