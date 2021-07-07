//
//  MPVASTTrackingEvent.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPVASTModel.h"
#import "MPVideoEvent.h"

NS_ASSUME_NONNULL_BEGIN

@class MPVASTDurationOffset;

/**
 VAST video tracking event.
 */
@interface MPVASTTrackingEvent : MPVASTModel
/**
 Type of video event that is associated with the `URL`.
 */
@property (nonatomic, nullable, copy, readonly) MPVideoEvent eventType;

/**
 Tracking URL.
 */
@property (nonatomic, copy, readonly) NSURL *URL;

/**
 Optional progress offset indicating when the tracking URL should be fired.
 @note This field only applies to `MPVideoEventProgress`; otherwise this will be `nil`.
 */
@property (nonatomic, nullable, readonly) MPVASTDurationOffset *progressOffset;

#pragma mark - Initialization

/**
 Initializes an instance of a VAST video event tracker.
 @param eventType Type of video event that is associated with the `URL`.
 @param url Tracking event URL.
 @param progressOffset Optional progress offset indicating when the tracking URL should be fired. This field only applies to `MPVideoEventProgress`; otherwise this should be `nil`.
 @return A tracker instance if successful; otherwise `nil` in the event the `URL` is invalid.
 */
- (instancetype _Nullable)initWithEventType:(MPVideoEvent)eventType
                                        url:(NSURL *)url
                             progressOffset:(MPVASTDurationOffset * _Nullable)progressOffset;

#pragma mark - Unavailable

// Use the designated initializer instead
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
