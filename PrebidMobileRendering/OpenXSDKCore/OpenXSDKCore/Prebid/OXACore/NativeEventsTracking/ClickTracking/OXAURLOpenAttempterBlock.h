//
//  OXAURLOpenAttempterBlock.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAExternalURLOpenerBlock.h"
#import "OXAExternalURLOpenCallbacks.h"

NS_ASSUME_NONNULL_BEGIN

// will return ('nop', nil) container if passed NO; otherwise -- will return completion handlers.
typedef OXAExternalURLOpenCallbacks * _Nonnull (^OXACanOpenURLResultHandlerBlock)(BOOL willOpenURL);

// pass 'YES' to 'compatibilityCheckHandler' to get URL handling completion block;
// if incompatible, call 'compatibilityCheckHandler' with NO.
typedef void (^OXAURLOpenAttempterBlock)(NSURL *url, OXACanOpenURLResultHandlerBlock compatibilityCheckHandler);

NS_ASSUME_NONNULL_END
