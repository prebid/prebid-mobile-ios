//
//  MPOpenMeasurementTracker.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPHTTPNetworkSession.h"

#import "MPAnalyticsTracker.h"
#import "MPLogging.h"
#import "MPOpenMeasurementTracker.h"
#import "MPViewabilityManager.h"
#import "MPViewabilityObstruction.h"
#import "MPWebView+Viewability.h"
#import "OMIDAdEvents.h"
#import "OMIDMediaEvents.h"
#import "OMIDAdSession.h"
#import "OMIDAdSessionConfiguration.h"
#import "OMIDAdSessionContext.h"
#import "OMIDFriendlyObstructionType.h"
#import "OMIDVASTProperties.h"

// the custom reference ID may not be relevant to your integration in which case you may pass an
// empty string.
NSString * const kOMIDCustomReferenceId = @"";

@interface MPOpenMeasurementTracker()
@property (nonatomic, strong) UIView *creativeViewToTrack;
@property (nonatomic, strong, nullable) NSMutableSet<UIView<MPViewabilityObstruction> *> *friendlyObstructions;
@property (nonatomic, strong, nullable) NSSet<UIView<MPViewabilityObstruction> *> *friendlyObstructionsToAddOnSessionCreation;
@property (nonatomic, assign) BOOL hasTrackedAdLoadEvent;
@property (nonatomic, assign) BOOL hasTrackedImpressionEvent;
@property (nonatomic, assign, readwrite) BOOL isTracking;
@property (nonatomic, strong) OMIDMopubAdEvents *omidAdEvents;
@property (nonatomic, strong) OMIDMopubAdSessionContext *omidContext;
@property (nonatomic, strong) OMIDMopubMediaEvents *omidMediaEvents;
@property (nonatomic, strong) OMIDMopubAdSession *omidSession;
@property (nonatomic, strong) OMIDMopubAdSessionConfiguration *omidSessionConfiguration;
@property (nonatomic, strong, nullable) OMIDMopubVASTProperties *omidVASTProperties;
@property (nonatomic, strong, nullable) NSArray<NSURL *> *omidNotExecutedTrackers;
@property (nonatomic, weak) MPVideoPlayerView *videoPlayerView;
@end

@implementation MPOpenMeasurementTracker

#pragma mark - Initialization

- (instancetype)initWithWebView:(MPWebView *)webview
                containedInView:(UIView *)containerView
           friendlyObstructions:(NSSet<UIView<MPViewabilityObstruction> *> * _Nullable)obstructions {
    if (self = [super init]) {
        // Viewability is not initialized or disabled, do not create the tracker
        MPViewabilityManager *manager = MPViewabilityManager.sharedManager;
        if (!manager.isInitialized || !manager.isEnabled) {
            return nil;
        }

        // Initial state
        _isTracking = NO;
        _hasTrackedAdLoadEvent = NO;
        _hasTrackedImpressionEvent = NO;
        _videoPlayerView = nil;         // This field does not apply to web content

        // Capture the reference to the view that will be tracked and its
        // friendly obstructions.
        // Do not immediately add `obstructions` to `self.friendlyObstructions` because
        // `createOmidSession` will invoke `addFriendlyObstructions:` which checks `self.friendlyObstructions`
        // before adding.
        _creativeViewToTrack = containerView;
        _friendlyObstructionsToAddOnSessionCreation = obstructions;
        _friendlyObstructions = nil;

        // Defer creating the OM SDK session in order to prevent issues with starting the session later.
        // We must wait until the WebView finishes loading OM SDK JavaScript before creating the `OMIDAdSession`.
        // Creating the session sooner than that may result in an inability to signal events (impression, etc.)
        // to verification scripts inside the WebView.
        // Source: https://interactiveadvertisingbureau.github.io/Open-Measurement-SDKiOS/#3-create-and-configure-the-ad-session-
        //
        _omidSession = nil;
        _omidAdEvents = nil;
        _omidMediaEvents = nil;
        _omidVASTProperties = nil;      // This field does not apply to web content
        _omidNotExecutedTrackers = nil; // This field does not apply to web content

        // First, create a context with a reference to the partner object you created in the setup step and the ad’s WebView.
        NSError *error = nil;
        _omidContext = [[OMIDMopubAdSessionContext alloc] initWithPartner:MPViewabilityManager.sharedManager.omidPartner
                                                                  webView:webview.wkWebView
                                                               contentUrl:nil
                                                customReferenceIdentifier:kOMIDCustomReferenceId
                                                                    error:&error];
        if (error != nil) {
            MPLogEvent([MPLogEvent error:error message:@"Failed to initialize Viewability tracker"]);
            return nil;
        }

        // Then designate which layer is responsible for signaling the impression event.
        // For WebView display ads this is generally the native layer.
        _omidSessionConfiguration = [[OMIDMopubAdSessionConfiguration alloc] initWithCreativeType:OMIDCreativeTypeHtmlDisplay
                                                                                   impressionType:OMIDImpressionTypeBeginToRender
                                                                                  impressionOwner:OMIDNativeOwner
                                                                                 mediaEventsOwner:OMIDNativeOwner
                                                                       isolateVerificationScripts:NO
                                                                                            error:&error];
        if (error != nil) {
            MPLogEvent([MPLogEvent error:error message:@"Failed to initialize Viewability tracker"]);
            return nil;
        }
    }

    return self;
}

