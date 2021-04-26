//
//  PBMNativeViewClickHandlerBlock.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import Foundation;

@class UIView;

NS_ASSUME_NONNULL_BEGIN

typedef void (^PBMNativeViewClickHandlerBlock)(NSString *url,
                                               NSString * _Nullable fallback,
                                               NSArray<NSString *> * _Nullable clicktrackers,
                                               PBMVoidBlock _Nullable onClickthroughExitBlock);

NS_ASSUME_NONNULL_END
