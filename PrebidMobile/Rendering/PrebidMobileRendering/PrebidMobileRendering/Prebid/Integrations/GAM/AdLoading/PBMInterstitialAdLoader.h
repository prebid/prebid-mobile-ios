//
//  PBMInterstitialAdLoader.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PBMAdLoaderProtocol.h"
#import "PBMInterstitialAdLoaderDelegate.h"
#import "PBMRewardedEventLoadingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMInterstitialAdLoader : NSObject <PBMAdLoaderProtocol, PBMRewardedEventLoadingDelegate>

- (instancetype)initWithDelegate:(id<PBMInterstitialAdLoaderDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
