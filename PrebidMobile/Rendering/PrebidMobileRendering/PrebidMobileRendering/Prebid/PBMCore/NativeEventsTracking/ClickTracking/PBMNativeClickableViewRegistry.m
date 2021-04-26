//
//  PBMNativeClickableViewRegistry.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import UIKit;

#import "PBMNativeClickableViewRegistry.h"

#import "PBMNativeClickTrackingEntry.h"
#import "PBMMacros.h"

#import "PBMPlayable.h"

@interface PBMNativeClickableViewRegistry ()
@property (nonatomic, strong, nonnull, readonly) PBMNativeClickTrackerBinderFactoryBlock binderFactory;
@property (nonatomic, strong, nonnull, readonly) PBMNativeViewClickHandlerBlock clickHandler;
@property (nonatomic, strong, nonnull, readonly) NSMutableArray<PBMNativeClickTrackingEntry *> *trackingEntries;
@end



@implementation PBMNativeClickableViewRegistry

- (instancetype)initWithBinderFactory:(PBMNativeClickTrackerBinderFactoryBlock)binderFactory
                         clickHandler:(PBMNativeViewClickHandlerBlock)clickHandler
{
    if (!(self = [super init])) {
        return nil;
    }
    _binderFactory = binderFactory;
    _clickHandler = clickHandler;
    _trackingEntries = [[NSMutableArray alloc] init];
    return self;
}

- (void)registerLink:(PBMNativeAdMarkupLink *)link forView:(UIView *)view {
    PBMNativeClickTrackingEntry * const trackingEntry = [self findOrCreateTrackingEntryForView:view];
    trackingEntry.url = link.url;
    trackingEntry.fallback = link.fallback;
    if (link.clicktrackers.count > 0) {
        trackingEntry.clicktrackers = [(trackingEntry.clicktrackers ?: @[]) arrayByAddingObjectsFromArray:link.clicktrackers];
    }
}

- (void)registerParentLink:(PBMNativeAdMarkupLink *)link forView:(UIView *)view {
    PBMNativeClickTrackingEntry * const trackingEntry = [self findOrCreateTrackingEntryForView:view];
    if (trackingEntry.url == nil) {
        trackingEntry.url = link.url;
        trackingEntry.fallback = link.fallback;
    }
    if (link.clicktrackers.count > 0) {
        trackingEntry.clicktrackers = [(trackingEntry.clicktrackers ?: @[]) arrayByAddingObjectsFromArray:link.clicktrackers];
    }
}

// MARK: - Private

- (PBMNativeClickTrackingEntry *)findOrCreateTrackingEntryForView:(UIView *)view {
    for (PBMNativeClickTrackingEntry *nextEntry in self.trackingEntries) {
        if (nextEntry.trackedView == view) {
            return nextEntry;
        }
    }
    
    PBMNativeClickTrackerBinderBlock const clickBinder = self.binderFactory(view);
    @weakify(self);
    PBMNativeClickHandlerBlock const entryClickHandler = ^(PBMNativeClickTrackingEntry *clickTrackingEntry) {
        @strongify(self);
        if (self == nil) {
            return;
        }

        BOOL isPlayable = [view conformsToProtocol:@protocol(PBMPlayable)];
        if (isPlayable) {
            id<PBMPlayable> playable = (id<PBMPlayable>)view;
            [playable autoPause];
        }
        self.clickHandler(clickTrackingEntry.url,
                          clickTrackingEntry.fallback,
                          clickTrackingEntry.clicktrackers,
                          !isPlayable ? nil :
                          ^{
                                id<PBMPlayable> playable = (id<PBMPlayable>)view;
                                if ([playable canAutoResume]) {
                                    [playable resume];
                                }
                            });
    };
    PBMNativeClickTrackingEntry * const newEntry = [[PBMNativeClickTrackingEntry alloc] initWithView:view
                                                                                         clickBinder:clickBinder
                                                                                        clickHandler:entryClickHandler];
    [self.trackingEntries addObject:newEntry];
    return newEntry;
}

@end
