//
//  PBMMoPubBannerAdUnit.m
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import "UIView+PBMExtensions.h"

#import "PBMMoPubBannerAdUnit.h"
#import "PBMMoPubBannerAdUnit+InternalState.h"

#import "PBMAdUnitConfig+Internal.h"
#import "PBMBid.h"
#import "PBMBidResponse.h"
#import "PBMBidRequester.h"
#import "PBMBidResponse.h"
#import "PBMBid.h"
#import "PBMError.h"
#import "PBMMoPubUtils+Private.h"
#import "PBMSDKConfiguration.h"
#import "PBMTargeting.h"
#import "PBMServerConnection.h"
#import "PBMAutoRefreshManager.h"

#import "PBMMacros.h"

@interface PBMMoPubBannerAdUnit ()

@property (nonatomic, strong, nullable) PBMBidRequester *bidRequester;
//This is an MPAdView object
//But we can't use it inderectly as don't want to have additional MoPub dependency in the SDK core
@property (nonatomic, weak, nullable) id<PBMMoPubAdObjectProtocol> adObject;
@property (nonatomic, copy, nullable) void (^completion)(PBMFetchDemandResult);

@property (nonatomic, weak, nullable) id<PBMMoPubAdObjectProtocol> lastAdObject;
@property (nonatomic, copy, nullable) void (^lastCompletion)(PBMFetchDemandResult);

@property (atomic, assign) BOOL isRefreshStopped;
@property (nonatomic, strong, nonnull, readonly) PBMAutoRefreshManager *autoRefreshManager;

@property (nonatomic, copy, nullable) NSError *adRequestError;

@end


@implementation PBMMoPubBannerAdUnit

// MARK: - Lifecycle

- (instancetype)initWithConfigId:(NSString *)configId size:(CGSize)size {
    if(!(self = [super init])) {
        return nil;
    }
    
    _adUnitConfig = [[PBMAdUnitConfig alloc] initWithConfigId:configId size:size];
    
    @weakify(self);
    _autoRefreshManager = [[PBMAutoRefreshManager alloc] initWithPrefetchTime:PBMAdPrefetchTime
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
                             connection:[PBMServerConnection singleton]
                       sdkConfiguration:[PBMSDKConfiguration singleton]
                              targeting:[PBMTargeting shared]
                             completion:self.lastCompletion];
        }
    }];
    
    return self;
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

- (void)setAdPosition:(PBMAdPosition)adPosition {
    self.adUnitConfig.adPosition = adPosition;
}

- (PBMAdPosition)adPosition {
    return self.adUnitConfig.adPosition;
}

- (PBMVideoPlacementType)videoPlacementType {
    return self.adUnitConfig.videoPlacementType;
}

- (void)setVideoPlacementType:(PBMVideoPlacementType)videoPlacementType {
    self.adUnitConfig.videoPlacementType = videoPlacementType;
}

- (PBMNativeAdConfiguration *)nativeAdConfig {
    return self.adUnitConfig.nativeAdConfig;
}

- (void)setNativeAdConfig:(PBMNativeAdConfiguration *)nativeAdConfig {
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
- (void)fetchDemandWithObject:(NSObject *)adObject completion:(void (^)(PBMFetchDemandResult))completion {
    self.isRefreshStopped = NO;
    [self fetchDemandWithObject:adObject
                     connection:[PBMServerConnection singleton]
               sdkConfiguration:[PBMSDKConfiguration singleton]
                      targeting:[PBMTargeting shared]
                     completion:completion];
}

- (void)fetchDemandWithObject:(NSObject *)adObject
                   connection:(id<PBMServerConnectionProtocol>)connection
             sdkConfiguration:(PBMSDKConfiguration *)sdkConfiguration
                    targeting:(PBMTargeting *)targeting
                   completion:(void (^)(PBMFetchDemandResult))completion
{
    if (self.bidRequester) {
        return; // Request in progress
    }
    
    if (![PBMMoPubUtils isCorrectAdObject:adObject]) {
        if (completion) {
            completion(PBMFetchDemandResult_WrongArguments);
        }
        return;
    }
    
    [self.autoRefreshManager cancelRefreshTimer];
    
    if (self.isRefreshStopped) {
        return;
    }
    
    self.adObject = (id<PBMMoPubAdObjectProtocol>)adObject;
    self.completion = completion;
    
    self.lastAdObject = nil;
    self.lastCompletion = nil;
    self.adRequestError = nil;
    
    [PBMMoPubUtils cleanUpAdObject:self.adObject];
    
    self.bidRequester = [[PBMBidRequester alloc] initWithConnection:connection
                                                   sdkConfiguration:sdkConfiguration
                                                          targeting:targeting
                                                adUnitConfiguration:self.adUnitConfig];
    @weakify(self);
    [self.bidRequester requestBidsWithCompletion:^(PBMBidResponse *response, NSError *error) {
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

- (void)handlePrebidResponse:(nullable PBMBidResponse *)response {
    PBMFetchDemandResult demandResult = PBMFetchDemandResult_DemandNoBids;
    if (response.winningBid) {
        if ([PBMMoPubUtils setUpAdObject:self.adObject
                                 withConfigId:self.configId
                           targetingInfo:response.winningBid.targetingInfo
                             extraObject:response.winningBid forKey:PBMMoPubAdUnitBidKey]) {
            demandResult = PBMFetchDemandResult_Ok;
        } else {
            demandResult =PBMFetchDemandResult_WrongArguments;
        }
    } else {
        PBMLogError(@"The winning bid is absent in response!");
    }
    [self completeWithResult:demandResult];
}

- (void)handlePrebidError:(NSError *)error {
    [self completeWithResult:([PBMError demandResultFromError:error] ?: PBMFetchDemandResult_InternalSDKError)];
}

- (void)completeWithResult:(PBMFetchDemandResult)demandResult {
    void (^ const completion)(PBMFetchDemandResult) = self.completion;
    const id<PBMMoPubAdObjectProtocol> adObject = self.adObject;
    
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
        return ((UIView*)self.lastAdObject).pbmIsVisible;
    }
    return YES;
}

@end
