//
//  OXAInterstitialAdLoaderDelegate.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class OXAInterstitialAdLoader;
@class OXAInterstitialController;
@protocol OXAInterstitialEventHandler;

NS_ASSUME_NONNULL_BEGIN

@protocol OXAInterstitialAdLoaderDelegate <NSObject>

@required

@property (nonatomic, strong, nullable, readonly) id<OXAInterstitialEventHandler> eventHandler;

// Loading callbacks
- (void)interstitialAdLoader:(OXAInterstitialAdLoader *)interstitialAdLoader
                    loadedAd:(void (^)(UIViewController *))showBlock
                isReadyBlock:(BOOL (^)(void))isReadyBlock;

// Hook to insert interaction delegate
- (void) interstitialAdLoader:(OXAInterstitialAdLoader *)interstitialAdLoader
createdInterstitialController:(OXAInterstitialController *)interstitialController;

@optional

@property (nonatomic, strong, nullable) NSObject *reward;

@end

NS_ASSUME_NONNULL_END
