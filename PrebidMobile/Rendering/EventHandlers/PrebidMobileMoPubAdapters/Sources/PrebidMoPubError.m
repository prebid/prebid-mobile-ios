//
//  PBMMoPubError.m
//  OpenXApolloMoPubAdapters
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import <PrebidMobileRendering/PBMErrorCode.h>
#import "PrebidMoPubConstants.h"

#import "PrebidMoPubError.h"

@interface PrebidMoPubError ()
@property (nonatomic, class, readonly) NSErrorDomain errorDomain;
@property (nonatomic, class, readonly) NSInteger baseErrorOffset;
@end

@implementation PrebidMoPubError

+ (NSErrorDomain)errorDomain {
    return PBMErrorDomain;
}

+ (NSInteger)baseErrorOffset {
    return 9000;
}

+ (NSError *)noLocalCacheID {
    NSString * const errorMessage = [NSString stringWithFormat:@"Failed to find local cache ID (expected in '%@').",
                                     PREBID_MOPUB_PREBID_CREATIVE_FLAG_KEY];
    return [NSError errorWithDomain:[self errorDomain]
                               code:[self baseErrorOffset] + 2
                           userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
}

+ (NSError *)invalidLocalCacheID {
    return [NSError errorWithDomain:[self errorDomain]
                               code:[self baseErrorOffset] + 3
                           userInfo:@{NSLocalizedDescriptionKey: @"Invalid local cache ID or the Ad already expired."}];
}

+ (NSError *)invalidNativeAd {
    return [NSError errorWithDomain:[self errorDomain]
                               code:[self baseErrorOffset] + 4
                           userInfo:@{NSLocalizedDescriptionKey: @"Failed to load Native Ad from cached bid response."}];
}

@end
