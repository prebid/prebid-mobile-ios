//
//  MPVASTCompanionAd.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVASTCompanionAd.h"
#import "MPVASTResource.h"
#import "MPVASTStringUtilities.h"
#import "MPVASTTrackingEvent.h"
#import "MPVASTTracking.h"

@interface MPVASTCompanionAd ()

/** Per VAST 3.0 spec 2.3.3.2 Companion Resource Elements:
 Companion resource types are described below:
 • StaticResource: Describes non-html creative where an attribute for creativeType is used to
    identify the creative resource platform. The video player uses the creativeType information to
    determine how to display the resource:
    o Image/gif,image/jpeg,image/png:displayedusingtheHTMLtag<img>andthe resource URI as the src attribute.
    o Application/x-javascript:displayedusingtheHTMLtag<script>andtheresource URI as the src attribute.
 • IFrameResource: Describes a resource that is an HTML page that can be displayed within an
    Iframe on the publisher’s page.
 • HTMLResource: Describes a “snippet” of HTML code to be inserted directly within the publisher’s
    HTML page code.
 */
@property (nonatomic, nullable, strong, readonly) NSArray<MPVASTResource *> *HTMLResources;
@property (nonatomic, nullable, strong, readonly) NSArray<MPVASTResource *> *iframeResources;
@property (nonatomic, nullable, strong, readonly) NSArray<MPVASTResource *> *staticResources;

@end

@implementation MPVASTCompanionAd

#pragma mark - MPVASTModel

- (instancetype _Nullable)initWithDictionary:(NSDictionary<NSString *, id> * _Nullable)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self) {
        // Custom parsing to generate the array of `MPVideoEventCreativeView` trackers from
        // the `TrackingEvents` element and children.
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

            // We only care about the `MPVideoEventCreativeView` event. In the event
            // that there isn't an entry, `_creativeViewTrackers` will be set to `nil`.
            _creativeViewTrackers = eventsDictionary[MPVideoEventCreativeView];
        } // End if
    }
    return self;
}

+ (NSDictionary<NSString *, id> *)modelMap {
    return @{@"assetHeight":        @[@"assetHeight", MPParseNumberFromString(NSNumberFormatterDecimalStyle)],
             @"assetWidth":         @[@"assetWidth", MPParseNumberFromString(NSNumberFormatterDecimalStyle)],
             @"height":             @[@"height", MPParseNumberFromString(NSNumberFormatterDecimalStyle)],
             @"width":              @[@"width", MPParseNumberFromString(NSNumberFormatterDecimalStyle)],
             @"clickThroughURL":    @[@"CompanionClickThrough.text", MPParseURLFromString()],
             @"clickTrackingURLs":  @[@"CompanionClickTracking.text", MPParseArrayOf(MPParseURLFromString())],
             @"viewTrackingURLs":   @[@"IconViewTracking.text", MPParseArrayOf(MPParseURLFromString())],
             @"identifier":         @"id",
             @"HTMLResources":      @[@"HTMLResource", MPParseArrayOf(MPParseClass([MPVASTResource class]))],
             @"iframeResources":    @[@"IFrameResource", MPParseArrayOf(MPParseClass([MPVASTResource class]))],
             @"staticResources":    @[@"StaticResource", MPParseArrayOf(MPParseClass([MPVASTResource class]))],
             @"apiFramework":       @"apiFramework"
    };
}

#pragma mark - Companion Ad Display and Selection

- (CGRect)safeAdViewBounds {
    return CGRectMake(0, 0, MAX(1, self.width), MAX(1, self.height));
}

- (MPVASTResource * _Nullable)resourceToDisplay {
    // format score = 1, display priority = A
    for (MPVASTResource *resource in self.staticResources) {
        if (resource.content.length > 0) {
            if (resource.isStaticCreativeTypeJavaScript) {
                resource.type = MPVASTResourceType_StaticScript;
                return resource;
            }
        }
    }

    // format score = 1, display priority = B
    for (MPVASTResource *resource in self.HTMLResources) {
        if (resource.content.length > 0) {
            resource.type = MPVASTResourceType_HTML;
            return resource;
        }
    }

    // format score = 1, display priority = C
    for (MPVASTResource *resource in self.iframeResources) {
        if (resource.content.length > 0) {
            resource.type = MPVASTResourceType_Iframe;
            return resource;
        }
    }

    // format score = 0.8, display priority = D
    for (MPVASTResource *resource in self.staticResources) {
        if (resource.content.length > 0) {
            if (resource.isStaticCreativeTypeImage) {
                resource.type = MPVASTResourceType_StaticImage;
                return resource;
            }
        }
    }

    return nil;
}

+ (MPVASTCompanionAd * _Nullable)bestCompanionAdForCandidates:(NSArray<MPVASTCompanionAd *> *)candidates
                                      containerSize:(CGSize)containerSize {
    if (candidates.count == 0 || containerSize.width <= 0 || containerSize.height <= 0) {
        return nil;
    }

    CGFloat highestScore = CGFLOAT_MIN;
    MPVASTCompanionAd *result;

    // It is possible that none of the candidate fits into the screen perfectly, but we will pick the
    // best one and then aspect fit it
    for (MPVASTCompanionAd *candidate in candidates) {
        if (candidate.resourceToDisplay != nil) {
            CGFloat score = [candidate selectionScoreForContainerSize:containerSize];
            if (highestScore < score) {
                highestScore = score;
                result = candidate;
            }
        }
    }

    return result;
}

#pragma mark - Private

- (BOOL)hasStaticImageResource {
    for (MPVASTResource *resource in self.staticResources) {
        if (resource.content.length > 0 && resource.isStaticCreativeTypeImage) {
            return YES;
        }
    }

    return NO;
}

/// Note: Static image resource is not considered as a web markup (HTML) resource.
- (BOOL)hasWebMarkupResource {
    for (MPVASTResource *resource in self.staticResources) {
        if (resource.content.length > 0 && resource.isStaticCreativeTypeJavaScript) {
            return YES;
        }
    }

    for (MPVASTResource *resource in self.iframeResources) {
        if (resource.content.length > 0) {
            return YES;
        }
    }

    for (MPVASTResource *resource in self.HTMLResources) {
        if (resource.content.length > 0) {
            return YES;
        }
    }

    return NO;
}

- (CGFloat)formatScore {
    if (self.hasWebMarkupResource) {
        return 1;
    }
    else if (self.hasStaticImageResource) {
        return 0.8;
    }
    else {
        return 0; // Flash resource or unknown resource
    }
}

/**
 See scoring algorithm documentation at http://go/adf-vast-video-selection.
 */
- (CGFloat)selectionScoreForContainerSize:(CGSize)containerSize {
    if (self.width == 0 || self.height == 0) {
        return 0;
    }

    CGFloat aspectRatioScore = ABS(containerSize.width / containerSize.height - self.width / self.height);
    CGFloat widthScore = ABS((containerSize.width - self.width) / containerSize.width);
    CGFloat fitScore = aspectRatioScore + widthScore;
    return self.formatScore / (1 + fitScore);
}

@end
