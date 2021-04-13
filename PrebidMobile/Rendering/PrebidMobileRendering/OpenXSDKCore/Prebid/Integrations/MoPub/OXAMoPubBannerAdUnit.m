//
//  OXAMoPubBannerAdUnit.m
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import "UIView+OxmExtensions.h"

#import "OXAMoPubBannerAdUnit.h"
#import "OXAMoPubBannerAdUnit+InternalState.h"

#import "OXAAdUnitConfig+Internal.h"
#import "OXABid.h"
#import "OXABidResponse.h"
#import "OXABidRequester.h"
#import "OXABidResponse.h"
#import "OXABid.h"
#import "OXAError.h"
#import "OXAMoPubUtils+Private.h"
#import "OXASDKConfiguration.h"
#import "OXATargeting.h"
#import "OXMServerConnection.h"
#import "OXMAutoRefreshManager.h"

#import "OXMMacros.h"

@interface OXAMoPubBannerAdUnit ()

@property (nonatomic, strong, nullable) OXABidRequester *bidRequester;
//This is an MPAdView object
//But we can't use it inderectly as don't want to have additional MoPub dependency in the SDK core
@property (nonatomic, weak, nullable) id<OXAMoPubAdObjectProtocol> adObject;
@property (nonatomic, copy, nullable) void (^completion)(OXAFetchDemandResult);

@property (nonatomic, weak, nullable) id<OXAMoPubAdObjectProtocol> lastAdObject;
@property (nonatomic, copy, nullable) void (^lastCompletion)(OXAFetchDemandResult);

@property (atomic, assign) BOOL isRefreshStopped;
@property (nonatomic, strong, nonnull, readonly) OXMAutoRefreshManager *autoRefreshManager;

@property (nonatomic, copy, nullable) NSError *adRequestError;

@end


@implementation OXAMoPubBannerAdUnit

// MARK: - Lifecycle

