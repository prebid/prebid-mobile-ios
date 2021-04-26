//
//  PBMInterstitialControllerLoadingDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PBMInterstitialController;

NS_ASSUME_NONNULL_BEGIN

@protocol PBMInterstitialControllerLoadingDelegate <NSObject>

@required

- (void)interstitialControllerDidLoadAd:(PBMInterstitialController *)interstitialController;
- (void)interstitialController:(PBMInterstitialController *)interstitialController
              didFailWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
