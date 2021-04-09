//
//  MPVASTLinearAd.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVASTLinearAd.h"
#import "MPVASTDurationOffset.h"
#import "MPVASTIndustryIcon.h"
#import "MPVASTMediaFile.h"
#import "MPVASTStringUtilities.h"
#import "MPVASTTrackingEvent.h"

@interface MPVASTLinearAd ()

// These properties are listed here as readwrite to allow `MPVideoConfig` to update
// these values in its own private category.
@property (nonatomic, nullable, strong, readwrite) NSArray<NSURL *> *clickTrackingURLs;
@property (nonatomic, nullable, strong, readwrite) NSArray<NSURL *> *customClickURLs;
@property (nonatomic, nullable, strong, readwrite) NSArray<MPVASTIndustryIcon *> *industryIcons;
@property (nonatomic, nullable, strong, readwrite) NSDictionary<MPVideoEvent, NSArray<MPVASTTrackingEvent *> *> *trackingEvents;

@end

@implementation MPVASTLinearAd

#pragma mark - MPVASTModel

- (instancetype _Nullable)initWithDictionary:(NSDictionary<NSString *, id> * _Nullable)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self) {
        // Custom parsing to generate the table of `MPVASTTrackingEvent` from the `TrackingEvents` element and children.
        // In the event of a malformed `TrackingEvents` element, no trackers will be parsed.
        id trackingEventsElement = dictionary[@"TrackingEvents"];
        if (trackingEventsElement != nil && [trackingEventsElement isKindOfClass:[NSDictionary class]]) {
            // Map the elements of TrackingEvents.Tracking into an array of `MPVASTTrackingEvent`.
            NSDictionary *trackingEventsElementDictionary = (NSDictionary *)trackingEventsElement;
            NSArray<MPVASTTrackingEvent *> *trackingEvents = [self generateModelsFromDictionaryValue:trackingEventsElementDictionary[@"Tracking"]
                                                                                       modelProvider:^id(NSDictionary *dictionary) {
                return [[MPVASTTrackingEvent alloc] initWithDictionary:dictionary];
            }];

            // Aggregate trackers that have the same `eventType` into an array in the
            // tracking events table.
            NSMutableDictionary<MPVideoEvent, NSMutableArray<MPVASTTrackingEvent *> *> *eventsDictionary = [NSMutableDictionary dictionary];
            [trackingEvents enumerateObjectsUsingBlock:^(MPVASTTrackingEvent * _Nonnull event, NSUInteger idx, BOOL * _Nonnull stop) {
                // Malformed `Tracking` element: no `event` attribute is present. Do not parse this item.
                MPVideoEvent eventType = event.eventType;
                if (eventType == nil) {
                    return;
                }

                // Create a new array entry if one is not present.
                NSMutableArray<MPVASTTrackingEvent *> *events = [eventsDictionary objectForKey:eventType];
                if (events == nil) {
                    events = [NSMutableArray array];
                    [eventsDictionary setObject:events forKey:eventType];
                }

                // Add the entry
                [events addObject:event];
            }];

            _trackingEvents = eventsDictionary.count > 0 ? eventsDictionary : nil;
        } // End if
    }
    return self;
}

+ (NSDictionary<NSString *, id> *)modelMap {
    return @{@"clickThroughURL":    @[@"VideoClicks.ClickThrough.text", MPParseURLFromString()],
             @"clickTrackingURLs":  @[@"VideoClicks.ClickTracking.text", MPParseArrayOf(MPParseURLFromString())],
             @"customClickURLs":    @[@"VideoClicks.CustomClick.text", MPParseArrayOf(MPParseURLFromString())],
             @"duration":           @[@"Duration.text", MPParseTimeIntervalFromDurationString()],
             @"industryIcons":      @[@"Icons.Icon", MPParseArrayOf(MPParseClass([MPVASTIndustryIcon class]))],
             @"mediaFiles":         @[@"MediaFiles.MediaFile", MPParseArrayOf(MPParseClass([MPVASTMediaFile class]))],
             @"skipOffset":         @[@"@self", MPParseClass([MPVASTDurationOffset class])]};
}

@end
