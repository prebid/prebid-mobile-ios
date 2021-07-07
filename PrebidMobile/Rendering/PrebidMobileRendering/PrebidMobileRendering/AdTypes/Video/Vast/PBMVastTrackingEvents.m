/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "PBMVastTrackingEvents.h"

@interface PBMVastTrackingEvents()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSArray<NSString *> *> *trackingEvents;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *progressOffsets;

@end

#pragma mark - Implementation

@implementation PBMVastTrackingEvents

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

- (void)addTrackingEvents:(nonnull PBMVastTrackingEvents *)events {
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
