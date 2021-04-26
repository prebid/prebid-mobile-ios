//
//  PBMDisplayViewLoadingDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PBMDisplayView;

NS_ASSUME_NONNULL_BEGIN

@protocol PBMDisplayViewLoadingDelegate <NSObject>

@required

- (void)displayViewDidLoadAd:(PBMDisplayView *)displayView;
- (void)displayView:(PBMDisplayView *)displayView didFailWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
