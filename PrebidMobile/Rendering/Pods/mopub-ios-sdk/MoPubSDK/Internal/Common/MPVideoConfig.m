//
//  MPVideoConfig.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVideoConfig.h"
#import "MPLogging.h"
#import "MPVASTStringUtilities.h"
#import "MPVASTCompanionAd.h"
#import "MPVASTConstant.h"
#import "MPVASTTracking.h"

// MoPub extensions have type `MoPub`
static NSString *const kMoPubExtensionType = @"MoPub";

/**
 This is a private data object that represents an ad candidate for display.
 */
@interface MPVideoPlaybackCandidate : NSObject

@property (nonatomic, strong) MPVASTLinearAd *linearAd;
@property (nonatomic, strong) NSArray<NSURL *> *errorURLs;
@property (nonatomic, strong) NSArray<NSURL *> *impressionURLs;
@property (nonatomic, strong) MPVASTDurationOffset *skipOffset;
@property (nonatomic, strong) NSString *callToActionButtonTitle;
@property (nonatomic, strong) NSArray<MPVASTCompanionAd *> *companionAds;
@property (nonatomic, strong) MPViewabilityContext *viewabilityContext;

@end

@implementation MPVideoPlaybackCandidate
@end // this data object should have empty implementation

#pragma mark -

/**
 Category to provide write access to select `MPVASTLinearAd` properties. This is used by
 `playbackCandidatesFromVASTResponse:` during the Wrapper merging process.
 */
@interface MPVASTLinearAd (MPVideoConfig)

@property (nonatomic, nullable, strong, readwrite) NSArray<NSURL *> *clickTrackingURLs;
@property (nonatomic, nullable, strong, readwrite) NSArray<NSURL *> *customClickURLs;
@property (nonatomic, nullable, strong, readwrite) NSArray<MPVASTIndustryIcon *> *industryIcons;
@property (nonatomic, nullable, strong, readwrite) NSDictionary<MPVideoEvent, NSArray<MPVASTTrackingEvent *> *> *trackingEvents;

@end

#pragma mark -

@interface MPVideoConfig ()
/**
 Companion ads to be shown once the video has completed playback or is skipped.
 */
@property (nonatomic, strong) NSArray<MPVASTCompanionAd *> *companionAds;

/**
 The minimum amount of time (in seconds) that needs to elapse before the VAST video can be skipped by
 the user. If no skip offset is specified, the VAST video is immediately skippable.
*/
@property (nonatomic, strong) MPVASTDurationOffset *skipOffset;

/**
 VAST video Event trackers for the Linear playback candidate.
 */
@property (nonatomic, strong) NSDictionary<MPVideoEvent, NSArray<MPVASTTrackingEvent *> *> *trackingEventTable;
@property (nonatomic, strong) MPViewabilityContext *viewabilityContext;
@end

@implementation MPVideoConfig

#pragma mark - Initialization

- (instancetype)initWithVASTResponse:(MPVASTResponse * _Nullable)response
                  additionalTrackers:(NSDictionary<MPVideoEvent, NSArray<MPVASTTrackingEvent *> *> * _Nullable)additionalTrackers {
    if (self = [super init]) {
        [self commonInit:response additionalTrackers:additionalTrackers];
    }
    return self;
}

