//
//  PBMMoPubRewardedAdUnit.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMMoPubRewardedAdUnit.h"
#import "PBMMoPubInterstitialAdUnit+Protected.h"
#import "PBMMoPubBaseInterstitialAdUnit+Protected.h"

@implementation PBMMoPubBidInfoWrapper
@end

@implementation PBMMoPubRewardedAdUnit

// MARK: - Lifecycle

- (instancetype)initWithConfigId:(NSString *)configId {
    if(!(self = [super initWithConfigId:configId])) {
        return nil;
    }
    self.adUnitConfig.isOptIn = YES;
    self.adUnitConfig.adFormat = PBMAdFormatVideo;
    return self;
}
@end
