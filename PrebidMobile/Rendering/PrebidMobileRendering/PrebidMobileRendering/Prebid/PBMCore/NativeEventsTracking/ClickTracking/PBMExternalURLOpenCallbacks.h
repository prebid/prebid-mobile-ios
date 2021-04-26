//
//  PBMExternalURLOpenCallbacks.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMURLOpenResultHandlerBlock.h"
#import "PBMVoidBlock.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMExternalURLOpenCallbacks : NSObject

@property (nonatomic, copy, readonly) PBMURLOpenResultHandlerBlock urlOpenedCallback;
@property (nonatomic, copy, readonly, nullable) PBMVoidBlock onClickthroughExitBlock;

- (instancetype)initWithUrlOpenedCallback:(PBMURLOpenResultHandlerBlock)urlOpenedCallback
                  onClickthroughExitBlock:(nullable PBMVoidBlock)onClickthroughExitBlock NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