- (instancetype)initWithVASTPlayerView:(MPAdContainerView *)videoPlayerContainerView
                           videoConfig:(MPVideoConfig *)videoConfig {
    if (self = [super init]) {
        // Viewability is not initialized or disabled, do not create the tracker
        MPViewabilityManager *manager = MPViewabilityManager.sharedManager;
        if (!manager.isInitialized || !manager.isEnabled) {
            return nil;
        }

        // Initial state
        _isTracking = NO;
        _hasTrackedAdLoadEvent = NO;
        _hasTrackedImpressionEvent = NO;
        _videoPlayerView = videoPlayerContainerView.videoPlayerView;

        // Capture the reference to the view that will be tracked and its
        // friendly obstructions.
        // Do not immediately add `obstructions` to `self.friendlyObstructions` because
        // `createOmidSession` will invoke `addFriendlyObstructions:` which checks `self.friendlyObstructions`
        // before adding.
        _creativeViewToTrack = videoPlayerContainerView;
        _friendlyObstructionsToAddOnSessionCreation = videoPlayerContainerView.friendlyObstructions;
        _friendlyObstructions = nil;

        // Defer creating the OM SDK session in order to prevent issues with starting the session later.
        _omidSession = nil;
        _omidAdEvents = nil;
        _omidMediaEvents = nil;
        _omidNotExecutedTrackers = videoConfig.viewabilityContext.omidNotExecutedTrackers;

        // Generate the VAST properties used for tracking purposes
        if (videoConfig.isRewardExpected) {
            // Locked experience
            _omidVASTProperties = [[OMIDMopubVASTProperties alloc] initWithAutoPlay:YES position:OMIDPositionStandalone];
        }
        else {
            // Skippable experience
            CGFloat skipOffset = [videoConfig.skipOffset timeIntervalForVideoWithDuration:videoPlayerContainerView.videoPlayerView.videoDuration];
            _omidVASTProperties = [[OMIDMopubVASTProperties alloc] initWithSkipOffset:skipOffset autoPlay:YES position:OMIDPositionStandalone];
        }

        // First, create a context with a reference to the partner object you created in the setup step,
        // the OMID JS, and the measurement resources.
        NSError *error = nil;
        _omidContext = [[OMIDMopubAdSessionContext alloc] initWithPartner:MPViewabilityManager.sharedManager.omidPartner
                                                                   script:MPViewabilityManager.sharedManager.omidJsLibrary
                                                                resources:videoConfig.viewabilityContext.omidResources
                                                               contentUrl:nil
                                                customReferenceIdentifier:kOMIDCustomReferenceId
                                                                    error:&error];

        if (error != nil) {
            MPLogEvent([MPLogEvent error:error message:@"Failed to initialize Viewability tracker"]);
            return nil;
        }

        // Then designate which layer is responsible for signaling the impression event.
        _omidSessionConfiguration = [[OMIDMopubAdSessionConfiguration alloc] initWithCreativeType:OMIDCreativeTypeVideo
                                                                                   impressionType:OMIDImpressionTypeBeginToRender
                                                                                  impressionOwner:OMIDNativeOwner
                                                                                 mediaEventsOwner:OMIDNativeOwner
                                                                       isolateVerificationScripts:NO
                                                                                            error:&error];
        if (error != nil) {
            MPLogEvent([MPLogEvent error:error message:@"Failed to initialize Viewability tracker"]);
            return nil;
        }
    }

    return self;
}

