//
//  PBMExternalURLOpenerBlock.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMURLOpenResultHandlerBlock.h"
#import "PBMVoidBlock.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^PBMExternalURLOpenerBlock)(NSURL *url,
                                          PBMURLOpenResultHandlerBlock completion,
                                          PBMVoidBlock _Nullable onClickthroughExitBlock);

NS_ASSUME_NONNULL_END
