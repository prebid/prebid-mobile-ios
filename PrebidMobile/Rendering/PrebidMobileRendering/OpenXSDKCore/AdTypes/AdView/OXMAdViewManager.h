//
//  OXMAdViewManager.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

//Superclass
#import <Foundation/Foundation.h>

#import "OXMAdConfiguration.h"
#import "OXMAdLoadManagerDelegate.h"
#import "OXMAdViewManagerDelegate.h"
#import "OXMCreativeViewDelegate.h"

@class OXMModalManager;
@protocol OXMModalManagerDelegate;
@protocol OXMServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN
@interface OXMAdViewManager : NSObject <OXMCreativeViewDelegate>

@property (nonatomic, strong) OXMAdConfiguration *adConfiguration;
@property (nonatomic, strong) OXMModalManager *modalManager;
@property (nonatomic, weak, nullable) id<OXMAdViewManagerDelegate> adViewManagerDelegate;
@property (nonatomic, assign) BOOL autoDisplayOnLoad;
@property (nonatomic, readonly) BOOL isCreativeOpened;

@property (nonatomic, readonly, getter=isMuted) BOOL muted;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithConnection:(id<OXMServerConnectionProtocol>)connection
              modalManagerDelegate:(nullable id<OXMModalManagerDelegate>)modalManagerDelegate NS_DESIGNATED_INITIALIZER;

- (nullable NSString*)revenueForNextCreative;

// Indicates whether the manager has all the needed data to show the add.
// If NO then the show method will not lead to displaying the ad.
- (BOOL)isAbleToShowCurrentCreative;

- (void)show;
- (void)pause;
- (void)resume;

- (void)mute;
- (void)unmute;


- (void)handleExternalTransaction:(OXMTransaction *)transaction;

@end
NS_ASSUME_NONNULL_END
