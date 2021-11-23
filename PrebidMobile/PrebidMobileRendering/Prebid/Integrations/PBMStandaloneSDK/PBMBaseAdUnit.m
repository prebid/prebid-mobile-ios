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

#include <objc/objc-sync.h>

#import "PBMBaseAdUnit.h"
#import "PBMBaseAdUnit+Protected.h"

#import "PBMBidRequester.h"
#import "PBMBidRequesterFactory.h"
#import "PBMConstants.h"
#import "PBMError.h"
#import "PBMMacros.h"
#import "PBMWinNotifier.h"
#import "PBMServerConnection.h"

#import "PrebidMobileSwiftHeaders.h"
#import <PrebidMobile/PrebidMobile-Swift.h>

@interface PBMBaseAdUnit ()

@property (nonatomic, copy, nonnull, readonly) PBMBidRequesterFactoryBlock bidRequesterFactory;

@property (nonatomic, strong, nullable) id<PBMBidRequesterProtocol> bidRequester; /// also serves as 'isLoading' flag
@property (nonatomic, copy, nullable) PBMFetchDemandCompletionHandler completion;

@property (nonatomic, strong, nullable) BidResponseForRendering *lastResponseUnsafe; /// backing storage, not protected by 'stateLockToken'
@property (nonatomic, strong, nullable) DemandResponseInfo *lastDemandResponseInfoUnsafe; /// backing storage, not protected by 'stateLockToken'

@end


@implementation PBMBaseAdUnit

// MARK: - Lifecycle

- (instancetype)initWithConfigID:(NSString *)configID
             bidRequesterFactory:(PBMBidRequesterFactoryBlock)bidRequesterFactory
                winNotifierBlock:(PBMWinNotifierBlock)winNotifierBlock
{
    if (!(self = [super init])) {
        return nil;
    }
    _adUnitConfig = [[AdUnitConfig alloc] initWithConfigID:configID];
    _bidRequesterFactory = [bidRequesterFactory copy];
    _winNotifierBlock = [winNotifierBlock copy];
    
    _stateLockToken = [[NSObject alloc] init];
    
    return self;
}

// MARK: - Computed public properties

- (NSString *)configId {
    return self.adUnitConfig.configID;
}

// MARK: - Computed protected properties

- (BidResponseForRendering *)lastBidResponse {
    BidResponseForRendering *result = nil;
    @synchronized (self.stateLockToken) {
        result = self.lastResponseUnsafe;
    }
    return result;
}

- (DemandResponseInfo *)lastDemandResponseInfo {
    DemandResponseInfo *result = nil;
    @synchronized (self.stateLockToken) {
        result = self.lastDemandResponseInfoUnsafe;
    }
    return result;
}

// MARK: - Ad Request

- (void)fetchDemandWithCompletion:(PBMFetchDemandCompletionHandler)completion {
    BOOL requestAlreadyInProgress = NO;
    @synchronized (self.stateLockToken) {
        if (self.bidRequester) {
            requestAlreadyInProgress = YES; // Report failure outside of '@synchronized' scope
        } else {
            self.bidRequester = self.bidRequesterFactory(self.adUnitConfig);
        }
    }
    
    if (requestAlreadyInProgress) {
        FetchDemandResult const previousFetchNotCompletedYet = FetchDemandResultSdkMisusePreviousFetchNotCompletedYet;
        completion([[DemandResponseInfo alloc] initWithFetchDemandResult:previousFetchNotCompletedYet
                                                                        bid:nil
                                                                   configId:self.configId
                                                           winNotifierBlock:self.winNotifierBlock
                                                                bidResponse:nil]);
        return;
    }
    self.completion = [completion copy];
    
    @weakify(self);
    [self.bidRequester requestBidsWithCompletion:^(BidResponseForRendering *response, NSError *error) {
        @strongify(self);
        [self handleDemandResponse:response error:error];
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

// MARK: - Protected methods

- (void)synchronized:(id)lock closure:(void (^)(void))synchronizedBlock {
    objc_sync_enter(lock);
    synchronizedBlock();
    objc_sync_exit(lock);
}

// MARK: - Private methods

- (void)handleDemandResponse:(BidResponseForRendering *)bidResponse error:(NSError *)error {
    PBMFetchDemandCompletionHandler theCompletion = nil;
    DemandResponseInfo *result = nil;
    
    @synchronized (self.stateLockToken) {
        theCompletion = self.completion;
        
        self.bidRequester = nil;
        self.completion = nil;
        self.lastResponseUnsafe = bidResponse;
        
        if (error) {
            result = [[DemandResponseInfo alloc] initWithFetchDemandResult:[PBMError demandResultFrom:error]
                                                                          bid:nil
                                                                     configId:self.configId
                                                             winNotifierBlock:self.winNotifierBlock
                                                                  bidResponse:bidResponse];
        } else if (!bidResponse.winningBid) {
            result = [[DemandResponseInfo alloc] initWithFetchDemandResult:FetchDemandResultDemandNoBids
                                                                          bid:nil
                                                                     configId:self.configId
                                                             winNotifierBlock:self.winNotifierBlock
                                                                  bidResponse:bidResponse];
        } else {
            result = [[DemandResponseInfo alloc] initWithFetchDemandResult:FetchDemandResultOk
                                                                          bid:bidResponse.winningBid
                                                                     configId:self.configId
                                                             winNotifierBlock:self.winNotifierBlock
                                                                  bidResponse:bidResponse];
        }
        
        self.lastDemandResponseInfoUnsafe = result;
    }
    if (theCompletion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            theCompletion(result);
        });
    }
}

@end
