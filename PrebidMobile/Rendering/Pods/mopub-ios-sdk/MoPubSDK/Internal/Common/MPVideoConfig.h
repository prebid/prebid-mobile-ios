//
//  MPVideoConfig.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPVASTCompanionAd.h"
#import "MPVASTResponse.h"
#import "MPViewabilityContext.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Configuration for a VAST video creative.
 */
@interface MPVideoConfig : NSObject

#pragma mark - Video Rendering Properties
/**
 Call to action text to be displayed when playing the VAST video. By default, this value is `kVASTDefaultCallToActionButtonTitle`.
 */
@property (nonatomic, copy, readonly) NSString *callToActionButtonTitle;

/**
 Optional URL to launch when a user taps on the video, specified by the Linear Ad.
 */
@property (nonatomic, nullable, readonly) NSURL *clickThroughURL;

/**
 Indicates that a user is able to click on the VAST video immediately so that they can consume additional content about the advertiser.
 Clicking on the video should launch the `clickThroughURL`. The default value is `NO`
 */
@property (nonatomic, assign) BOOL enableEarlyClickthroughForNonRewardedVideo;

/**
 Optional Industry Icons to display when playing the VAST video.
 */
@property (nonatomic, nullable, readonly) NSArray<MPVASTIndustryIcon *> *industryIcons;

/**
 Indicates that a rewarded is expected once the video completes playback without skipping. The default is `NO`
 */
@property (nonatomic, assign) BOOL isRewardExpected;

/**
 All available video files included with the VAST creative.
 @note: The video files will typically have different resolutions and bitrates. The best one is picked when the ad is loaded (not when receiving the ad response).
 */
@property (nonatomic, nullable, readonly) NSArray<MPVASTMediaFile *> *mediaFiles;

/**
 The minimum amount of time (in seconds) that needs to elapse before the VAST video can be skipped by
 the user. If no skip offset is specified, the VAST video is immediately skippable.
 */
@property (nonatomic, nullable, readonly) MPVASTDurationOffset *skipOffset;

/**
 Viewability context to use with this video asset.
 */
@property (nonatomic, nullable, readonly) MPViewabilityContext *viewabilityContext;

#pragma mark - Initialization

/**
 Initializes the video configuration with a given VAST response.
 @param response VAST response of the creative.
 @param additionalTrackers Additional VAST event trackers that should be merged with the trackers present in the VAST response.
 Note that the only trackers that will be merged are: `MPVideoEventStart`, `MPVideoEventFirstQuartile`, `MPVideoEventMidpoint`, `MPVideoEventThirdQuartile`, and `MPVideoEventComplete`.
 @return Video configuration for the VAST response.
 */
- (instancetype)initWithVASTResponse:(MPVASTResponse * _Nullable)response
                  additionalTrackers:(NSDictionary<MPVideoEvent, NSArray<MPVASTTrackingEvent *> *> * _Nullable)additionalTrackers NS_DESIGNATED_INITIALIZER;

#pragma mark - Event Trackers

/**
 Retrieve the VAST trackers for the given event.
 @param key Tracking event key
 @return An array of trackers for the given `key`. This may be `nil` if the `key` has no trackers.
 */
- (NSArray<MPVASTTrackingEvent *> * _Nullable)trackingEventsForKey:(MPVideoEvent)key;

#pragma mark - Unavailable

// Use the designated initializer instead
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

#pragma mark -

@interface MPVideoConfig (MPVASTCompanionAdProvider) <MPVASTCompanionAdProvider>
@end

NS_ASSUME_NONNULL_END
