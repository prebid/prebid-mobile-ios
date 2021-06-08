//
//  PBMNativeAdMarkupEventTracker.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMJsonDecodable.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeAdMarkupEventTracker : NSObject <PBMJsonDecodable>

/// Type of event to track.
/// See Event Types table.
@property (nonatomic, assign) NSInteger event;

/// Type of tracking requested.
/// See Event Tracking Methods table.
@property (nonatomic, assign) NSInteger method;

/// The URL of the image or js.
/// Required for image or js, optional for custom.
@property (nonatomic, copy, nullable) NSString *url;

/// To be agreed individually with the exchange, an array of key:value objects for custom tracking,
/// for example the account number of the DSP with a tracking company. IE {“accountnumber”:”123”}.
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *customdata;

/// This object is a placeholder that may contain custom JSON agreed to by the parties to support flexibility beyond the standard defined in this specification
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *ext;

- (instancetype)initWithEvent:(NSInteger)event
                       method:(NSInteger) method
                          url:(NSString *)url;

@end

NS_ASSUME_NONNULL_END

