//
//  PBMMediaData.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMMediaData.h"
#import "PBMMediaData+Internal.h"

@implementation PBMMediaData

- (instancetype)initWithMediaAsset:(PBMNativeAdMarkupAsset *)mediaAsset
                     nativeAdHooks:(PBMNativeAdMediaHooks *)nativeAdHooks
{
    if (!(self = [super init])) {
        return nil;
    }
    _mediaAsset = mediaAsset;
    _nativeAdHooks = nativeAdHooks;
    return self;
}

@end
