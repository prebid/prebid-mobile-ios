//
//  OXMVastTrackingEvents.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMVastTrackingEvents.h"

@interface OXMVastTrackingEvents()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSArray<NSString *> *> *trackingEvents;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *progressOffsets;

@end

#pragma mark - Implementation

@implementation OXMVastTrackingEvents

#pragma mark - Initialization

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        self.trackingEvents = [NSMutableDictionary new];
        self.progressOffsets = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark - Public

- (void)addTrackingURL:(nullable NSString *)url
                 event:(nullable NSString *)event
            attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes {
    if (!url || !event) {
        return;
    }
    
    NSMutableArray *existingURLSForEvent = [self.trackingEvents[event] mutableCopy];
    if (existingURLSForEvent) {
        [existingURLSForEvent addObject:url];
        _trackingEvents[event] = existingURLSForEvent;
    } else {
        _trackingEvents[event] = @[url];
    }
    
    // if it is a progress event add the offset attribute to progressOffsets
    // TODO: the progress events need to be sorted by offset it is not required for them to be listed in chronological order
    if ([event isEqualToString:@"progress"] && attributes) {
        
        NSString *strOffset = attributes[@"offset"];
        NSTimeInterval offset = 0.0;
        BOOL isIntegerValue = [[NSScanner scannerWithString:strOffset] scanDouble:&offset];

        [_progressOffsets addObject:(isIntegerValue ? @(offset) : @0)];
    }
}

- (nullable NSArray<NSString *> *)trackingURLsForEvent:(nonnull NSString *)event {
    return event ? self.trackingEvents[event] : @[];
}

- (void)addTrackingEvents:(nonnull OXMVastTrackingEvents *)events {
    if (!events) {
        return;
    }
    
    for (NSString *event in events.trackingEvents.allKeys) {
        if (!event) {
            continue;
        }
        
        NSArray *urlArray = events.trackingEvents[event];
        for (NSString *url in urlArray) {
            [self addTrackingURL:url event:event attributes:nil];
        }
    }
}

@end
