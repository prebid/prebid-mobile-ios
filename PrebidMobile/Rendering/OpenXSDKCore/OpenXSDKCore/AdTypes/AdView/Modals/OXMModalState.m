//
//  OXMModalState.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMModalState.h"
#import "OXMWebView.h"
#import "OXMMacros.h"

@interface OXMModalState ()

@property (nonatomic, strong, nullable, readwrite) OXMAdConfiguration *adConfiguration;
@property (nonatomic, strong, nullable, readwrite) OXMInterstitialDisplayProperties *displayProperties;
@property (nonatomic, strong, nullable, readwrite) UIView *view;
@property (nonatomic, copy, nullable, readwrite) OXMModalStatePopHandler onStatePopFinished;
@property (nonatomic, copy, nullable, readwrite) OXMModalStateAppLeavingHandler onStateHasLeftApp;
@property (nonatomic, copy, nullable, readwrite) OXMModalStatePopHandler nextOnStatePopFinished;
@property (nonatomic, copy, nullable, readwrite) OXMModalStateAppLeavingHandler nextOnStateHasLeftApp;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

@end

// MARK: -

@implementation OXMModalState

@synthesize mraidState = _mraidState;

#pragma mark - Initialization

+ (nonnull instancetype)modalStateWithView:(nonnull UIView *)view
                           adConfiguration:(nullable OXMAdConfiguration *)adConfiguration
                         displayProperties:(nullable OXMInterstitialDisplayProperties *)displayProperties
                        onStatePopFinished:(nullable OXMModalStatePopHandler)onStatePopFinished
                         onStateHasLeftApp:(nullable OXMModalStateAppLeavingHandler)onStateHasLeftApp
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
                           adConfiguration:(nullable OXMAdConfiguration *)adConfiguration
                         displayProperties:(nullable OXMInterstitialDisplayProperties *)displayProperties
                        onStatePopFinished:(nullable OXMModalStatePopHandler)onStatePopFinished
                         onStateHasLeftApp:(nullable OXMModalStateAppLeavingHandler)onStateHasLeftApp
                        onModalPushedBlock:(nullable OXMVoidBlock)onModalPushedBlock
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
                           adConfiguration:(nullable OXMAdConfiguration *)adConfiguration
                         displayProperties:(nullable OXMInterstitialDisplayProperties *)displayProperties
                        onStatePopFinished:(nullable OXMModalStatePopHandler)onStatePopFinished
                         onStateHasLeftApp:(nullable OXMModalStateAppLeavingHandler)onStateHasLeftApp
                    nextOnStatePopFinished:(nullable OXMModalStatePopHandler)nextOnStatePopFinished
                     nextOnStateHasLeftApp:(nullable OXMModalStateAppLeavingHandler)nextOnStateHasLeftApp
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
                           adConfiguration:(nullable OXMAdConfiguration *)adConfiguration
                         displayProperties:(nullable OXMInterstitialDisplayProperties *)displayProperties
                        onStatePopFinished:(nullable OXMModalStatePopHandler)onStatePopFinished
                         onStateHasLeftApp:(nullable OXMModalStateAppLeavingHandler)onStateHasLeftApp
                    nextOnStatePopFinished:(nullable OXMModalStatePopHandler)nextOnStatePopFinished
                     nextOnStateHasLeftApp:(nullable OXMModalStateAppLeavingHandler)nextOnStateHasLeftApp
                        onModalPushedBlock:(nullable OXMVoidBlock)onModalPushedBlock
{
    OXMModalState * state = [[OXMModalState alloc] init];
    state.view = view;
    state.adConfiguration = adConfiguration;
    state.displayProperties = displayProperties;
    state.onStatePopFinished = [onStatePopFinished copy];
    state.onStateHasLeftApp = [onStateHasLeftApp copy];
    state.nextOnStatePopFinished = [nextOnStatePopFinished copy];
    state.nextOnStateHasLeftApp = [nextOnStateHasLeftApp copy];
    state.onModalPushedBlock = [onModalPushedBlock copy];
    state.mraidState = [OXMMRAIDStateNotEnabled copy];
    return state;
}

- (BOOL)isRotationEnabled {
    BOOL enabled = YES;
    UIView *lastView = [self.view.subviews lastObject];
    if ([lastView isKindOfClass:[OXMWebView class]]) {
        OXMWebView *webView = (OXMWebView *)lastView;
        enabled = webView.rotationEnabled;
    }
    
    return enabled;
}

@end
