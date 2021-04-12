//
//  OXAInterstitialAdLoader.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OXAAdLoaderProtocol.h"
#import "OXAInterstitialAdLoaderDelegate.h"
#import "OXARewardedEventLoadingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXAInterstitialAdLoader : NSObject <OXAAdLoaderProtocol, OXARewardedEventLoadingDelegate>

- (instancetype)initWithDelegate:(id<OXAInterstitialAdLoaderDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
