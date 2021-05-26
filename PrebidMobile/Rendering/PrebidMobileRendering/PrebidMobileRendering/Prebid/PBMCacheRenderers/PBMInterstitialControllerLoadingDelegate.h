//
//  PBMInterstitialControllerLoadingDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class InterstitialController;

NS_ASSUME_NONNULL_BEGIN

@protocol PBMInterstitialControllerLoadingDelegate <NSObject>

@required

- (void)interstitialControllerDidLoadAd:(InterstitialController *)interstitialController;
- (void)interstitialController:(InterstitialController *)interstitialController
              didFailWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