- (instancetype)initWithNativeView:(UIView *)view
                    trackerContext:(MPViewabilityContext *)context
              friendlyObstructions:(NSSet<UIView<MPViewabilityObstruction> *> * _Nullable)obstructions {
    if (self = [super init]) {
        // Viewability is not initialized or disabled, do not create the tracker
        MPViewabilityManager *manager = MPViewabilityManager.sharedManager;
        if (!manager.isInitialized || !manager.isEnabled) {
            return nil;
        }

        // Initial state
        _isTracking = NO;
        _hasTrackedAdLoadEvent = NO;
        _hasTrackedImpressionEvent = NO;
        _videoPlayerView = nil;         // This field does not apply to native content

        // Capture the reference to the view that will be tracked and its
        // friendly obstructions.
        // Do not immediately add `obstructions` to `self.friendlyObstructions` because
        // `createOmidSession` will invoke `addFriendlyObstructions:` which checks `self.friendlyObstructions`
        // before adding.
        _creativeViewToTrack = view;
        _friendlyObstructionsToAddOnSessionCreation = obstructions;
        _friendlyObstructions = nil;

        // Defer creating the OM SDK session in order to prevent issues with starting the session later.
        _omidSession = nil;
        _omidAdEvents = nil;
        _omidMediaEvents = nil;
        _omidNotExecutedTrackers = context.omidNotExecutedTrackers;
        _omidVASTProperties = nil;      // This field does not apply to native content

        // First, create a context with a reference to the partner object you created in the setup step,
        // the OMID JS, and the measurement resources.
        NSError *error = nil;
        _omidContext = [[OMIDMopubAdSessionContext alloc] initWithPartner:MPViewabilityManager.sharedManager.omidPartner
                                                                   script:MPViewabilityManager.sharedManager.omidJsLibrary
                                                                resources:context.omidResources
                                                               contentUrl:nil
                                                customReferenceIdentifier:kOMIDCustomReferenceId
                                                                    error:&error];

        if (error != nil) {
            MPLogEvent([MPLogEvent error:error message:@"Failed to initialize Viewability tracker"]);
            return nil;
        }

        // Then designate which layer is responsible for signaling the impression event.
        _omidSessionConfiguration = [[OMIDMopubAdSessionConfiguration alloc] initWithCreativeType:OMIDCreativeTypeNativeDisplay
                                                                                   impressionType:OMIDImpressionTypeBeginToRender
                                                                                  impressionOwner:OMIDNativeOwner
                                                                                 mediaEventsOwner:OMIDNoneOwner
                                                                       isolateVerificationScripts:NO
                                                                                            error:&error];
        if (error != nil) {
            MPLogEvent([MPLogEvent error:error message:@"Failed to initialize Viewability tracker"]);
            return nil;
        }
    }

    return self;
}

- (void)dealloc {
    [self stopTracking];

    // Capture that a Viewability session was valid.
    // We are using the session configuration instead of the session
    // itself since `omidSessionConfiguration` is created at initialization
    // time, whereas `omidSession` is created at `startTracking` time.
    BOOL validViewabilitySession = (_omidSessionConfiguration != nil);

    // Explicit `nil` in case the Open Measurement SDK decides to hang on
    // to references longer than expected.
    _creativeViewToTrack = nil;
    _friendlyObstructionsToAddOnSessionCreation = nil;
    _friendlyObstructions = nil;
    _omidAdEvents = nil;
    _omidMediaEvents = nil;
    _omidContext = nil;
    _omidSessionConfiguration = nil;
    _omidSession = nil;
    _omidVASTProperties = nil;
    _videoPlayerView = nil;

    // Log the deallocation of the Viewability tracker only if
    // the Viewability tracking session was valid. This is to
    // filter out this log message when initialization of this
    // class returned `nil` instead of creating a valid instance.
    if (validViewabilitySession) {
        MPLogEvent([MPLogEvent viewabilityTrackerDeallocated:self]);
    }
}

