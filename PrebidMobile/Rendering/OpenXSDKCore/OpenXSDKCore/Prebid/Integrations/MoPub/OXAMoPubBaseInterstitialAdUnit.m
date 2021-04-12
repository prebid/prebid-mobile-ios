//
//  OXAMoPubBaseInterstitialAdUnit.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXAMoPubBaseInterstitialAdUnit.h"
#import "OXAMoPubBaseInterstitialAdUnit+Protected.h"

#import "OXAAdUnitConfig.h"
#import "OXABid.h"
#import "OXABidRequester.h"
#import "OXABidResponse.h"
#import "OXAError.h"
#import "OXAMoPubUtils+Private.h"
#import "OXASDKConfiguration.h"
#import "OXATargeting.h"
#import "OXMMacros.h"
#import "OXMServerConnection.h"

@interface OXAMoPubBaseInterstitialAdUnit ()

@property (nonatomic, strong, nullable) OXABidRequester *bidRequester;

//This is an MPInterstitialAdController object
//But we can't use it inderectly as don't want to have additional MoPub dependency in the SDK core
@property (nonatomic, weak, nullable) id<OXAMoPubAdObjectProtocol>adObject;
@property (nonatomic, copy, nullable) void (^completion)(OXAFetchDemandResult);

@end


@implementation OXAMoPubBaseInterstitialAdUnit

- (instancetype)initWithConfigId:(NSString *)configId {
    if(!(self = [super init])) {
        return nil;
    }
    _adUnitConfig = [[OXAAdUnitConfig alloc] initWithConfigId:configId];
    _adUnitConfig.isInterstitial = YES;
    _adUnitConfig.adPosition = OXAAdPosition_FullScreen;
    _adUnitConfig.videoPlacementType = 5;   //Fullscreen
    return self;
}

// MARK: - Computed properties

- (NSString *)configId {
    return self.adUnitConfig.configId;
}

// MARK: - Public Methods

- (void)fetchDemandWithObject:(NSObject *)adObject completion:(void (^)(OXAFetchDemandResult))completion {
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
    
    self.adObject = (id<OXAMoPubAdObjectProtocol>)adObject;
    self.completion = completion;
    
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
