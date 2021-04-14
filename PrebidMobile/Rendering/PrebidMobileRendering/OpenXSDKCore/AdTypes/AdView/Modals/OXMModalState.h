//
//  OXMModalState.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OXMConstants.h"
#import "OXMVoidBlock.h"

@class OXMModalState;

typedef void (^OXMModalStatePopHandler)(OXMModalState * _Nonnull poppedState);
typedef void (^OXMModalStateAppLeavingHandler)(OXMModalState * _Nonnull leavingState);

@class OXMAdConfiguration;
@class OXMInterstitialDisplayProperties;

@interface OXMModalState : NSObject

@property (nonatomic, strong, nullable, readonly) OXMAdConfiguration *adConfiguration;
@property (nonatomic, strong, nullable, readonly) OXMInterstitialDisplayProperties *displayProperties;
@property (nonatomic, strong, nullable, readonly) UIView *view;

@property (nonatomic, copy, nonnull) OXMMRAIDState mraidState;

@property (nonatomic, copy, nullable, readonly) OXMModalStatePopHandler onStatePopFinished;
@property (nonatomic, copy, nullable, readonly) OXMModalStateAppLeavingHandler onStateHasLeftApp;

// Used to transfer delegate function to another object, rather then current delegate for next states pushed on top
// ref: MOBILE-5849
@property (nonatomic, copy, nullable, readonly) OXMModalStatePopHandler nextOnStatePopFinished;
@property (nonatomic, copy, nullable, readonly) OXMModalStateAppLeavingHandler nextOnStateHasLeftApp;

@property (nonatomic, strong, nullable) OXMVoidBlock onModalPushedBlock;

@property (nonatomic, assign, readonly, getter=isRotationEnabled) BOOL rotationEnabled;

- (nonnull instancetype)init NS_UNAVAILABLE;

+ (nonnull instancetype)modalStateWithView:(nonnull UIView *)view
                           adConfiguration:(nullable OXMAdConfiguration *)adConfiguration
                         displayProperties:(nullable OXMInterstitialDisplayProperties *)displayProperties
                        onStatePopFinished:(nullable OXMModalStatePopHandler)onStatePopFinished
                         onStateHasLeftApp:(nullable OXMModalStateAppLeavingHandler)onStateHasLeftApp;


+ (nonnull instancetype)modalStateWithView:(nonnull UIView *)view
                           adConfiguration:(nullable OXMAdConfiguration *)adConfiguration
                         displayProperties:(nullable OXMInterstitialDisplayProperties *)displayProperties
                        onStatePopFinished:(nullable OXMModalStatePopHandler)onStatePopFinished
                         onStateHasLeftApp:(nullable OXMModalStateAppLeavingHandler)onStateHasLeftApp
                    nextOnStatePopFinished:(nullable OXMModalStatePopHandler)nextOnStatePopFinished
                     nextOnStateHasLeftApp:(nullable OXMModalStateAppLeavingHandler)nextOnStateHasLeftApp;


+ (nonnull instancetype)modalStateWithView:(nonnull UIView *)view
                           adConfiguration:(nullable OXMAdConfiguration *)adConfiguration
                         displayProperties:(nullable OXMInterstitialDisplayProperties *)displayProperties
                        onStatePopFinished:(nullable OXMModalStatePopHandler)onStatePopFinished
                         onStateHasLeftApp:(nullable OXMModalStateAppLeavingHandler)onStateHasLeftApp
                        onModalPushedBlock:(nullable OXMVoidBlock)onModalPushedBlock;

+ (nonnull instancetype)modalStateWithView:(nonnull UIView *)view
                           adConfiguration:(nullable OXMAdConfiguration *)adConfiguration
                         displayProperties:(nullable OXMInterstitialDisplayProperties *)displayProperties
                        onStatePopFinished:(nullable OXMModalStatePopHandler)onStatePopFinished
                         onStateHasLeftApp:(nullable OXMModalStateAppLeavingHandler)onStateHasLeftApp
                    nextOnStatePopFinished:(nullable OXMModalStatePopHandler)nextOnStatePopFinished
                     nextOnStateHasLeftApp:(nullable OXMModalStateAppLeavingHandler)nextOnStateHasLeftApp
                        onModalPushedBlock:(nullable OXMVoidBlock)onModalPushedBlock;

@end
