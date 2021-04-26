//
//  PBMVastTrackingEvents.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBMVastTrackingEvents : NSObject

@property (nonatomic, readonly, nonnull) NSDictionary<NSString *, NSArray<NSString *> *> *trackingEvents;
@property (nonatomic, readonly, nonnull) NSArray<NSNumber *> *progressOffsets;

- (nonnull instancetype)init;

- (void)addTrackingURL:(nullable NSString *)url
                 event:(nullable NSString *)event
            attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;

- (nullable NSArray<NSString *> *)trackingURLsForEvent:(nonnull NSString *)event;

- (void)addTrackingEvents:(nonnull PBMVastTrackingEvents *)events;

@end