#pragma mark - Private

/**
 Create and initializes the following Open Measurement objects:
 - omidSession
 - omidAdEvents
 - omidMediaEvents
 */
- (void)createOmidSession {
    // Create the OM SDK tracking session
    NSError *error = nil;
    self.omidSession = [[OMIDMopubAdSession alloc] initWithConfiguration:self.omidSessionConfiguration
                                                        adSessionContext:self.omidContext
                                                                   error:&error];
    if (error != nil) {
        MPLogEvent([MPLogEvent error:error message:@"Failed to initialize OM SDK session"]);
    }

    // Set the view on which to track viewability. For a WebView ad, this will be the WebView itself.
    self.omidSession.mainAdView = self.creativeViewToTrack;

    // If there are any native elements which you would consider to be part of the ad,
    // such as a close button, some logo text, or another decoration, you should register them as friendly
    // obstructions to prevent them from counting towards coverage of the ad.
    // This applies to any ancestor or peer views in the view hierarchy (all sub-views of the adView will
    // be automatically treated as part of the ad)
    [self addFriendlyObstructions:self.friendlyObstructionsToAddOnSessionCreation];
    self.friendlyObstructionsToAddOnSessionCreation = nil;

    // Create the object responsible for notifying OM SDK of ad life cycle events.
    self.omidAdEvents = [[OMIDMopubAdEvents alloc] initWithAdSession:self.omidSession error:&error];
    if (error != nil) {
        MPLogEvent([MPLogEvent error:error message:@"Failed to initialize OM SDK ad events"]);
    }

    // Create the object responsible for notifying OM SDK of media events.
    self.omidMediaEvents = [[OMIDMopubMediaEvents alloc] initWithAdSession:self.omidSession error:&error];
    if (error != nil) {
        MPLogEvent([MPLogEvent error:error message:@"Failed to initialize OM SDK media events"]);
    }
}

/**
 Translates from `MPViewabilityObstructionType` to `OMIDFriendlyObstructionType`.
 */
- (OMIDFriendlyObstructionType)omidObstructionType:(MPViewabilityObstructionType)type {
    switch (type) {
        case MPViewabilityObstructionTypeMediaControls: return OMIDFriendlyObstructionMediaControls;
        case MPViewabilityObstructionTypeClose: return OMIDFriendlyObstructionCloseAd;
        case MPViewabilityObstructionTypeOther: return OMIDFriendlyObstructionOther;
        case MPViewabilityObstructionTypeNotVisible: return OMIDFriendlyObstructionNotVisible;
    }
}

#pragma mark - MPViewabilityTracker

- (void)addFriendlyObstructions:(NSArray<UIView<MPViewabilityObstruction> *> * _Nullable)obstructions {
    // No obstruction to add.
    if (obstructions.count == 0) {
        return;
    }

    // No session to add to.
    if (self.omidSession == nil) {
        return;
    }

    // Sort the obstructions by name so that adding the obstructions will be deterministic
    // for unit testing and UI testing.
    NSArray<UIView<MPViewabilityObstruction> *> *sortedObstructions = [obstructions sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"viewabilityObstructionName" ascending:YES]]];

    [sortedObstructions enumerateObjectsUsingBlock:^(UIView<MPViewabilityObstruction> * _Nonnull obstructionView, NSUInteger idx, BOOL * _Nonnull stop) {
        // Do not add an obstruction that already exists
        if ([self.friendlyObstructions containsObject:obstructionView]) {
            return;
        }

        // Extract relevant information
        OMIDFriendlyObstructionType type = [self omidObstructionType:obstructionView.viewabilityObstructionType];
        NSString *reason = obstructionView.viewabilityObstructionName;

        // Add the obstruction
        NSError *obstructionError = nil;
        [self.omidSession addFriendlyObstruction:obstructionView purpose:type detailedReason:reason error:&obstructionError];
        if (obstructionError != nil) {
            MPLogEvent([MPLogEvent error:obstructionError message:@"Failed to add friendly obstruction"]);
        }
        else {
            // Add the obstruction to the set of known/tracked obstructions
            if (self.friendlyObstructions == nil) {
                self.friendlyObstructions = [NSMutableSet set];
            }
            [self.friendlyObstructions addObject:obstructionView];

            MPLogEvent([MPLogEvent viewabilityTracker:self addedFriendlyObstruction:obstructionView]);
        }
    }];
}

