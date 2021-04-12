//
//  OXADisplayViewLoadingDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OXADisplayView;

NS_ASSUME_NONNULL_BEGIN

@protocol OXADisplayViewLoadingDelegate <NSObject>

@required

- (void)displayViewDidLoadAd:(OXADisplayView *)displayView;
- (void)displayView:(OXADisplayView *)displayView didFailWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
