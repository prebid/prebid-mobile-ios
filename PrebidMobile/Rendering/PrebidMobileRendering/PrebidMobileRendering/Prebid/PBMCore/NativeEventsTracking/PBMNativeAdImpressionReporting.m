//
//  PBMNativeAdImpressionReporting.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMNativeAdImpressionReporting.h"

@implementation PBMNativeAdImpressionReporting

+ (PBMNativeImpressionDetectionHandler)impressionReporterWithEventTrackers:(NSArray<PBMNativeAdMarkupEventTracker *> *)eventTrackers
                                                                urlVisitor:(PBMTrackingURLVisitorBlock)urlVisitor
                                                          
{
    return ^(PBMNativeEventType impressionType) {
        if (eventTrackers.count <= 0) {
            return;
        }
        NSMutableArray <NSString *> * const trackingUrls = [[NSMutableArray alloc] initWithCapacity:eventTrackers.count];
        for (PBMNativeAdMarkupEventTracker *nextEventTracker in eventTrackers) {
            if (nextEventTracker.event == impressionType
                && nextEventTracker.method == PBMNativeEventTrackingMethod_Img
                && nextEventTracker.url != nil)
            {
                [trackingUrls addObject:nextEventTracker.url];
            }
        }
        urlVisitor(trackingUrls);
    };
}

@end