- (void)startTracking {
    @synchronized (self) {
        // Already tracking
        if (self.isTracking) {
            return;
        }

        // Viewability is not initialize or disabled
        MPViewabilityManager *manager = MPViewabilityManager.sharedManager;
        if (!manager.isInitialized || !manager.isEnabled) {
            return;
        }

        // Disallow reusing the tracker
        if (self.omidSession != nil) {
            MPLogWarn(@"Attempted to start a previously tracked Viewability session!");
            return;
        }

        // Create the Open Measurement session and tracking objects before starting
        // the tracking session. This has been defered as late as possible to give
        // the Open Measurement javascript that was injected into the creative HTML
        // time to finish loading in the web view.
        [self createOmidSession];

        // Register notification handler
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(onViewabilityDisabledNotification:)
                                                   name:kDisableViewabilityTrackerNotification
                                                 object:nil];

        // Start the tracking session
        [self.omidSession start];

        // Dispatch out all of the optional resource error trackers now.
        if (self.omidNotExecutedTrackers.count > 0) {
            [MPAnalyticsTracker.sharedTracker sendTrackingRequestForURLs:self.omidNotExecutedTrackers];
        }

        // Set internal state
        self.isTracking = YES;

        MPLogEvent([MPLogEvent viewabilityTrackerSessionStarted:self]);

    } // End synchronized(self)
}

- (void)stopTracking {
    @synchronized (self) {
        // Not tracking, do nothing.
        if (!self.isTracking) {
            return;
        }

        self.isTracking = NO;

        // Remove notification observing
        [NSNotificationCenter.defaultCenter removeObserver:self];

        // Note that ending an OMID ad session sends a message to the verification scripts running inside the webview
        // supplied by the integration. So that the verification scripts have enough time to handle the `sessionFinish` event,
        // the integration must maintain a strong reference to the webview for at least 1.0 seconds after ending the session.
        [self.omidSession finish];

        // DO NOT set `omidSession` to `nil` since it needs to be given time to dispatch out any messages
        // to the webview, and `omidSession` is used to determine if the session has already been created
        // and should not be restarted.

        MPLogEvent([MPLogEvent viewabilityTrackerSessionStopped:self]);

    } // End synchronized(self)
}

- (void)trackAdLoaded {
    @synchronized (self) {
        // Not tracking, do nothing.
        if (!self.isTracking) {
            return;
        }

        if (self.hasTrackedAdLoadEvent) {
            return;
        }

        // Signal to OM SDK that the ad has loaded.
        NSError *error = nil;
        if (self.omidVASTProperties != nil) {
            [self.omidAdEvents loadedWithVastProperties:self.omidVASTProperties error:&error];
        }
        else {
            [self.omidAdEvents loadedWithError:&error];
        }

        if (error != nil) {
            MPLogEvent([MPLogEvent error:error message:@"Failed to signal ad load event to OM SDK"]);
        }

        self.hasTrackedAdLoadEvent = YES;

        MPLogEvent([MPLogEvent viewabilityTrackerTrackedAdLoaded:self]);
    } // End synchronized(self)
}

- (void)trackImpression {
    @synchronized (self) {
        // Not tracking, do nothing.
        if (!self.isTracking) {
            return;
        }

        // Already tracked impression
        if (self.hasTrackedImpressionEvent) {
            return;
        }

        // Signal to OM SDK that an ad impression has occurred.
        NSError *error = nil;
        [self.omidAdEvents impressionOccurredWithError:&error];
        if (error != nil) {
            MPLogEvent([MPLogEvent error:error message:@"Failed to signal ad impression event to OM SDK"]);
        }

        self.hasTrackedImpressionEvent = YES;

        MPLogEvent([MPLogEvent viewabilityTrackerTrackedImpression:self]);
    } // End synchronized(self)
}

