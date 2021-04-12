//
//  OXAAdLoadFlowController.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXAAdLoadFlowController.h"
#import "OXAAdLoadFlowController+PrivateState.h"

#import "OXABannerEventHandler.h"
#import "OXADisplayView.h"
#import "OXADisplayView+InternalState.h"
#import "OXAError.h"

#import "OXMMacros.h"

// MARK: - Implementation

@implementation OXAAdLoadFlowController

// MARK: - Lifecycle


- (instancetype)initWithBidRequesterFactory:(id<OXABidRequesterProtocol> (^)(OXAAdUnitConfig *))bidRequesterFactory
                                   adLoader:(id<OXAAdLoaderProtocol>)adLoader
                                   delegate:(id<OXAAdLoadFlowControllerDelegate>)delegate
                      configValidationBlock:(OXAAdUnitConfigValidationBlock)configValidationBlock
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _bidRequesterFactory = [bidRequesterFactory copy];
    _adLoader = adLoader;
    _delegate = delegate;
    _configValidationBlock = [configValidationBlock copy];
    
    NSString * const uuid = [[NSUUID UUID] UUIDString];
    const char * const queueName = [[NSString stringWithFormat:@"OXAAdLoadFlowController_%@", uuid] UTF8String];
    _dispatchQueue = dispatch_queue_create(queueName, NULL);
    
    _mutationLock = [[NSLock alloc] init];
    
    return self;
}

// MARK: - Public API

- (BOOL)hasFailedLoading {
    return (self.flowState == OXAAdLoadFlowState_LoadingFailed);
}

// MARK: - OXAAdLoaderFlowDelegate

- (void)adLoader:(id<OXAAdLoaderProtocol>)adLoader loadedPrimaryAd:(id)adObject adSize:(nullable NSValue *)adSize {
    @weakify(self);
    [self enqueueGatedBlock:^{
        @strongify(self);
        if (self.bidRequestError) {
            NSError * const requestError = self.bidRequestError;
            self.bidRequestError = nil;
            OXMLogInfo(@"[ERROR]: %@", [requestError localizedDescription]);
        }
        self.adSize = adSize;
        self.primaryAdObject = adObject;
        [self markReadyToDeployAdView];
    }];
}

- (void)adLoader:(id<OXAAdLoaderProtocol>)adLoader failedWithPrimarySDKError:(nullable NSError *)error {
    @weakify(self);
    [self enqueueGatedBlock:^{
        @strongify(self);
        if (self.bidResponse.winningBid) {
            [self loadApolloDisplayView];
        } else {
            [self reportLoadingFailedWithError:error];
        }
    }];
}

- (void)adLoaderDidWinApollo:(id<OXAAdLoaderProtocol>)adLoader {
    @weakify(self);
    [self enqueueGatedBlock:^{
        @strongify(self);
        [self loadApolloDisplayView];
    }];
}

- (void)adLoaderLoadedApolloAd:(id<OXAAdLoaderProtocol>)adLoader {
    @weakify(self);
    [self enqueueGatedBlock:^{
        @strongify(self);
        self.adSize = [NSValue valueWithCGSize:self.bidResponse.winningBid.size];
        [self markReadyToDeployAdView];
    }];
}

- (void)adLoader:(id<OXAAdLoaderProtocol>)adLoader failedWithApolloError:(nullable NSError *)error {
    @weakify(self);
    [self enqueueGatedBlock:^{
        @strongify(self);
        self.apolloAdObject = nil;
        [self reportLoadingFailedWithError:error];
    }];
}

// MARK: - Private Methods

- (void)enqueueGatedBlock:(nonnull dispatch_block_t)block {
    @weakify(self);
    dispatch_async(self.dispatchQueue, ^{
        @strongify(self);
        if (!self) {
            return;
        }
        id<NSLocking> const lock = self.mutationLock;
        [lock lock];
        block();
        [lock unlock];
    });
}

///
- (void)refresh {
    @weakify(self);
    [self enqueueGatedBlock:^{
        @strongify(self);
        [self moveToNextLoadingStep];
    }];
}

- (void)enqueueNextStepAttempt {
    @weakify(self);
    [self enqueueGatedBlock:^{
        @strongify(self);
        BOOL const moveForward = [self.delegate adLoadFlowControllerShouldContinue:self];
        if (moveForward) {
            [self moveToNextLoadingStep];
        }
    }];
}

