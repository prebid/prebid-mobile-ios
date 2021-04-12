//
//  OXMAbstractCreative.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

//Superclass
#import <Foundation/Foundation.h>

//Protocols
#import "OXMCreativeViewDelegate.h"
#import "OXMVoidBlock.h"

//Classes
@protocol OXMCreativeResolutionDelegate;

@class UIView;
@class UIViewController;
@class OXMCreativeModel;
@class OXMInterstitialDisplayProperties;
@class OXMModalManager;
@class OXMModalState;
@class OXMTransaction;
@class OXMEventManager;
@class OXMOpenMeasurementSession;
@class OXMDownloadDataHelper;
@class OXMCreativeViewabilityTracker;
@class OXMViewExposure;

NS_ASSUME_NONNULL_BEGIN

/**
 *  `OXMAbstractCreative`'s purpose is a bundling of a model and a view. It acts as an adapter between
 *  the view and the SDK, it's essentially the C in MVC.
 *
 *  All `Creatives` must conform to this protocol. Each creative has-a model which contains the
 *  creative info, and must implement a few methods for handling display of the creative.
 */
@interface OXMAbstractCreative : NSObject

@property (nonatomic, weak, readonly, nullable) OXMTransaction *transaction;
@property (nonatomic, strong, nullable) OXMCreativeModel *creativeModel;
@property (nonatomic, readonly, nonnull) OXMEventManager *eventManager;
@property (nonatomic, strong, nullable) UIView *view;
@property (nonatomic, assign) BOOL clickthroughVisible;
@property (nonatomic, strong, nullable) OXMModalManager *modalManager;
@property (nonatomic, strong, nonnull) dispatch_queue_t dispatchQueue;
@property (nonatomic, strong, nullable) OXMCreativeViewabilityTracker *viewabilityTracker;
@property (nonatomic, copy, nullable, readonly) OXMVoidBlock dismissInterstitialModalState;
@property BOOL isDownloaded;

// Indicates whether creative is opened with user action (expanded, clickthrough showed ...) or not
// Note that subclasses provide specific implementation.
@property (nonatomic, readonly) BOOL isOpened;

// The time that that the ad is displayed (i.e. before its refreshed).
// Note that subclasses provide specific implementation.
@property (nonatomic, readonly, nullable)NSNumber *displayInterval;

@property (nonatomic, weak, nullable) id<OXMCreativeResolutionDelegate> creativeResolutionDelegate;
@property (nonatomic, weak, nullable) id<OXMCreativeViewDelegate> creativeViewDelegate;
@property (nonatomic, weak, nullable) UIViewController* viewControllerForPresentingModals;

@property (nonatomic, readonly, getter=isMuted) BOOL muted;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCreativeModel:(OXMCreativeModel *)creativeModel
                                  transaction:(OXMTransaction *)transaction NS_DESIGNATED_INITIALIZER;

- (void)setupView;
- (void)displayWithRootViewController:(UIViewController *)viewController;
- (void)showAsInterstitialFromRootViewController:(UIViewController *)viewController displayProperties:(OXMInterstitialDisplayProperties *)displayProperties;
- (void)handleClickthrough:(NSURL *)url;
- (void)updateLegalButtonDecorator;

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
- (void)modalManagerDidFinishPop:(OXMModalState *)state;
- (void)modalManagerDidLeaveApp:(OXMModalState *)state;

- (void)onViewabilityChanged:(BOOL)viewable viewExposure:(OXMViewExposure *)viewExposure;

@end

NS_ASSUME_NONNULL_END