- (void)trackVideoEvent:(MPVideoEvent)event {
    @synchronized (self) {
        // Not tracking, do nothing.
        if (!self.isTracking) {
            return;
        }

        // Tracker not initialized for media events. Disregard this tracking event.
        if (self.omidMediaEvents == nil) {
            return;
        }

        // Video playback started
        if ([event isEqualToString:MPVideoEventStart]) {
            NSTimeInterval duration = self.videoPlayerView.videoDuration;
            float volume = self.videoPlayerView.videoVolume;
            [self.omidMediaEvents startWithDuration:duration mediaPlayerVolume:volume];
        }
        // First Quartile
        else if ([event isEqualToString:MPVideoEventFirstQuartile]) {
            [self.omidMediaEvents firstQuartile];
        }
        // Midpoint
        else if ([event isEqualToString:MPVideoEventMidpoint]) {
            [self.omidMediaEvents midpoint];
        }
        // Third Quartile
        else if ([event isEqualToString:MPVideoEventThirdQuartile]) {
            [self.omidMediaEvents thirdQuartile];
        }
        // Video playback complete
        else if ([event isEqualToString:MPVideoEventComplete]) {
            [self.omidMediaEvents complete];
        }
        // Video paused
        else if ([event isEqualToString:MPVideoEventPause]) {
            [self.omidMediaEvents pause];
        }
        // Video resumed
        else if ([event isEqualToString:MPVideoEventResume]) {
            [self.omidMediaEvents resume];
        }
        // Video skipped
        else if ([event isEqualToString:MPVideoEventSkip]) {
            [self.omidMediaEvents skipped];
        }
        // Collapsed
        else if ([event isEqualToString:MPVideoEventCollapse]) {
            [self.omidMediaEvents playerStateChangeTo:OMIDPlayerStateCollapsed];
        }
        // Expanded
        else if ([event isEqualToString:MPVideoEventExpand]) {
            [self.omidMediaEvents playerStateChangeTo:OMIDPlayerStateExpanded];
        }
        // Fullscreen
        else if ([event isEqualToString:MPVideoEventFullScreen]) {
            [self.omidMediaEvents playerStateChangeTo:OMIDPlayerStateFullscreen];
        }
        // Exit fullscreen
        else if ([event isEqualToString:MPVideoEventExitFullScreen]) {
            [self.omidMediaEvents playerStateChangeTo:OMIDPlayerStateNormal];
        }
        // Click
        else if ([event isEqualToString:MPVideoEventClick]) {
            [self.omidMediaEvents adUserInteractionWithType:OMIDInteractionTypeClick];
        }
        // Mute
        else if ([event isEqualToString:MPVideoEventMute]) {
            [self.omidMediaEvents volumeChangeTo:0.0];
        }
        // Unmmute
        else if ([event isEqualToString:MPVideoEventUnmute]) {
            float volume = self.videoPlayerView.videoVolume;
            [self.omidMediaEvents volumeChangeTo:volume];
        }
        // Unsupported
        else {
            // Intentionally return here so that any additional logic afterwards is
            // not executed.
            return;
        }

        MPLogEvent([MPLogEvent viewabilityTracker:self trackedVideoEvent:event]);
    } // End synchronized(self)
}

- (void)updateTrackedView:(UIView *)view {
    @synchronized (self) {
        // Not tracking, do nothing.
        if (!self.isTracking) {
            return;
        }

        // If the view changes at a subsequent time due to a fullscreen expansion or for a similar reason,
        // you should always update the `mainAdView` reference to whatever is appropriate at that time.
        self.creativeViewToTrack = view;
        self.omidSession.mainAdView = self.creativeViewToTrack;

        MPLogEvent([MPLogEvent viewabilityTrackerUpdatedTrackingView:self]);
    } // End synchronized(self)
}

#pragma mark - Notification Handlers

- (void)onViewabilityDisabledNotification:(NSNotification *)notification {
    [self stopTracking];
}

@end
