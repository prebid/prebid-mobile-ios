//
//  PBMNativeAdMarkupLink.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMJsonDecodable.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeAdMarkupLink : NSObject <PBMJsonDecodable>

/// Landing URL of the clickable link.
@property (nonatomic, copy, nullable) NSString *url;

/// List of third-party tracker URLs to be fired on click of the URL.
@property (nonatomic, copy, nullable) NSArray<NSString *> *clicktrackers;

/// Fallback URL for deeplink.
/// To be used if the URL given in url is not supported by the device.
@property (nonatomic, copy, nullable) NSString *fallback;

/// This object is a placeholder that may contain custom JSON agreed to by the parties to support flexibility beyond the standard defined in this specification
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *ext;

- (instancetype)initWithUrl:(nullable NSString *)url;

@end

NS_ASSUME_NONNULL_END
