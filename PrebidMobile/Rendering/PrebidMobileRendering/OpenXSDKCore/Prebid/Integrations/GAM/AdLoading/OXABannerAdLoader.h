//
//  OXABannerAdLoader.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OXAAdLoaderProtocol.h"
#import "OXABannerAdLoaderDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXABannerAdLoader : NSObject <OXAAdLoaderProtocol>

- (instancetype)initWithDelegate:(id<OXABannerAdLoaderDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
