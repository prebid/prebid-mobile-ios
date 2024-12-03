/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "PBMAdLoadFlowController.h"
#import "PBMAdLoadFlowController+PrivateState.h"

#import "PBMDisplayView.h"
#import "PBMDisplayView+InternalState.h"
#import "PBMError.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

#import "PBMMacros.h"

// MARK: - Implementation

@implementation PBMAdLoadFlowController

// MARK: - Lifecycle


- (instancetype)initWithBidRequesterFactory:(id<PBMBidRequesterProtocol> (^)(AdUnitConfig *))bidRequesterFactory
                                   adLoader:(id<PBMAdLoaderProtocol>)adLoader
                               adUnitConfig:(AdUnitConfig *)adUnitConfig
                                   delegate:(id<AdLoadFlowControllerDelegate>)delegate
                      configValidationBlock:(PBMAdUnitConfigValidationBlock)configValidationBlock
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _bidRequesterFactory = [bidRequesterFactory copy];
    _adLoader = adLoader;
    _delegate = delegate;
    _configValidationBlock = [configValidationBlock copy];
    _savedAdUnitConfig = adUnitConfig;
    
    NSString * const uuid = [[NSUUID UUID] UUIDString];
    const char * const queueName = [[NSString stringWithFormat:@"PBMAdLoadFlowController_%@", uuid] UTF8String];
    _dispatchQueue = dispatch_queue_create(queueName, NULL);
    
    _mutationLock = [[NSLock alloc] init];
    
    return self;
}

// MARK: - Public API

- (BOOL)hasFailedLoading {
    return (self.flowState == PBMAdLoadFlowState_LoadingFailed);
}

// MARK: - PBMAdLoaderFlowDelegate

- (void)adLoader:(id<PBMAdLoaderProtocol>)adLoader loadedPrimaryAd:(id)adObject adSize:(nullable NSValue *)adSize {
    @weakify(self);
    [self enqueueGatedBlock:^{
        @strongify(self);
        if (!self) { return; }

        if (self.bidRequestError) {
            NSError * const requestError = self.bidRequestError;
            self.bidRequestError = nil;
            PBMLogInfo(@"[ERROR]: %@", [requestError localizedDescription]);
        }
        self.adSize = adSize;
        self.primaryAdObject = adObject;
        [self markReadyToDeployAdView];
    }];
}

- (void)adLoader:(id<PBMAdLoaderProtocol>)adLoader failedWithPrimarySDKError:(nullable NSError *)error {
    @weakify(self);
    [self enqueueGatedBlock:^{
        @strongify(self);
        if (!self) { return; }
        
        if (self.bidResponse.winningBid) {
            [self loadPrebidDisplayView];
        } else {
            [self reportLoadingFailedWithError:error];
        }
    }];
}

- (void)adLoaderDidWinPrebid:(id<PBMAdLoaderProtocol>)adLoader {
    @weakify(self);
    [self enqueueGatedBlock:^{
        @strongify(self);
        if (!self) { return; }
        
        [self loadPrebidDisplayView];
    }];
}

- (void)adLoaderLoadedPrebidAd:(id<PBMAdLoaderProtocol>)adLoader {
    @weakify(self);
    [self enqueueGatedBlock:^{
        @strongify(self);
        if (!self) { return; }
        
        self.adSize = [NSValue valueWithCGSize:self.bidResponse.winningBid.size];
        [self markReadyToDeployAdView];
    }];
}

- (void)adLoader:(id<PBMAdLoaderProtocol>)adLoader failedWithPrebidError:(nullable NSError *)error {
    @weakify(self);
    [self enqueueGatedBlock:^{
        @strongify(self);
        if (!self) { return; }
        
        self.prebidAdObject = nil;
        [self reportLoadingFailedWithError:error];
    }];
}

// MARK: - Private Methods

- (void)enqueueGatedBlock:(nonnull dispatch_block_t)block {
    @weakify(self);
    dispatch_async(self.dispatchQueue, ^{
        @strongify(self);
        if (!self) { return; }
        
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
        if (!self) { return; }
        
        [self moveToNextLoadingStep];
    }];
}

- (void)enqueueNextStepAttempt {
    @weakify(self);
    [self enqueueGatedBlock:^{
        @strongify(self);
        if (!self) { return; }
        
        BOOL const moveForward = [self.delegate adLoadFlowControllerShouldContinue:self];
        if (moveForward) {
            [self moveToNextLoadingStep];
        }
    }];
}

