//
//  MPRewardedAds+Internal.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPRewardedAds.h"

@interface MPRewardedAds (Internal)

+ (MPRewardedAds *)sharedInstance;
- (void)startRewardedAdConnectionWithUrl:(NSURL *)url;

@end
