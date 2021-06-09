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

//Superclass
#import <Foundation/Foundation.h>

//Protocols
#import "PBMCreativeViewDelegate.h"
#import "PBMVoidBlock.h"

//Classes
@class UIView;
@class UIViewController;

@protocol PBMCreativeResolutionDelegate;
@class PBMCreativeModel;
@class PBMInterstitialDisplayProperties;
@class PBMModalManager;
@class PBMModalState;
@class PBMTransaction;
@class PBMEventManager;
@class PBMOpenMeasurementSession;
@class PBMDownloadDataHelper;
@class PBMCreativeViewabilityTracker;
@class PBMViewExposure;

NS_ASSUME_NONNULL_BEGIN

/**
 *  `PBMAbstractCreative`'s purpose is a bundling of a model and a view. It acts as an adapter between
 *  the view and the SDK, it's essentially the C in MVC.
 *
 *  All `Creatives` must conform to this protocol. Each creative has-a model which contains the
 *  creative info, and must implement a few methods for handling display of the creative.
 */
@interface PBMAbstractCreative : NSObject

@property (nonatomic, weak, readonly, nullable) PBMTransaction *transaction;
@property (nonatomic, strong, nullable) PBMCreativeModel *creativeModel;
@property (nonatomic, readonly, nonnull) PBMEventManager *eventManager;
@property (nonatomic, strong, nullable) UIView *view;
@property (nonatomic, assign) BOOL clickthroughVisible;
@property (nonatomic, strong, nullable) PBMModalManager *modalManager;
@property (nonatomic, strong, nonnull) dispatch_queue_t dispatchQueue;
@property (nonatomic, strong, nullable) PBMCreativeViewabilityTracker *viewabilityTracker;
@property (nonatomic, copy, nullable, readonly) PBMVoidBlock dismissInterstitialModalState;
@property BOOL isDownloaded;

// Indicates whether creative is opened with user action (expanded, clickthrough showed ...) or not
// Note that subclasses provide specific implementation.
@property (nonatomic, readonly) BOOL isOpened;

// The time that that the ad is displayed (i.e. before its refreshed).
// Note that subclasses provide specific implementation.
@property (nonatomic, readonly, nullable)NSNumber *displayInterval;

@property (nonatomic, weak, nullable) id<PBMCreativeResolutionDelegate> creativeResolutionDelegate;
@property (nonatomic, weak, nullable) id<PBMCreativeViewDelegate> creativeViewDelegate;
@property (nonatomic, weak, nullable) UIViewController* viewControllerForPresentingModals;

@property (nonatomic, readonly, getter=isMuted) BOOL muted;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCreativeModel:(PBMCreativeModel *)creativeModel
                                  transaction:(PBMTransaction *)transaction NS_DESIGNATED_INITIALIZER;

- (void)setupView;
- (void)displayWithRootViewController:(UIViewController *)viewController;
- (void)showAsInterstitialFromRootViewController:(UIViewController *)viewController displayProperties:(PBMInterstitialDisplayProperties *)displayProperties;
- (void)handleClickthrough:(NSURL *)url;

//Resolution
- (void)onResolutionCompleted;
- (void)onResolutionFailed:(NSError *)error;

//Open Measurement
- (void)createOpenMeasurementSession;

- (void)pause;
- (void)resume;
- (void)mute;
- (void)unmute;

//Modal Manager Events
- (void)modalManagerDidFinishPop:(PBMModalState *)state;
- (void)modalManagerDidLeaveApp:(PBMModalState *)state;

- (void)onViewabilityChanged:(BOOL)viewable viewExposure:(PBMViewExposure *)viewExposure;

@end

NS_ASSUME_NONNULL_END
