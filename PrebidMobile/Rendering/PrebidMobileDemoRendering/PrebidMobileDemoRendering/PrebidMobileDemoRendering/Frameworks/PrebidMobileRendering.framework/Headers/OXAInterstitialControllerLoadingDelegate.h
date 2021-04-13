//
//  OXAInterstitialControllerLoadingDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OXAInterstitialController;

NS_ASSUME_NONNULL_BEGIN

@protocol OXAInterstitialControllerLoadingDelegate <NSObject>

@required

- (void)interstitialControllerDidLoadAd:(OXAInterstitialController *)interstitialController;
- (void)interstitialController:(OXAInterstitialController *)interstitialController
              didFailWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
