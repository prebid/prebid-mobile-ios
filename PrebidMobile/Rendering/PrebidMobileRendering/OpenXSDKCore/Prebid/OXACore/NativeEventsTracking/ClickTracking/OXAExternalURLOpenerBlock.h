//
//  OXAExternalURLOpenerBlock.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAURLOpenResultHandlerBlock.h"
#import "OXMVoidBlock.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^OXAExternalURLOpenerBlock)(NSURL *url,
                                          OXAURLOpenResultHandlerBlock completion,
                                          OXMVoidBlock _Nullable onClickthroughExitBlock);

NS_ASSUME_NONNULL_END
