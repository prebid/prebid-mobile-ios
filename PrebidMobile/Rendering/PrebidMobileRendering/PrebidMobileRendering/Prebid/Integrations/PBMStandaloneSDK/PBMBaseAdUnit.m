//
//  PBMBaseAdUnit.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

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

#import "PrebidMobileRenderingSwiftHeaders.h"
#import <PrebidMobileRendering/PrebidMobileRendering-Swift.h>

@interface PBMBaseAdUnit ()

@property (nonatomic, copy, nonnull, readonly) PBMBidRequesterFactoryBlock bidRequesterFactory;

@property (nonatomic, strong, nullable) id<PBMBidRequesterProtocol> bidRequester; /// also serves as 'isLoading' flag
@property (nonatomic, copy, nullable) PBMFetchDemandCompletionHandler completion;

@property (nonatomic, strong, nullable) BidResponse *lastResponseUnsafe; /// backing storage, not protected by 'stateLockToken'
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

- (BidResponse *)lastBidResponse {
    BidResponse *result = nil;
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
                                                           winNotifierBlock:self.winNotifierBlock]);
        return;
    }
    self.completion = [completion copy];
    
    @weakify(self);
    [self.bidRequester requestBidsWithCompletion:^(BidResponse *response, NSError *error) {
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

- (void)handleDemandResponse:(BidResponse *)bidResponse error:(NSError *)error {
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
                                                             winNotifierBlock:self.winNotifierBlock];
        } else if (!bidResponse.winningBid) {
            result = [[DemandResponseInfo alloc] initWithFetchDemandResult:FetchDemandResultDemandNoBids
                                                                          bid:nil
                                                                     configId:self.configId
                                                             winNotifierBlock:self.winNotifierBlock];
        } else {
            result = [[DemandResponseInfo alloc] initWithFetchDemandResult:FetchDemandResultOk
                                                                          bid:bidResponse.winningBid
                                                                     configId:self.configId
                                                             winNotifierBlock:self.winNotifierBlock];
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
