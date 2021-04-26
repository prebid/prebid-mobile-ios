//
//  PBMGAMError.m
//  OpenXApolloGAMEventHandlers
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMGAMError.h"

#import <PrebidMobileRendering/PBMErrorCode.h>
#import "PBMGAMConstants.h"

@interface PBMGAMError ()
@property (nonatomic, class, readonly) NSErrorDomain errorDomain;
@property (nonatomic, class, readonly) NSInteger baseErrorOffset;
@end

@implementation PBMGAMError

+ (NSErrorDomain)errorDomain {
    return PBMErrorDomain;
}

+ (NSInteger)baseErrorOffset {
    return 6000;
}

+ (NSError *)gamClassesNotFound {
    return [NSError errorWithDomain:[self errorDomain]
                               code:[self baseErrorOffset] + 1
                           userInfo:@{NSLocalizedDescriptionKey: @"GoogleMobileAds SDK does not provide the required classes."}];
}

+ (NSError *)noLocalCacheID {
    NSString * const errorMessage = [NSString stringWithFormat:@"Failed to find local cache ID (expected in '%@').",
                                     PREBID_GAM_PREBID_CREATIVE_FLAG_KEY];
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

+ (void)logError:(NSError *)error {
    NSLog(@"[PrebidMobileGAMEventHandlers] ERROR: %@", error.localizedDescription);
}

@end
