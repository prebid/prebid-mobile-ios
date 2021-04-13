//
//  OXAMoPubError.m
//  OpenXApolloMoPubAdapters
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import <PrebidMobileRendering/OXAErrorCode.h>
#import "OXAMoPubConstants.h"

#import "OXAMoPubError.h"

@interface OXAMoPubError ()
@property (nonatomic, class, readonly) NSErrorDomain errorDomain;
@property (nonatomic, class, readonly) NSInteger baseErrorOffset;
@end

@implementation OXAMoPubError

+ (NSErrorDomain)errorDomain {
    return OXAErrorDomain;
}

+ (NSInteger)baseErrorOffset {
    return 9000;
}

+ (NSError *)noLocalCacheID {
    NSString * const errorMessage = [NSString stringWithFormat:@"Failed to find local cache ID (expected in '%@').",
                                     OXA_MOPUB_APOLLO_CREATIVE_FLAG_KEY];
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
