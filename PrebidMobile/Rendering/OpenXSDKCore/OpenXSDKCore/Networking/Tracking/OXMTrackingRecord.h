//
//  OXMTrackingRecord.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

// This is public so that it will work with NativeAdCreative

NS_SWIFT_NAME(TrackingRecord)
@interface OXMTrackingRecord : NSObject

@property (nonatomic, copy, nonnull) NSString *trackingType;
@property (nonatomic, copy, nonnull) NSString *trackingURL;

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithTrackingType:(nonnull NSString *)trackingType trackingURL:(nonnull NSString *)trackingURL NS_DESIGNATED_INITIALIZER;

@end