- (void)commonInit:(MPVASTResponse * _Nullable)response
additionalTrackers:(NSDictionary<MPVideoEvent, NSArray<MPVASTTrackingEvent *> *> * _Nullable)additionalTrackers {
    // No response, don't continue further.
    if (response == nil) {
        MPLogWarn(@"No VAST response specified");
        return;
    }

    // Find all of the Linear ad candidates in the VAST response, and choose the first one
    // since MoPub currently does not support Ad Pods.
    NSArray<MPVideoPlaybackCandidate *> *candidates = [self playbackCandidatesFromVASTResponse:response];
    MPVideoPlaybackCandidate *candidate = candidates.firstObject;
    if (candidate == nil) {
        MPLogWarn(@"VAST response contained no Linear ads");
        return;
    }

    // obtain from linear ad
    _mediaFiles = candidate.linearAd.mediaFiles;
    _clickThroughURL = candidate.linearAd.clickThroughURL;
    _industryIcons = candidate.linearAd.industryIcons;

    _skipOffset = candidate.skipOffset;
    _companionAds = candidate.companionAds;
    _viewabilityContext = candidate.viewabilityContext;

    if (candidate.callToActionButtonTitle.length > 0) {
        _callToActionButtonTitle = candidate.callToActionButtonTitle;
    } else {
        _callToActionButtonTitle = kVASTDefaultCallToActionButtonTitle;
    }

    // Setup event tracker table
    self.trackingEventTable = [self trackingEventsFromCandidate:candidate additionalTrackers:additionalTrackers];
}

#pragma mark - Properties

- (MPVASTDurationOffset * _Nullable)skipOffset {
    // If the video is rewarded, do not use the skip offset for countdown timer purposes
    if (self.isRewardExpected) {
        return nil;
    } else {
        return _skipOffset;
    }
}

#pragma mark - Playback Candidates

/**
 Aggregates all of the Linear ads in the VAST response, which are candidates for playback.
 @param response VAST response to parse.
 @return An array of playback candidates, or an empty array if none are found.
 @note This method performs infix recursion.
 */
