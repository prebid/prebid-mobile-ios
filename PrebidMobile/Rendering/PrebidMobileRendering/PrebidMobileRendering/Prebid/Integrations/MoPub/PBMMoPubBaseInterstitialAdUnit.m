//
//  PBMMoPubBaseInterstitialAdUnit.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMMoPubBaseInterstitialAdUnit.h"
#import "PBMMoPubBaseInterstitialAdUnit+Protected.h"

#import "PBMAdUnitConfig.h"
#import "PBMBid.h"
#import "PBMBidRequester.h"
#import "PBMBidResponse.h"
#import "PBMError.h"
#import "PBMMoPubUtils+Private.h"
#import "PBMSDKConfiguration.h"
#import "PBMTargeting.h"
#import "PBMMacros.h"
#import "PBMServerConnection.h"

@interface PBMMoPubBaseInterstitialAdUnit ()

@property (nonatomic, strong, nullable) PBMBidRequester *bidRequester;

//This is an MPInterstitialAdController object
//But we can't use it inderectly as don't want to have additional MoPub dependency in the SDK core
@property (nonatomic, weak, nullable) id<PBMMoPubAdObjectProtocol>adObject;
@property (nonatomic, copy, nullable) void (^completion)(PBMFetchDemandResult);

@end


@implementation PBMMoPubBaseInterstitialAdUnit

- (instancetype)initWithConfigId:(NSString *)configId {
    if(!(self = [super init])) {
        return nil;
    }
    _adUnitConfig = [[PBMAdUnitConfig alloc] initWithConfigId:configId];
    _adUnitConfig.isInterstitial = YES;
    _adUnitConfig.adPosition = PBMAdPosition_FullScreen;
    _adUnitConfig.videoPlacementType = 5;   //Fullscreen
    return self;
}

// MARK: - Computed properties

- (NSString *)configId {
    return self.adUnitConfig.configId;
}

// MARK: - Public Methods

- (void)fetchDemandWithObject:(NSObject *)adObject completion:(void (^)(PBMFetchDemandResult))completion {
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
    
    self.adObject = (id<PBMMoPubAdObjectProtocol>)adObject;
    self.completion = completion;
    
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
        if (response && !error) {
            [self handlePrebidResponse:response];
        } else {
            [self handlePrebidError:error];
        }
    }];
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
    self.completion = nil;
    [self markLoadingFinished];
    if (completion) {
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


@end
