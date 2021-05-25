//
//  PBMBaseInterstitialAdUnit.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import UIKit;

#import "PBMAdFormat.h"

@protocol PBMInterstitialEventHandler;

NS_ASSUME_NONNULL_BEGIN

@interface PBMBaseInterstitialAdUnit : NSObject

@property (nonatomic, readonly) NSString *configId;
@property (nonatomic, readonly) BOOL isReady;

@property (nonatomic, weak, nullable) id delegate;

- (instancetype)initWithConfigId:(NSString *)configId eventHandler:(id)eventHandler;
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
