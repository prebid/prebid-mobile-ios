//
//  PBMModalState.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMModalState.h"
#import "PBMWebView.h"
#import "PBMMacros.h"

@interface PBMModalState ()

@property (nonatomic, strong, nullable, readwrite) PBMAdConfiguration *adConfiguration;
@property (nonatomic, strong, nullable, readwrite) PBMInterstitialDisplayProperties *displayProperties;
@property (nonatomic, strong, nullable, readwrite) UIView *view;
@property (nonatomic, copy, nullable, readwrite) PBMModalStatePopHandler onStatePopFinished;
@property (nonatomic, copy, nullable, readwrite) PBMModalStateAppLeavingHandler onStateHasLeftApp;
@property (nonatomic, copy, nullable, readwrite) PBMModalStatePopHandler nextOnStatePopFinished;
@property (nonatomic, copy, nullable, readwrite) PBMModalStateAppLeavingHandler nextOnStateHasLeftApp;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

@end

// MARK: -

@implementation PBMModalState

@synthesize mraidState = _mraidState;

#pragma mark - Initialization

+ (nonnull instancetype)modalStateWithView:(nonnull UIView *)view
                           adConfiguration:(nullable PBMAdConfiguration *)adConfiguration
                         displayProperties:(nullable PBMInterstitialDisplayProperties *)displayProperties
                        onStatePopFinished:(nullable PBMModalStatePopHandler)onStatePopFinished
                         onStateHasLeftApp:(nullable PBMModalStateAppLeavingHandler)onStateHasLeftApp
{
    return [self modalStateWithView:view
                    adConfiguration:adConfiguration
                  displayProperties:displayProperties
                 onStatePopFinished:onStatePopFinished
                  onStateHasLeftApp:onStateHasLeftApp
             nextOnStatePopFinished:nil
              nextOnStateHasLeftApp:nil
                 onModalPushedBlock:nil];
}

+ (nonnull instancetype)modalStateWithView:(nonnull UIView *)view
                           adConfiguration:(nullable PBMAdConfiguration *)adConfiguration
                         displayProperties:(nullable PBMInterstitialDisplayProperties *)displayProperties
                        onStatePopFinished:(nullable PBMModalStatePopHandler)onStatePopFinished
                         onStateHasLeftApp:(nullable PBMModalStateAppLeavingHandler)onStateHasLeftApp
                        onModalPushedBlock:(nullable PBMVoidBlock)onModalPushedBlock
{
    return [self modalStateWithView:view
                    adConfiguration:adConfiguration
                  displayProperties:displayProperties
                 onStatePopFinished:onStatePopFinished
                  onStateHasLeftApp:onStateHasLeftApp
             nextOnStatePopFinished:nil
              nextOnStateHasLeftApp:nil
                 onModalPushedBlock:onModalPushedBlock];
}

+ (nonnull instancetype)modalStateWithView:(nonnull UIView *)view
                           adConfiguration:(nullable PBMAdConfiguration *)adConfiguration
                         displayProperties:(nullable PBMInterstitialDisplayProperties *)displayProperties
                        onStatePopFinished:(nullable PBMModalStatePopHandler)onStatePopFinished
                         onStateHasLeftApp:(nullable PBMModalStateAppLeavingHandler)onStateHasLeftApp
                    nextOnStatePopFinished:(nullable PBMModalStatePopHandler)nextOnStatePopFinished
                     nextOnStateHasLeftApp:(nullable PBMModalStateAppLeavingHandler)nextOnStateHasLeftApp
{
    return [self modalStateWithView:view
                    adConfiguration:adConfiguration
                  displayProperties:displayProperties
                 onStatePopFinished:onStatePopFinished
                  onStateHasLeftApp:onStateHasLeftApp
             nextOnStatePopFinished:nextOnStatePopFinished
              nextOnStateHasLeftApp:nextOnStateHasLeftApp
                 onModalPushedBlock:nil];
}

+ (nonnull instancetype)modalStateWithView:(nonnull UIView *)view
                           adConfiguration:(nullable PBMAdConfiguration *)adConfiguration
                         displayProperties:(nullable PBMInterstitialDisplayProperties *)displayProperties
                        onStatePopFinished:(nullable PBMModalStatePopHandler)onStatePopFinished
                         onStateHasLeftApp:(nullable PBMModalStateAppLeavingHandler)onStateHasLeftApp
                    nextOnStatePopFinished:(nullable PBMModalStatePopHandler)nextOnStatePopFinished
                     nextOnStateHasLeftApp:(nullable PBMModalStateAppLeavingHandler)nextOnStateHasLeftApp
                        onModalPushedBlock:(nullable PBMVoidBlock)onModalPushedBlock
{
    PBMModalState * state = [[PBMModalState alloc] init];
    state.view = view;
    state.adConfiguration = adConfiguration;
    state.displayProperties = displayProperties;
    state.onStatePopFinished = [onStatePopFinished copy];
    state.onStateHasLeftApp = [onStateHasLeftApp copy];
    state.nextOnStatePopFinished = [nextOnStatePopFinished copy];
    state.nextOnStateHasLeftApp = [nextOnStateHasLeftApp copy];
    state.onModalPushedBlock = [onModalPushedBlock copy];
    state.mraidState = [PBMMRAIDStateNotEnabled copy];
    return state;
}

- (BOOL)isRotationEnabled {
    BOOL enabled = YES;
    UIView *lastView = [self.view.subviews lastObject];
    if ([lastView isKindOfClass:[PBMWebView class]]) {
        PBMWebView *webView = (PBMWebView *)lastView;
        enabled = webView.rotationEnabled;
    }
    
    return enabled;
}

@end