- (NSArray<MPVideoPlaybackCandidate *> *)playbackCandidatesFromVASTResponse:(MPVASTResponse *)response {
    // Result
    NSMutableArray<MPVideoPlaybackCandidate *> *candidates = [NSMutableArray array];

    for (MPVASTAd *ad in response.ads) {
        // BASE CASE: Inline ads do not require further recursive unwrapping and merging.
        if (ad.inlineAd != nil) {
            MPVASTInline *inlineAd = ad.inlineAd;
            MPVideoPlaybackCandidate *candidate = [[MPVideoPlaybackCandidate alloc] init];
            candidate.callToActionButtonTitle = [self moPubExtensionFromInlineAd:inlineAd forKey:kVASTMoPubCTATextKey][kVASTAdTextKey];
            candidate.viewabilityContext = [[MPViewabilityContext alloc] initWithAdVerificationsXML:ad.inlineAd.adVerifications];

            for (MPVASTCreative *creative in inlineAd.creatives) {
                if (creative.linearAd && [creative.linearAd.mediaFiles count]) {
                    candidate.linearAd = creative.linearAd;
                    candidate.skipOffset = creative.linearAd.skipOffset;
                    candidate.errorURLs = inlineAd.errorURLs;
                    candidate.impressionURLs = inlineAd.impressionURLs;
                    [candidates addObject:candidate];
                } else if (creative.companionAds.count > 0) {
                    NSMutableArray<MPVASTCompanionAd *> *companionAds = [NSMutableArray new];
                    for (MPVASTCompanionAd *companionAd in creative.companionAds) {
                        if (companionAd.resourceToDisplay != nil) { // cannot display ad without any resource
                            [companionAds addObject:companionAd];
                        }
                    }
                    candidate.companionAds = [NSArray arrayWithArray:companionAds];
                }
            }
        }
        // RECURSIVE CASE: Wrapper ads require the wrapper contents to be merged with the resulting
        // Inline ad candidates.
        else if (ad.wrapper != nil) {
            NSArray<MPVideoPlaybackCandidate *> *candidatesFromWrapper = [self playbackCandidatesFromVASTResponse:ad.wrapper.wrappedVASTResponse];

            // Merge any wrapper-level tracking URLs into each of the candidates.
            for (MPVideoPlaybackCandidate *candidate in candidatesFromWrapper) {
                // Merge error URLs
                candidate.errorURLs = ({
                    NSArray<NSURL *> *candidateErrorURLs = candidate.errorURLs ?: @[];
                    NSArray<NSURL *> *wrapperErrorURLs = ad.wrapper.errorURLs ?: @[];
                    NSArray<NSURL *> *mergedErrorURLs = [candidateErrorURLs arrayByAddingObjectsFromArray:wrapperErrorURLs];

                    // Set the merged error URLs if there are any, otherwise `nil`.
                    mergedErrorURLs.count > 0 ? mergedErrorURLs : nil;
                });

                // Merge impression URLs
                candidate.impressionURLs = ({
                    NSArray<NSURL *> *candidateImpressionURLs = candidate.impressionURLs ?: @[];
                    NSArray<NSURL *> *wrapperImpressionURLs = ad.wrapper.impressionURLs ?: @[];
                    NSArray<NSURL *> *mergedImpressionURLs = [candidateImpressionURLs arrayByAddingObjectsFromArray:wrapperImpressionURLs];

                    // Set the merged impression URLs if there are any, otherwise `nil`.
                    mergedImpressionURLs.count > 0 ? mergedImpressionURLs : nil;
                });

                // Merge tracking events
                candidate.linearAd.trackingEvents = ({
                    NSDictionary<MPVideoEvent, NSArray<MPVASTTrackingEvent *> *> *linearTrackingEvents = candidate.linearAd.trackingEvents ?: @{};
                    NSDictionary<MPVideoEvent, NSArray<MPVASTTrackingEvent *> *> *wrapperTrackingEvents = [self trackingEventsFromWrapper:ad.wrapper];
                    NSDictionary<MPVideoEvent, NSArray<MPVASTTrackingEvent *> *> *mergedTrackingEvents = [self dictionaryByMergingTrackingDictionaries:@[linearTrackingEvents, wrapperTrackingEvents]];

                    // Set the merged trackers if there are any, otherwise `nil`.
                    mergedTrackingEvents.count > 0 ? mergedTrackingEvents : nil;
                });

                // Merge click trackers
                candidate.linearAd.clickTrackingURLs = ({
                    NSArray<NSURL *> *linearClickTrackingUrls = candidate.linearAd.clickTrackingURLs ?: @[];
                    NSArray<NSURL *> *wrapperClickTrackingUrls = [self clickTrackingURLsFromWrapper:ad.wrapper];
                    NSArray<NSURL *> *mergedClickTrackingUrls = [linearClickTrackingUrls arrayByAddingObjectsFromArray:wrapperClickTrackingUrls];

                    // Set the merged click trackers if there are any, otherwise `nil`.
                    mergedClickTrackingUrls.count > 0 ? mergedClickTrackingUrls : nil;
                });

                // Merge custom click URLs
                candidate.linearAd.customClickURLs = ({
                    NSArray<NSURL *> *linearCustomClickUrls = candidate.linearAd.customClickURLs ?: @[];
                    NSArray<NSURL *> *wrapperCustomClickUrls = [self customClickURLsFromWrapper:ad.wrapper];
                    NSArray<NSURL *> *mergedCustomClickUrls = [linearCustomClickUrls arrayByAddingObjectsFromArray:wrapperCustomClickUrls];

                    // Set the merged custom click URLs if there are any, otherwise `nil`.
                    mergedCustomClickUrls.count > 0 ? mergedCustomClickUrls : nil;
                });

                // Merge industry icons
                candidate.linearAd.industryIcons = ({
                    NSArray<MPVASTIndustryIcon *> *linearIndustryIcons = candidate.linearAd.industryIcons ?: @[];
                    NSArray<MPVASTIndustryIcon *> *wrapperIndustryIcons = [self industryIconsFromWrapper:ad.wrapper];
                    NSArray<MPVASTIndustryIcon *> *mergedIndustryIcons = [linearIndustryIcons arrayByAddingObjectsFromArray:wrapperIndustryIcons];

                    // Set the merged industry icons if there are any, otherwise `nil`.
                    mergedIndustryIcons.count > 0 ? mergedIndustryIcons : nil;
                });

                // Merge Viewability resources
                [candidate.viewabilityContext addAdVerificationsXML:ad.wrapper.adVerifications];
            } // end for

            [candidates addObjectsFromArray:candidatesFromWrapper];
        }
    }

    return candidates;
}

