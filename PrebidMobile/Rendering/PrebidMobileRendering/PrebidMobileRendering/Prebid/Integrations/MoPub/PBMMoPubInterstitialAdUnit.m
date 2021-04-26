//
//  PBMMoPubInterstitialAdUnit.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMMoPubInterstitialAdUnit.h"
#import "PBMMoPubInterstitialAdUnit+Protected.h"
#import "PBMMoPubBaseInterstitialAdUnit+Protected.h"

#import "PBMAdUnitConfig.h"
#import "PBMBid.h"
#import "PBMBidRequester.h"
#import "PBMBidResponse.h"
#import "PBMError.h"
#import "PBMMoPubUtils+Private.h"
#import "PBMSDKConfiguration.h"
#import "PBMMacros.h"
#import "PBMServerConnection.h"

@interface PBMMoPubInterstitialAdUnit ()

@property (nonatomic, strong, nullable) PBMBidRequester *bidRequester;

//This is an MPInterstitialAdController object
//But we can't use it inderectly as don't want to have additional MoPub dependency in the SDK core
@property (nonatomic, weak, nullable) id<PBMMoPubAdObjectProtocol>adObject;

@property (nonatomic, copy, nullable) void (^completion)(PBMFetchDemandResult);

@end

@implementation PBMMoPubInterstitialAdUnit

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

- (PBMAdFormat)adFormat {
    return self.adUnitConfig.adFormat;
}

- (void)setAdFormat:(PBMAdFormat)adFormat {
    self.adUnitConfig.adFormat = adFormat;
}

- (NSArray<NSValue *> *)additionalSizes {
    return self.adUnitConfig.additionalSizes;
}

- (void)setAdditionalSizes:(NSArray<NSValue *> *)additionalSizes {
    self.adUnitConfig.additionalSizes = additionalSizes;
}

@end
