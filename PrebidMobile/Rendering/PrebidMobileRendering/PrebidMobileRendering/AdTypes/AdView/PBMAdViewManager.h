//
//  PBMAdViewManager.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

//Superclass
#import <Foundation/Foundation.h>

#import "PBMAdConfiguration.h"
#import "PBMAdLoadManagerDelegate.h"
#import "PBMAdViewManagerDelegate.h"
#import "PBMCreativeViewDelegate.h"

@class PBMModalManager;
@protocol PBMModalManagerDelegate;
@protocol PBMServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN
@interface PBMAdViewManager : NSObject <PBMCreativeViewDelegate>

@property (nonatomic, strong) PBMAdConfiguration *adConfiguration;
@property (nonatomic, strong) PBMModalManager *modalManager;
@property (nonatomic, weak, nullable) id<PBMAdViewManagerDelegate> adViewManagerDelegate;
@property (nonatomic, assign) BOOL autoDisplayOnLoad;
@property (nonatomic, readonly) BOOL isCreativeOpened;

@property (nonatomic, readonly, getter=isMuted) BOOL muted;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithConnection:(id<PBMServerConnectionProtocol>)connection
              modalManagerDelegate:(nullable id<PBMModalManagerDelegate>)modalManagerDelegate NS_DESIGNATED_INITIALIZER;

- (nullable NSString*)revenueForNextCreative;

// Indicates whether the manager has all the needed data to show the add.
// If NO then the show method will not lead to displaying the ad.
- (BOOL)isAbleToShowCurrentCreative;

- (void)show;
- (void)pause;
- (void)resume;

- (void)mute;
- (void)unmute;


- (void)handleExternalTransaction:(PBMTransaction *)transaction;

@end
NS_ASSUME_NONNULL_END