#pragma mark - Event Trackers

- (NSArray<MPVASTTrackingEvent *> * _Nullable)trackingEventsForKey:(MPVideoEvent)key {
    return self.trackingEventTable[key];
}

/**
 Generates an event tracker table from the specified video playback candidate and table of additional trackers.
 @param candidate Linear ad playback candidate.
 @param additionalTrackers Additional trackers to include in the playback candidate's trackers.
 @return An event tracker table. Note that this table can be empty.
 */
- (NSDictionary<MPVideoEvent, NSArray<MPVASTTrackingEvent *> *> *)trackingEventsFromCandidate:(MPVideoPlaybackCandidate *)candidate
                                                                           additionalTrackers:(NSDictionary<MPVideoEvent, NSArray<MPVASTTrackingEvent *> *> * _Nullable)additionalTrackers {
    // Results
    NSMutableDictionary<MPVideoEvent, NSArray<MPVASTTrackingEvent *> *> *eventTable = [NSMutableDictionary dictionary];

    // Candidate already has tracking events, merge them.
    NSDictionary<MPVideoEvent, NSArray<MPVASTTrackingEvent *> *> *candidateTrackingEvents = candidate.linearAd.trackingEvents;
    if (candidateTrackingEvents != nil) {
        [eventTable addEntriesFromDictionary:candidateTrackingEvents];
    }

    // Merge the quartile trackers from the additional trackers with the existing
    // set of quartile trackers.
    for (MPVideoEvent name in @[MPVideoEventStart,
                                MPVideoEventFirstQuartile,
                                MPVideoEventMidpoint,
                                MPVideoEventThirdQuartile,
                                MPVideoEventComplete]) {
        eventTable[name] = [self mergeTrackersOfName:name sourceTrackers:eventTable additionalTrackers:additionalTrackers];
    }

    // Add Click, Error, and Impression tracking URLs
    NSMutableDictionary<MPVideoEvent, NSArray<NSURL *> *> *eventVsURLs = [NSMutableDictionary new];
    if (candidate.linearAd.clickTrackingURLs.count > 0) {
        eventVsURLs[MPVideoEventClick] = candidate.linearAd.clickTrackingURLs;
    }
    if (candidate.errorURLs.count > 0) {
        eventVsURLs[MPVideoEventError] = candidate.errorURLs;
    }
    if (candidate.impressionURLs.count > 0) {
        eventVsURLs[MPVideoEventImpression] = candidate.impressionURLs;
    }

    [eventVsURLs enumerateKeysAndObjectsUsingBlock:^(MPVideoEvent _Nonnull event, NSArray<NSURL *> * _Nonnull urls, BOOL * _Nonnull stop) {
        NSMutableArray<MPVASTTrackingEvent *> *trackingEvents = [NSMutableArray new];
        [urls enumerateObjectsUsingBlock:^(NSURL * _Nonnull url, NSUInteger idx, BOOL * _Nonnull stop) {
            MPVASTTrackingEvent *trackingEvent = [[MPVASTTrackingEvent alloc] initWithEventType:event url:url progressOffset:nil];
            if (trackingEvent != nil) {
                [trackingEvents addObject:trackingEvent];
            }
        }];

        // Set the tracking event table entry.
        eventTable[event] = trackingEvents;
    }];

    return eventTable;
}

/**
 Merges the specified trackers from the source table with the additional trackers table.
 @param trackerName Tracking event to merge.
 @param sourceTrackers Source trackers table.
 @param additionalTrackers Additional trackers table.
 @return The merged trackers or an empty array if there were no trackers to merge.
 */
