//
//  OXAMoPubRewardedAdUnit.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXAMoPubRewardedAdUnit.h"
#import "OXAMoPubInterstitialAdUnit+Protected.h"
#import "OXAMoPubBaseInterstitialAdUnit+Protected.h"

@implementation OXAMoPubBidInfoWrapper
@end

@implementation OXAMoPubRewardedAdUnit

// MARK: - Lifecycle

- (instancetype)initWithConfigId:(NSString *)configId {
    if(!(self = [super initWithConfigId:configId])) {
        return nil;
    }
    self.adUnitConfig.isOptIn = YES;
    self.adUnitConfig.adFormat = OXAAdFormatVideo;
    return self;
}
@end
