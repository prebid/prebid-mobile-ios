//
//  OXAExternalURLOpenCallbacks.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAURLOpenResultHandlerBlock.h"
#import "OXMVoidBlock.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXAExternalURLOpenCallbacks : NSObject

@property (nonatomic, copy, readonly) OXAURLOpenResultHandlerBlock urlOpenedCallback;
@property (nonatomic, copy, readonly, nullable) OXMVoidBlock onClickthroughExitBlock;

- (instancetype)initWithUrlOpenedCallback:(OXAURLOpenResultHandlerBlock)urlOpenedCallback
                  onClickthroughExitBlock:(nullable OXMVoidBlock)onClickthroughExitBlock NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