- (NSArray<MPVASTTrackingEvent *> *)mergeTrackersOfName:(MPVideoEvent)trackerName
                                         sourceTrackers:(NSDictionary<NSString *, NSArray<MPVASTTrackingEvent *> *> * _Nullable)sourceTrackers
                                     additionalTrackers:(NSDictionary<NSString *, NSArray<MPVASTTrackingEvent *> *> * _Nullable)additionalTrackers {
    // Ensure that the working set of original trackers is non-nil and
    // is a valid array.
    NSArray<MPVASTTrackingEvent *> *source = sourceTrackers[trackerName];
    if (source == nil || [source isKindOfClass:[NSArray class]] == false) {
        source = @[];
    }

    // Validate that there are additional trackers for the specified `trackerName`
    // and that they are an array. Otherwise, there is no need to perform a merge.
    NSArray<MPVASTTrackingEvent *> *additional = additionalTrackers[trackerName];
    if (additional == nil || [additional isKindOfClass:[NSArray class]] == false) {
        return source;
    }

    // Merge the trackers
    return [source arrayByAddingObjectsFromArray:additional];
}

- (NSDictionary *)dictionaryByMergingTrackingDictionaries:(NSArray *)dictionaries {
    NSMutableDictionary *mergedDictionary = [NSMutableDictionary dictionary];
    for (NSDictionary *dictionary in dictionaries) {
        for (NSString *key in [dictionary allKeys]) {
            if ([dictionary[key] isKindOfClass:[NSArray class]]) {
                if (!mergedDictionary[key]) {
                    mergedDictionary[key] = [NSMutableArray array];
                }

                [mergedDictionary[key] addObjectsFromArray:dictionary[key]];
            } else {
                MPLogInfo(@"TrackingEvents dictionary expected an array object for key '%@' "
                           @"but got an instance of %@ instead.",
                           key, NSStringFromClass([dictionary[key] class]));
            }
        }
    }
    return mergedDictionary;
}

#pragma mark - Wrapper Extraction

/**
 Retrieves the merged set of tracking events across all Linear creatives in the Wrapper.
 @param wrapper VAST Wrapper object to extract the tracking event information.
 @return The merged tracking event table, or an empty dictionary.
 */
- (NSDictionary<MPVideoEvent, NSArray<MPVASTTrackingEvent *> *> *)trackingEventsFromWrapper:(MPVASTWrapper * _Nullable)wrapper {
    // Result
    NSMutableArray *trackingEventDictionaries = [NSMutableArray array];

    // No wrapper, give back an empty dictionary.
    if (wrapper == nil) {
        return @{};
    }

    for (MPVASTCreative *creative in wrapper.creatives) {
        // It's possible for the `linearAd` and `trackingEvents` to be `nil`, so check before adding to avoid crashing.
        NSDictionary<MPVideoEvent, NSArray<MPVASTTrackingEvent *> *> *trackingEvents = creative.linearAd.trackingEvents;
        if (trackingEvents != nil) {
            [trackingEventDictionaries addObject:trackingEvents];
        }
    }

    return [self dictionaryByMergingTrackingDictionaries:trackingEventDictionaries];
}

/**
 Retrieves all of the Click tracking URLs across all Linear creatives in the Wrapper.
 @param wrapper VAST Wrapper object to extract the click tracking URLs.
 @return An array of all Click tracking URLs, or empty.
 */
- (NSArray<NSURL *> *)clickTrackingURLsFromWrapper:(MPVASTWrapper * _Nullable)wrapper {
    // Result
    NSMutableArray<NSURL *> *clickTrackingURLs = [NSMutableArray array];

    // No wrapper, give back an empty array.
    if (wrapper == nil) {
        return clickTrackingURLs;
    }

    for (MPVASTCreative *creative in wrapper.creatives) {
        NSArray<NSURL *> *urls = creative.linearAd.clickTrackingURLs;
        if (urls != nil) {
            [clickTrackingURLs addObjectsFromArray:urls];
        }
    }

    return clickTrackingURLs;
}

