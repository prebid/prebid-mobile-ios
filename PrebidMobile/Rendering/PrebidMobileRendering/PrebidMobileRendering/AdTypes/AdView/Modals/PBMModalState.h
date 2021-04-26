//
//  PBMModalState.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBMConstants.h"
#import "PBMVoidBlock.h"

@class PBMModalState;

typedef void (^PBMModalStatePopHandler)(PBMModalState * _Nonnull poppedState);
typedef void (^PBMModalStateAppLeavingHandler)(PBMModalState * _Nonnull leavingState);

@class PBMAdConfiguration;
@class PBMInterstitialDisplayProperties;

@interface PBMModalState : NSObject

@property (nonatomic, strong, nullable, readonly) PBMAdConfiguration *adConfiguration;
@property (nonatomic, strong, nullable, readonly) PBMInterstitialDisplayProperties *displayProperties;
@property (nonatomic, strong, nullable, readonly) UIView *view;

@property (nonatomic, copy, nonnull) PBMMRAIDState mraidState;

@property (nonatomic, copy, nullable, readonly) PBMModalStatePopHandler onStatePopFinished;
@property (nonatomic, copy, nullable, readonly) PBMModalStateAppLeavingHandler onStateHasLeftApp;

// Used to transfer delegate function to another object, rather then current delegate for next states pushed on top
// ref: MOBILE-5849
@property (nonatomic, copy, nullable, readonly) PBMModalStatePopHandler nextOnStatePopFinished;
@property (nonatomic, copy, nullable, readonly) PBMModalStateAppLeavingHandler nextOnStateHasLeftApp;

@property (nonatomic, strong, nullable) PBMVoidBlock onModalPushedBlock;

@property (nonatomic, assign, readonly, getter=isRotationEnabled) BOOL rotationEnabled;

- (nonnull instancetype)init NS_UNAVAILABLE;

+ (nonnull instancetype)modalStateWithView:(nonnull UIView *)view
                           adConfiguration:(nullable PBMAdConfiguration *)adConfiguration
                         displayProperties:(nullable PBMInterstitialDisplayProperties *)displayProperties
                        onStatePopFinished:(nullable PBMModalStatePopHandler)onStatePopFinished
                         onStateHasLeftApp:(nullable PBMModalStateAppLeavingHandler)onStateHasLeftApp;


+ (nonnull instancetype)modalStateWithView:(nonnull UIView *)view
                           adConfiguration:(nullable PBMAdConfiguration *)adConfiguration
                         displayProperties:(nullable PBMInterstitialDisplayProperties *)displayProperties
                        onStatePopFinished:(nullable PBMModalStatePopHandler)onStatePopFinished
                         onStateHasLeftApp:(nullable PBMModalStateAppLeavingHandler)onStateHasLeftApp
                    nextOnStatePopFinished:(nullable PBMModalStatePopHandler)nextOnStatePopFinished
                     nextOnStateHasLeftApp:(nullable PBMModalStateAppLeavingHandler)nextOnStateHasLeftApp;


+ (nonnull instancetype)modalStateWithView:(nonnull UIView *)view
                           adConfiguration:(nullable PBMAdConfiguration *)adConfiguration
                         displayProperties:(nullable PBMInterstitialDisplayProperties *)displayProperties
                        onStatePopFinished:(nullable PBMModalStatePopHandler)onStatePopFinished
                         onStateHasLeftApp:(nullable PBMModalStateAppLeavingHandler)onStateHasLeftApp
                        onModalPushedBlock:(nullable PBMVoidBlock)onModalPushedBlock;

+ (nonnull instancetype)modalStateWithView:(nonnull UIView *)view
                           adConfiguration:(nullable PBMAdConfiguration *)adConfiguration
                         displayProperties:(nullable PBMInterstitialDisplayProperties *)displayProperties
                        onStatePopFinished:(nullable PBMModalStatePopHandler)onStatePopFinished
                         onStateHasLeftApp:(nullable PBMModalStateAppLeavingHandler)onStateHasLeftApp
                    nextOnStatePopFinished:(nullable PBMModalStatePopHandler)nextOnStatePopFinished
                     nextOnStateHasLeftApp:(nullable PBMModalStateAppLeavingHandler)nextOnStateHasLeftApp
                        onModalPushedBlock:(nullable PBMVoidBlock)onModalPushedBlock;

@end