- (void)moveToNextLoadingStep {
    switch (self.flowState) {
        case PBMAdLoadFlowState_Idle:
        case PBMAdLoadFlowState_LoadingFailed:
        {
            [self tryLaunchingAdRequestFlow];
            return;
        }
            
        case PBMAdLoadFlowState_BidRequest:
        case PBMAdLoadFlowState_PrimaryAdRequest:
        case PBMAdLoadFlowState_LoadingDisplayView:
            // nop -- ad is being loaded -- waiting for the callback
            return;
            
        case PBMAdLoadFlowState_DemandReceived:
            [self requestPrimaryAdServer:self.bidResponse];
            return;
            
        case PBMAdLoadFlowState_ReadyToDeploy:
            [self deployPendingViewAndSendSuccessReport];
            return;
    }
}

- (void)tryLaunchingAdRequestFlow {
    const BOOL configIsValid = self.configValidationBlock(self.savedAdUnitConfig, NO);
    if (!configIsValid) {
        [self reportLoadingFailedWithError:[PBMError errorWithMessage:@"AdUnitConfig is not valid."
                                                                 type:PBMErrorTypeInternalError]];
        return;
    }
    
    [self.delegate adLoadFlowControllerWillSendBidRequest:self];
    
    [self sendBidRequest];
}

- (void)sendBidRequest {
    self.flowState = PBMAdLoadFlowState_BidRequest;
    
    self.bidRequester = self.bidRequesterFactory(self.savedAdUnitConfig);
    @weakify(self);
    [self.bidRequester requestBidsWithCompletion:^(BidResponse *response, NSError *error) {
        @strongify(self);
        if (!self) { return; }
        
        [self enqueueGatedBlock:^{
            @strongify(self);
            if (!self) { return; }
            
            [self handleBidResponse:response error:error];
        }];
    }];
}

- (void)handleBidResponse:(nullable BidResponse *)response error:(nullable NSError *)error {
    self.bidResponse = (response && !error) ? response : nil;
    self.bidRequestError = error;
    
    self.bidRequester = nil;
    self.flowState = PBMAdLoadFlowState_DemandReceived;
    
    [self enqueueNextStepAttempt];
}

- (void)requestPrimaryAdServer:(nullable BidResponse *)bidResponse {
    self.flowState = PBMAdLoadFlowState_PrimaryAdRequest;
    
    [self.delegate adLoadFlowControllerWillRequestPrimaryAd:self];
    self.adLoader.flowDelegate = self;
    
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if (!self) { return; }
        
        [self.adLoader.primaryAdRequester requestAdWithBidResponse:bidResponse];
    });
}

- (void)loadPrebidDisplayView {
    if (self.bidRequestError) {
        NSError * const requestError = self.bidRequestError;
        self.bidRequestError = nil;
        [self reportLoadingFailedWithError:requestError];
        return;
    }
    
    const BOOL configIsValid = self.configValidationBlock(self.savedAdUnitConfig, YES);
    if (!configIsValid) {
        [self reportLoadingFailedWithError:[PBMError errorWithMessage:@"AdUnitConfig is not valid."
                                                                 type:PBMErrorTypeInternalError]];
        return;
    }
    
    Bid * const bid = self.bidResponse.winningBid;
    if (!bid) {
        [self reportLoadingFailedWithError:[PBMError noWinningBid]];
        return;
    }
    
    self.flowState = PBMAdLoadFlowState_LoadingDisplayView;
    AdUnitConfig * const adUnitConfig = self.savedAdUnitConfig;
    
    @weakify(self);
    dispatch_sync(dispatch_get_main_queue(), ^{
        @strongify(self);
        if (!self) { return; }
        
        __strong __block id prebidAdObjectBox = nil;
        [self.adLoader createPrebidAdWithBid:bid
                                adUnitConfig:adUnitConfig
                               adObjectSaver:^(id _Nonnull prebidAdObject) {
            prebidAdObjectBox = prebidAdObject;
        } loadMethodInvoker:^(dispatch_block_t _Nonnull loadMethod) {
            @strongify(self);
            if (!self) { return; }
            
            [self enqueueGatedBlock:^{
                @strongify(self);
                if (!self) { return; }
                
                self.prebidAdObject = prebidAdObjectBox;
                loadMethod();
            }];
        }];
    });
}

- (void)markReadyToDeployAdView {
    self.flowState = PBMAdLoadFlowState_ReadyToDeploy;
    [self enqueueNextStepAttempt];
}

- (void)deployPendingViewAndSendSuccessReport {
    self.flowState = PBMAdLoadFlowState_Idle;
    [self.adLoader reportSuccessWithAdObject:(self.primaryAdObject ?: self.prebidAdObject)
                                      adSize:self.adSize];
}

- (void)reportLoadingFailedWithError:(nullable NSError *)error {
    self.flowState = PBMAdLoadFlowState_LoadingFailed;
    [self.delegate adLoadFlowController:self failedWithError:error];
}

@end