- (void)moveToNextLoadingStep {
    switch (self.flowState) {
        case OXAAdLoadFlowState_Idle:
        case OXAAdLoadFlowState_LoadingFailed:
        {
            [self tryLaunchingAdRequestFlow];
            return;
        }
            
        case OXAAdLoadFlowState_BidRequest:
        case OXAAdLoadFlowState_PrimaryAdRequest:
        case OXAAdLoadFlowState_LoadingDisplayView:
            // nop -- ad is being loaded -- waiting for the callback
            return;
            
        case OXAAdLoadFlowState_DemandReceived:
            [self requestPrimaryAdServer:self.bidResponse];
            return;
            
        case OXAAdLoadFlowState_ReadyToDeploy:
            [self deployPendingViewAndSendSuccessReport];
            return;
    }
}

- (void)tryLaunchingAdRequestFlow {
    OXAAdUnitConfig * const configClone = [self.delegate.adUnitConfig copy];
    const BOOL configIsValid = self.configValidationBlock(configClone, NO);
    if (!configIsValid) {
        [self reportLoadingFailedWithError:[OXAError noNativeCreative]];
        return;
    }
    
    self.savedAdUnitConfig = configClone;
    [self.delegate adLoadFlowControllerWillSendBidRequest:self];
    
    [self sendBidRequest];
}

- (void)sendBidRequest {
    self.flowState = OXAAdLoadFlowState_BidRequest;
    
    self.bidRequester = self.bidRequesterFactory(self.savedAdUnitConfig);
    @weakify(self);
    [self.bidRequester requestBidsWithCompletion:^(OXABidResponse *response, NSError *error) {
        @strongify(self);
        [self enqueueGatedBlock:^{
            @strongify(self);
            [self handleBidResponse:response error:error];
        }];
    }];
}

- (void)handleBidResponse:(nullable OXABidResponse *)response error:(nullable NSError *)error {
    self.bidResponse = (response && !error) ? response : nil;
    self.bidRequestError = error;
    
    self.bidRequester = nil;
    self.flowState = OXAAdLoadFlowState_DemandReceived;
    
    [self enqueueNextStepAttempt];
}

- (void)requestPrimaryAdServer:(nullable OXABidResponse *)bidResponse {
    self.flowState = OXAAdLoadFlowState_PrimaryAdRequest;
    
    [self.delegate adLoadFlowControllerWillRequestPrimaryAd:self];
    self.adLoader.flowDelegate = self;
    
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self.adLoader.primaryAdRequester requestAdWithBidResponse:bidResponse];
    });
}

- (void)loadApolloDisplayView {
    if (self.bidRequestError) {
        NSError * const requestError = self.bidRequestError;
        self.bidRequestError = nil;
        [self reportLoadingFailedWithError:requestError];
        return;
    }
    
    const BOOL configIsValid = self.configValidationBlock(self.savedAdUnitConfig, YES);
    if (!configIsValid) {
        [self reportLoadingFailedWithError:[OXAError noNativeCreative]];
        return;
    }
    
    OXABid * const bid = self.bidResponse.winningBid;
    if (!bid) {
        [self reportLoadingFailedWithError:[OXAError noWinningBid]];
        return;
    }
    
    self.flowState = OXAAdLoadFlowState_LoadingDisplayView;
    OXAAdUnitConfig * const adUnitConfig = self.savedAdUnitConfig;
    @weakify(self);
    dispatch_sync(dispatch_get_main_queue(), ^{
        @strongify(self);
        __strong __block id apolloAdObjectBox = nil;
        [self.adLoader createApolloAdWithBid:bid
                                adUnitConfig:adUnitConfig
                               adObjectSaver:^(id _Nonnull apolloAdObject) {
            apolloAdObjectBox = apolloAdObject;
        } loadMethodInvoker:^(dispatch_block_t _Nonnull loadMethod) {
            @strongify(self);
            [self enqueueGatedBlock:^{
                @strongify(self);
                self.apolloAdObject = apolloAdObjectBox;
                loadMethod();
            }];
        }];
    });
}

- (void)markReadyToDeployAdView {
    self.flowState = OXAAdLoadFlowState_ReadyToDeploy;
    [self enqueueNextStepAttempt];
}

- (void)deployPendingViewAndSendSuccessReport {
    self.flowState = OXAAdLoadFlowState_Idle;
    [self.adLoader reportSuccessWithAdObject:(self.primaryAdObject ?: self.apolloAdObject)
                                      adSize:self.adSize];
}

- (void)reportLoadingFailedWithError:(nullable NSError *)error {
    self.flowState = OXAAdLoadFlowState_LoadingFailed;
    [self.delegate adLoadFlowController:self failedWithError:error];
}

@end
