//
//  OXANativeEventTracker.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXANativeEventTrackingMethod.h"
#import "OXANativeEventType.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXANativeEventTracker : NSObject

/// [Required]
/// Type of event available for tracking.
@property (nonatomic, assign) OXANativeEventType event;

/// [Required]
/// Array of the types of tracking available for the given event.
/// See OXANativeEventTrackingMethod
@property (nonatomic, copy) NSArray<NSNumber *> *methods;

/// This object is a placeholder that may contain custom JSON agreed to by the parties to support flexibility beyond the standard defined in this specification
@property (nonatomic, copy, nullable, readonly) NSDictionary<NSString *, id> *ext;
- (BOOL)setExt:(nullable NSDictionary<NSString *, id> *)ext
         error:(NSError * _Nullable __autoreleasing * _Nullable)error;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithEvent:(OXANativeEventType)event methods:(NSArray<NSNumber *> *)methods NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
