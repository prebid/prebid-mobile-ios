//
//  PBMBannerAdLoader.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PBMAdLoaderProtocol.h"

@protocol BannerAdLoaderDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface PBMBannerAdLoader : NSObject <PBMAdLoaderProtocol>

- (instancetype)initWithDelegate:(id<BannerAdLoaderDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
