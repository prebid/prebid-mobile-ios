//
//  OXANativeAdImpressionReporting.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXANativeAdImpressionReporting.h"

@implementation OXANativeAdImpressionReporting

+ (OXANativeImpressionDetectionHandler)impressionReporterWithEventTrackers:(NSArray<OXANativeAdMarkupEventTracker *> *)eventTrackers
                                                                urlVisitor:(OXATrackingURLVisitorBlock)urlVisitor
                                                          
{
    return ^(OXANativeEventType impressionType) {
        if (eventTrackers.count <= 0) {
            return;
        }
        NSMutableArray <NSString *> * const trackingUrls = [[NSMutableArray alloc] initWithCapacity:eventTrackers.count];
        for (OXANativeAdMarkupEventTracker *nextEventTracker in eventTrackers) {
            if (nextEventTracker.event == impressionType
                && nextEventTracker.method == OXANativeEventTrackingMethod_Img
                && nextEventTracker.url != nil)
            {
                [trackingUrls addObject:nextEventTracker.url];
            }
        }
        urlVisitor(trackingUrls);
    };
}

@end
