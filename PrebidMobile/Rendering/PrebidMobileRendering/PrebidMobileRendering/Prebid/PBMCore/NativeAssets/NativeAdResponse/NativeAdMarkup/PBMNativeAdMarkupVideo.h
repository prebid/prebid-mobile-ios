//
//  PBMNativeAdMarkupVideo.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMJsonDecodable.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeAdMarkupVideo : NSObject <PBMJsonDecodable>

/// vast xml.
@property (nonatomic, copy, nullable) NSString *vasttag;

- (instancetype)initWithVastTag:(nullable NSString *)vasttag;

@end

NS_ASSUME_NONNULL_END
