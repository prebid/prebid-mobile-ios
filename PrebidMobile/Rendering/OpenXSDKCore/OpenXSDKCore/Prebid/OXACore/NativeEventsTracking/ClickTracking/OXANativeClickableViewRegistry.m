//
//  OXANativeClickableViewRegistry.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import UIKit;

#import "OXANativeClickableViewRegistry.h"

#import "OXANativeClickTrackingEntry.h"
#import "OXMMacros.h"

#import "OXAPlayable.h"

@interface OXANativeClickableViewRegistry ()
@property (nonatomic, strong, nonnull, readonly) OXANativeClickTrackerBinderFactoryBlock binderFactory;
@property (nonatomic, strong, nonnull, readonly) OXANativeViewClickHandlerBlock clickHandler;
@property (nonatomic, strong, nonnull, readonly) NSMutableArray<OXANativeClickTrackingEntry *> *trackingEntries;
@end



@implementation OXANativeClickableViewRegistry

- (instancetype)initWithBinderFactory:(OXANativeClickTrackerBinderFactoryBlock)binderFactory
                         clickHandler:(OXANativeViewClickHandlerBlock)clickHandler
{
    if (!(self = [super init])) {
        return nil;
    }
    _binderFactory = binderFactory;
    _clickHandler = clickHandler;
    _trackingEntries = [[NSMutableArray alloc] init];
    return self;
}

- (void)registerLink:(OXANativeAdMarkupLink *)link forView:(UIView *)view {
    OXANativeClickTrackingEntry * const trackingEntry = [self findOrCreateTrackingEntryForView:view];
    trackingEntry.url = link.url;
    trackingEntry.fallback = link.fallback;
    if (link.clicktrackers.count > 0) {
        trackingEntry.clicktrackers = [(trackingEntry.clicktrackers ?: @[]) arrayByAddingObjectsFromArray:link.clicktrackers];
    }
}

- (void)registerParentLink:(OXANativeAdMarkupLink *)link forView:(UIView *)view {
    OXANativeClickTrackingEntry * const trackingEntry = [self findOrCreateTrackingEntryForView:view];
    if (trackingEntry.url == nil) {
        trackingEntry.url = link.url;
        trackingEntry.fallback = link.fallback;
    }
    if (link.clicktrackers.count > 0) {
        trackingEntry.clicktrackers = [(trackingEntry.clicktrackers ?: @[]) arrayByAddingObjectsFromArray:link.clicktrackers];
    }
}

// MARK: - Private

- (OXANativeClickTrackingEntry *)findOrCreateTrackingEntryForView:(UIView *)view {
    for (OXANativeClickTrackingEntry *nextEntry in self.trackingEntries) {
        if (nextEntry.trackedView == view) {
            return nextEntry;
        }
    }
    
    OXANativeClickTrackerBinderBlock const clickBinder = self.binderFactory(view);
    @weakify(self);
    OXANativeClickHandlerBlock const entryClickHandler = ^(OXANativeClickTrackingEntry *clickTrackingEntry) {
        @strongify(self);
        if (self == nil) {
            return;
        }

        BOOL isPlayable = [view conformsToProtocol:@protocol(OXAPlayable)];
        if (isPlayable) {
            id<OXAPlayable> playable = (id<OXAPlayable>)view;
            [playable autoPause];
        }
        self.clickHandler(clickTrackingEntry.url,
                          clickTrackingEntry.fallback,
                          clickTrackingEntry.clicktrackers,
                          !isPlayable ? nil :
                          ^{
                                id<OXAPlayable> playable = (id<OXAPlayable>)view;
                                if ([playable canAutoResume]) {
                                    [playable resume];
                                }
                            });
    };
    OXANativeClickTrackingEntry * const newEntry = [[OXANativeClickTrackingEntry alloc] initWithView:view
                                                                                         clickBinder:clickBinder
                                                                                        clickHandler:entryClickHandler];
    [self.trackingEntries addObject:newEntry];
    return newEntry;
}

@end