- (instancetype)initWithConfigId:(NSString *)configId size:(CGSize)size {
    if(!(self = [super init])) {
        return nil;
    }
    
    _adUnitConfig = [[OXAAdUnitConfig alloc] initWithConfigId:configId size:size];
    
    @weakify(self);
    _autoRefreshManager = [[OXMAutoRefreshManager alloc] initWithPrefetchTime:OXAAdPrefetchTime
                                                                 lockingQueue:nil
                                                                 lockProvider:nil
                                                            refreshDelayBlock:^NSNumber * _Nullable{
        @strongify(self);
        return @(self.adUnitConfig.refreshInterval);
    } mayRefreshNowBlock:^BOOL{
        @strongify(self);
        return [self isAdObjectVisible] || self.adRequestError;
    } refreshBlock:^{
        @strongify(self);
        if (self.lastAdObject && self.lastCompletion) {
            [self fetchDemandWithObject:self.lastAdObject
                             connection:[OXMServerConnection singleton]
                       sdkConfiguration:[OXASDKConfiguration singleton]
                              targeting:[OXATargeting shared]
                             completion:self.lastCompletion];
        }
    }];
    
    return self;
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

- (void)setAdPosition:(OXAAdPosition)adPosition {
    self.adUnitConfig.adPosition = adPosition;
}

- (OXAAdPosition)adPosition {
    return self.adUnitConfig.adPosition;
}

- (OXAVideoPlacementType)videoPlacementType {
    return self.adUnitConfig.videoPlacementType;
}

- (void)setVideoPlacementType:(OXAVideoPlacementType)videoPlacementType {
    self.adUnitConfig.videoPlacementType = videoPlacementType;
}

- (OXANativeAdConfiguration *)nativeAdConfig {
    return self.adUnitConfig.nativeAdConfig;
}

- (void)setNativeAdConfig:(OXANativeAdConfiguration *)nativeAdConfig {
    self.adUnitConfig.nativeAdConfig = nativeAdConfig;
}

- (NSTimeInterval)refreshInterval {
    return self.adUnitConfig.refreshInterval;
}

- (void)setRefreshInterval:(NSTimeInterval)refreshInterval {
    self.adUnitConfig.refreshInterval = refreshInterval;
}

- (NSArray<NSValue *> *)additionalSizes {
    return self.adUnitConfig.additionalSizes;
}

- (void)setAdditionalSizes:(NSArray<NSValue *> *)additionalSizes {
    self.adUnitConfig.additionalSizes = additionalSizes;
}

// MARK: - Public Methods
- (void)fetchDemandWithObject:(NSObject *)adObject completion:(void (^)(OXAFetchDemandResult))completion {
    self.isRefreshStopped = NO;
    [self fetchDemandWithObject:adObject
                     connection:[OXMServerConnection singleton]
               sdkConfiguration:[OXASDKConfiguration singleton]
                      targeting:[OXATargeting shared]
                     completion:completion];
}

- (void)fetchDemandWithObject:(NSObject *)adObject
                   connection:(id<OXMServerConnectionProtocol>)connection
             sdkConfiguration:(OXASDKConfiguration *)sdkConfiguration
                    targeting:(OXATargeting *)targeting
                   completion:(void (^)(OXAFetchDemandResult))completion
{
    if (self.bidRequester) {
        return; // Request in progress
    }
    
    if (![OXAMoPubUtils isCorrectAdObject:adObject]) {
        if (completion) {
            completion(OXAFetchDemandResult_WrongArguments);
        }
        return;
    }
    
    [self.autoRefreshManager cancelRefreshTimer];
    
    if (self.isRefreshStopped) {
        return;
    }
    
    self.adObject = (id<OXAMoPubAdObjectProtocol>)adObject;
    self.completion = completion;
    
    self.lastAdObject = nil;
    self.lastCompletion = nil;
    self.adRequestError = nil;
    
    [OXAMoPubUtils cleanUpAdObject:self.adObject];
    
    self.bidRequester = [[OXABidRequester alloc] initWithConnection:connection
                                                   sdkConfiguration:sdkConfiguration
                                                          targeting:targeting
                                                adUnitConfiguration:self.adUnitConfig];
    @weakify(self);
    [self.bidRequester requestBidsWithCompletion:^(OXABidResponse *response, NSError *error) {
        @strongify(self);
        if (!self) {
            return;
        }
        
        if (self.isRefreshStopped) {
            [self markLoadingFinished];
            return;
        }
        
        if (response && !error) {
            [self handlePrebidResponse:response];
        } else {
            [self handlePrebidError:error];
        }
    }];
}

- (void)stopRefresh {
    self.isRefreshStopped = YES;
}

- (void)adObject:(NSObject *)adObject didFailToLoadAdWithError:(NSError *)error {
    if (adObject == self.adObject || adObject == self.lastAdObject) {
        self.adRequestError = error;
    }
}

// MARK: - Context Data

- (void)addContextData:(NSString *)data forKey:(NSString *)key {
    [self.adUnitConfig addContextData:data forKey:key];
}

- (void)updateContextData:(NSSet<NSString *> *)data forKey:(NSString *)key {
    [self.adUnitConfig updateContextData:data forKey:key];
}

- (void)removeContextDataForKey:(NSString *)key {
    [self.adUnitConfig removeContextDataForKey:key];
}

- (void)clearContextData {
    [self.adUnitConfig clearContextData];
}

// MARK: - Private Methods

- (void)handlePrebidResponse:(nullable OXABidResponse *)response {
    OXAFetchDemandResult demandResult = OXAFetchDemandResult_DemandNoBids;
    if (response.winningBid) {
        if ([OXAMoPubUtils setUpAdObject:self.adObject
                                 withConfigId:self.configId
                           targetingInfo:response.winningBid.targetingInfo
                             extraObject:response.winningBid forKey:OXAMoPubAdUnitBidKey]) {
            demandResult = OXAFetchDemandResult_Ok;
        } else {
            demandResult =OXAFetchDemandResult_WrongArguments;
        }
    } else {
        OXMLogError(@"The winning bid is absent in response!");
    }
    [self completeWithResult:demandResult];
}

- (void)handlePrebidError:(NSError *)error {
    [self completeWithResult:([OXAError demandResultFromError:error] ?: OXAFetchDemandResult_InternalSDKError)];
}

- (void)completeWithResult:(OXAFetchDemandResult)demandResult {
    void (^ const completion)(OXAFetchDemandResult) = self.completion;
    const id<OXAMoPubAdObjectProtocol> adObject = self.adObject;
    
    [self markLoadingFinished];
    
    if (completion) {
        self.lastAdObject = adObject;
        self.lastCompletion = completion;
        [self.autoRefreshManager setupRefreshTimer];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(demandResult);
        });
    }
}

- (void)markLoadingFinished {
    self.adObject = nil;
    self.completion = nil;
    self.bidRequester = nil;
}

- (BOOL)isAdObjectVisible {
    if (self.lastAdObject && [self.lastAdObject isKindOfClass:[UIView class]]) {
        return ((UIView*)self.lastAdObject).oxaIsVisible;
    }
    return YES;
}

@end
