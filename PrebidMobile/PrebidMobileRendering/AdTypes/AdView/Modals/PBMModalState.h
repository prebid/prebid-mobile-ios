/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <UIKit/UIKit.h>
#import "PBMConstants.h"
#import "PBMVoidBlock.h"

@class PBMModalState;
@class AdConfiguration;
@class PBMInterstitialDisplayProperties;

typedef void (^PBMModalStatePopHandler)(PBMModalState * _Nonnull poppedState);
typedef void (^PBMModalStateAppLeavingHandler)(PBMModalState * _Nonnull leavingState);

@interface PBMModalState : NSObject

@property (nonatomic, strong, nullable, readonly) AdConfiguration *adConfiguration;
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
                           adConfiguration:(nullable AdConfiguration *)adConfiguration
                         displayProperties:(nullable PBMInterstitialDisplayProperties *)displayProperties
                        onStatePopFinished:(nullable PBMModalStatePopHandler)onStatePopFinished
                         onStateHasLeftApp:(nullable PBMModalStateAppLeavingHandler)onStateHasLeftApp;


+ (nonnull instancetype)modalStateWithView:(nonnull UIView *)view
                           adConfiguration:(nullable AdConfiguration *)adConfiguration
                         displayProperties:(nullable PBMInterstitialDisplayProperties *)displayProperties
                        onStatePopFinished:(nullable PBMModalStatePopHandler)onStatePopFinished
                         onStateHasLeftApp:(nullable PBMModalStateAppLeavingHandler)onStateHasLeftApp
                    nextOnStatePopFinished:(nullable PBMModalStatePopHandler)nextOnStatePopFinished
                     nextOnStateHasLeftApp:(nullable PBMModalStateAppLeavingHandler)nextOnStateHasLeftApp;


+ (nonnull instancetype)modalStateWithView:(nonnull UIView *)view
                           adConfiguration:(nullable AdConfiguration *)adConfiguration
                         displayProperties:(nullable PBMInterstitialDisplayProperties *)displayProperties
                        onStatePopFinished:(nullable PBMModalStatePopHandler)onStatePopFinished
                         onStateHasLeftApp:(nullable PBMModalStateAppLeavingHandler)onStateHasLeftApp
                        onModalPushedBlock:(nullable PBMVoidBlock)onModalPushedBlock;

+ (nonnull instancetype)modalStateWithView:(nonnull UIView *)view
                           adConfiguration:(nullable AdConfiguration *)adConfiguration
                         displayProperties:(nullable PBMInterstitialDisplayProperties *)displayProperties
                        onStatePopFinished:(nullable PBMModalStatePopHandler)onStatePopFinished
                         onStateHasLeftApp:(nullable PBMModalStateAppLeavingHandler)onStateHasLeftApp
                    nextOnStatePopFinished:(nullable PBMModalStatePopHandler)nextOnStatePopFinished
                     nextOnStateHasLeftApp:(nullable PBMModalStateAppLeavingHandler)nextOnStateHasLeftApp
                        onModalPushedBlock:(nullable PBMVoidBlock)onModalPushedBlock;

@end
