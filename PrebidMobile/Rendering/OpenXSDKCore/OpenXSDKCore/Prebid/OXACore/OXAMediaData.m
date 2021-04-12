//
//  OXAMediaData.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAMediaData.h"
#import "OXAMediaData+Internal.h"

@implementation OXAMediaData

- (instancetype)initWithMediaAsset:(OXANativeAdMarkupAsset *)mediaAsset
                     nativeAdHooks:(OXANativeAdMediaHooks *)nativeAdHooks
{
    if (!(self = [super init])) {
        return nil;
    }
    _mediaAsset = mediaAsset;
    _nativeAdHooks = nativeAdHooks;
    return self;
}

@end
