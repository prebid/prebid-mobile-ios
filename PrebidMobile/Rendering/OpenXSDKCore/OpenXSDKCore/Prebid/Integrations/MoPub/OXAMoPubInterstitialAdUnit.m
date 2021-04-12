//
//  OXAMoPubInterstitialAdUnit.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXAMoPubInterstitialAdUnit.h"
#import "OXAMoPubInterstitialAdUnit+Protected.h"
#import "OXAMoPubBaseInterstitialAdUnit+Protected.h"

#import "OXAAdUnitConfig.h"
#import "OXABid.h"
#import "OXABidRequester.h"
#import "OXABidResponse.h"
#import "OXAError.h"
#import "OXAMoPubUtils+Private.h"
#import "OXASDKConfiguration.h"
#import "OXMMacros.h"
#import "OXMServerConnection.h"

@interface OXAMoPubInterstitialAdUnit ()

@property (nonatomic, strong, nullable) OXABidRequester *bidRequester;

//This is an MPInterstitialAdController object
//But we can't use it inderectly as don't want to have additional MoPub dependency in the SDK core
@property (nonatomic, weak, nullable) id<OXAMoPubAdObjectProtocol>adObject;

@property (nonatomic, copy, nullable) void (^completion)(OXAFetchDemandResult);

@end

@implementation OXAMoPubInterstitialAdUnit

// MARK: - Lifecycle

- (instancetype)initWithConfigId:(NSString *)configId minSizePerc:(nullable NSValue *)minSizePerc {
    if(!(self = [super initWithConfigId:configId])) {
        return nil;
    }
    self.adUnitConfig.minSizePerc = minSizePerc;
    return self;
}

- (instancetype)initWithConfigId:(NSString *)configId minSizePercentage:(CGSize)minSizePercentage {
    return (self = [self initWithConfigId:configId minSizePerc:@(minSizePercentage)]);
}

- (instancetype)initWithConfigId:(NSString *)configId {
    return (self = [self initWithConfigId:configId minSizePerc:nil]);
}

// MARK: - Computed properties

- (NSString *)configId {
    return self.adUnitConfig.configId;
}

- (OXAAdFormat)adFormat {
    return self.adUnitConfig.adFormat;
}

- (void)setAdFormat:(OXAAdFormat)adFormat {
    self.adUnitConfig.adFormat = adFormat;
}

- (NSArray<NSValue *> *)additionalSizes {
    return self.adUnitConfig.additionalSizes;
}

- (void)setAdditionalSizes:(NSArray<NSValue *> *)additionalSizes {
    self.adUnitConfig.additionalSizes = additionalSizes;
}

@end
