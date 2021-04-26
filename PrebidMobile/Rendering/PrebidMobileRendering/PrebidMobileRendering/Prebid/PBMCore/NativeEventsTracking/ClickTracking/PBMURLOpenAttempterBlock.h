//
//  PBMURLOpenAttempterBlock.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMExternalURLOpenerBlock.h"
#import "PBMExternalURLOpenCallbacks.h"

NS_ASSUME_NONNULL_BEGIN

// will return ('nop', nil) container if passed NO; otherwise -- will return completion handlers.
typedef PBMExternalURLOpenCallbacks * _Nonnull (^PBMCanOpenURLResultHandlerBlock)(BOOL willOpenURL);

// pass 'YES' to 'compatibilityCheckHandler' to get URL handling completion block;
// if incompatible, call 'compatibilityCheckHandler' with NO.
typedef void (^PBMURLOpenAttempterBlock)(NSURL *url, PBMCanOpenURLResultHandlerBlock compatibilityCheckHandler);

NS_ASSUME_NONNULL_END