/**
 Retrieves all of the Custom Click URLs across all Linear creatives in the Wrapper.
 @param wrapper VAST Wrapper object to extract the custom click URLs.
 @return An array of all Custom Click URLs, or empty.
*/
- (NSArray<NSURL *> *)customClickURLsFromWrapper:(MPVASTWrapper * _Nullable)wrapper {
    // Result
    NSMutableArray<NSURL *> *customClickURLs = [NSMutableArray array];

    // No wrapper, give back an empty array.
    if (wrapper == nil) {
        return customClickURLs;
    }

    for (MPVASTCreative *creative in wrapper.creatives) {
        NSArray<NSURL *> *urls = creative.linearAd.customClickURLs;
        if (urls != nil) {
            [customClickURLs addObjectsFromArray:urls];
        }
    }

    return customClickURLs;
}

/**
 Retrieves all of the Industry Icons across all Linear creatives in the Wrapper.
 @param wrapper VAST Wrapper object to extract the Industry Icons.
 @return An array of all Industry Icons, or empty.
*/
- (NSArray<MPVASTIndustryIcon *> *)industryIconsFromWrapper:(MPVASTWrapper * _Nullable)wrapper {
    // Result
    NSMutableArray<MPVASTIndustryIcon *> *industryIcons = [NSMutableArray array];

    // No wrapper, give back an empty array.
    if (wrapper == nil) {
        return industryIcons;
    }

    for (MPVASTCreative *creative in wrapper.creatives) {
        NSArray<MPVASTIndustryIcon *> *icons = creative.linearAd.industryIcons;
        if (icons != nil) {
            [industryIcons addObjectsFromArray:icons];
        }
    }

    return industryIcons;
}

#pragma mark - MoPub Extension

/**
 Retrieves the specified MoPub Extension value from an Inline element.
 @param inlineAd The Inline ad to fetch the MoPub extension from.
 @param key The MoPub extension name.
 @return A dictionary of key-value pairs that was associated with the MoPub Extension; otherwise `nil`.
 */
- (NSDictionary * _Nullable)moPubExtensionFromInlineAd:(MPVASTInline * _Nullable)inlineAd forKey:(NSString *)key {
    // No Inline ad.
    if (inlineAd == nil) {
        return nil;
    }

    // Search through all of the extension nodes, looking for `type == MoPub`
    for (id node in inlineAd.extensions) {
        if (![node isKindOfClass:[NSDictionary class]]) {
            continue;
        }

        NSDictionary *nodeDictionary = (NSDictionary *)node;
        NSString *type = nodeDictionary[@"type"];
        id extension = [self firstObjectForKey:key inDictionary:nodeDictionary];

        // Found the extension
        if ([type isEqualToString:kMoPubExtensionType] &&
            [extension isKindOfClass:[NSDictionary class]] &&
            extension != nil) {
            return extension;
        }
    };

    return nil;
}

// When dealing with VAST, we will often have dictionaries where a key can map either to a single
// value or an array of values. For example, the dictionary containing VAST extensions might contain
// one or more <Extension> nodes. This method is useful when we simply want the first value matching
// a given key. It is equivalent to calling [dictionary objectForKey:key] when the key maps to a
// single value. When the key maps to an NSArray, it returns the first value in the array.
- (id)firstObjectForKey:(NSString *)key inDictionary:(NSDictionary *)dictionary {
    id value = [dictionary objectForKey:key];
    if ([value isKindOfClass:[NSArray class]]) {
        return [value firstObject];
    } else {
        return value;
    }
}

@end

#pragma mark - MPVASTCompanionAdProvider

@implementation MPVideoConfig (MPVASTCompanionAdProvider)

- (BOOL)hasCompanionAd {
    return self.companionAds.count > 0;
}

- (MPVASTCompanionAd *)companionAdForContainerSize:(CGSize)containerSize {
    return [MPVASTCompanionAd bestCompanionAdForCandidates:self.companionAds
                                             containerSize:containerSize];
}

@end
