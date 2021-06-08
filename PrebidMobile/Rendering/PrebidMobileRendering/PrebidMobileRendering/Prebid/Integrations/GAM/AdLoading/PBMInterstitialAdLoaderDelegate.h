//
//  PBMInterstitialAdLoaderDelegate.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PBMInterstitialAdLoader;
@class InterstitialController;
@protocol InterstitialEventHandlerProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol PBMInterstitialAdLoaderDelegate <NSObject>

@required

@property (nonatomic, strong, nullable, readonly) id eventHandler;

// Loading callbacks
- (void)interstitialAdLoader:(PBMInterstitialAdLoader *)interstitialAdLoader
                    loadedAd:(void (^)(UIViewController * _Nullable))showBlock
                isReadyBlock:(BOOL (^)(void))isReadyBlock;

// Hook to insert interaction delegate
- (void) interstitialAdLoader:(PBMInterstitialAdLoader *)interstitialAdLoader
createdInterstitialController:(InterstitialController *)interstitialController;

@optional

@property (nonatomic, strong, nullable) NSObject *reward;

@end

NS_ASSUME_NONNULL_END
