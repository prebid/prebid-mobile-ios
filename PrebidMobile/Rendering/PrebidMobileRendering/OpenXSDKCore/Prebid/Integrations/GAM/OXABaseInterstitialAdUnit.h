//
//  OXABaseInterstitialAdUnit.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import UIKit;

#import "OXAAdFormat.h"

@protocol OXAInterstitialEventHandler;

NS_ASSUME_NONNULL_BEGIN

@interface OXABaseInterstitialAdUnit<__covariant EventHandlerType, __covariant DelegateType> : NSObject

@property (nonatomic, readonly) NSString *configId;
@property (nonatomic, readonly) BOOL isReady;

@property (nonatomic, weak, nullable) DelegateType delegate;

- (instancetype)initWithConfigId:(NSString *)configId eventHandler:(EventHandlerType)eventHandler;
- (instancetype)initWithConfigId:(NSString *)configId;

- (void)loadAd;
- (void)showFromViewController:(UIViewController *)controller;

// MARK: - Context Data
// Note: context data is stored with 'copy' semantics
- (void)addContextData:(NSString *)data forKey:(NSString *)key;
- (void)updateContextData:(NSSet<NSString *> *)data forKey:(NSString *)key;
- (void)removeContextDataForKey:(NSString *)key;
- (void)clearContextData;

@end

NS_ASSUME_NONNULL_END
