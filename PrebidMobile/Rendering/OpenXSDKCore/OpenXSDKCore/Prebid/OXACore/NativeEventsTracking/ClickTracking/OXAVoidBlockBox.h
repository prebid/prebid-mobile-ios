//
//  OXAVoidBlockBox.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXMVoidBlock.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXAVoidBlockBox : NSObject

- (instancetype)initWithBlock:(OXMVoidBlock)block;

- (instancetype)init NS_UNAVAILABLE;

- (void)invoke;

@end

NS_ASSUME_NONNULL_END
