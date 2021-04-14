//
//  OXANativeAdEventTracker.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeEventTrackingMethod.h"
#import "OXANativeEventType.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXANativeAdEventTracker : NSObject

/// Type of event to track.
/// See Event Types table.
@property (nonatomic, assign, readonly) OXANativeEventType event;

/// Type of tracking requested.
/// See Event Tracking Methods table.
@property (nonatomic, assign, readonly) OXANativeEventTrackingMethod method;

/// The URL of the image or js.
/// Required for image or js, optional for custom.
@property (nonatomic, strong, nullable, readonly) NSString *url;

/// To be agreed individually with the exchange, an array of key:value objects for custom tracking,
/// for example the account number of the DSP with a tracking company. IE {“accountnumber”:”123”}.
@property (nonatomic, strong, nullable, readonly) NSDictionary<NSString *, id> *customdata;

/// This object is a placeholder that may contain custom JSON agreed to by the parties to support flexibility beyond the standard defined in this specification
@property (nonatomic, strong, nullable, readonly) NSDictionary<NSString *, id> *ext;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
