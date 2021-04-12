//
//  OXANativeAdMarkupVideo.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXAJsonDecodable.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXANativeAdMarkupVideo : NSObject <OXAJsonDecodable>

/// vast xml.
@property (nonatomic, copy, nullable) NSString *vasttag;

- (instancetype)initWithVastTag:(nullable NSString *)vasttag;

@end

NS_ASSUME_NONNULL_END
