//
//  PBMInterstitialAdLoaderDelegate.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PBMInterstitialAdLoader;
@class PBMInterstitialController;
@protocol PBMInterstitialEventHandler;

NS_ASSUME_NONNULL_BEGIN

@protocol PBMInterstitialAdLoaderDelegate <NSObject>

@required

@property (nonatomic, strong, nullable, readonly) id<PBMInterstitialEventHandler> eventHandler;

// Loading callbacks
- (void)interstitialAdLoader:(PBMInterstitialAdLoader *)interstitialAdLoader
                    loadedAd:(void (^)(UIViewController *))showBlock
                isReadyBlock:(BOOL (^)(void))isReadyBlock;

// Hook to insert interaction delegate
- (void) interstitialAdLoader:(PBMInterstitialAdLoader *)interstitialAdLoader
createdInterstitialController:(PBMInterstitialController *)interstitialController;

@optional

@property (nonatomic, strong, nullable) NSObject *reward;

@end

NS_ASSUME_NONNULL_END
