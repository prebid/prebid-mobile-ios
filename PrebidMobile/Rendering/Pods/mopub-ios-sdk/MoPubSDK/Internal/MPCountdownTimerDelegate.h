//
//  MPCountdownTimerDelegate.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MPCountdownTimerDelegate <NSObject>

- (void)countdownTimerDidFinishCountdown:(id)source;

@end

NS_ASSUME_NONNULL_END
