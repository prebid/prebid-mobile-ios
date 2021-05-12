//
//  MPRewardedAdConnection.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

@class MPRewardedAdConnection;

@protocol MPRewardedAdConnectionDelegate <NSObject>

- (void)rewardedAdConnectionCompleted:(MPRewardedAdConnection *)connection url:(NSURL *)url;

@end

@interface MPRewardedAdConnection : NSObject

- (instancetype)initWithUrl:(NSURL *)url delegate:(id<MPRewardedAdConnectionDelegate>)delegate;
- (void)sendRewardedAdCompletionRequest;

@end
