//
//  PBMBaseAdUnit.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMBaseAdUnit.h"
#import "PBMBaseAdUnit+Protected.h"

#import "PBMAdUnitConfig.h"
#import "PBMBidRequester.h"
#import "PBMBidRequesterFactory.h"
#import "PBMBidResponse.h"
#import "PBMDemandResponseInfo+Internal.h"
#import "PBMError.h"
#import "PBMWinNotifier.h"
#import "PBMServerConnection.h"

#import "PBMConstants.h"
#import "PBMMacros.h"


@interface PBMBaseAdUnit ()

@property (nonatomic, copy, nonnull, readonly) PBMBidRequesterFactoryBlock bidRequesterFactory;

@property (nonatomic, strong, nullable) id<PBMBidRequesterProtocol> bidRequester; /// also serves as 'isLoading' flag
@property (nonatomic, copy, nullable) PBMFetchDemandCompletionHandler completion;

@property (nonatomic, strong, nullable) PBMBidResponse *lastResponseUnsafe; /// backing storage, not protected by 'stateLockToken'
@property (nonatomic, strong, nullable) PBMDemandResponseInfo *lastDemandResponseInfoUnsafe; /// backing storage, not protected by 'stateLockToken'

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
    _adUnitConfig = [[PBMAdUnitConfig alloc] initWithConfigId:configID];
    _bidRequesterFactory = [bidRequesterFactory copy];
    _winNotifierBlock = [winNotifierBlock copy];
    
    _stateLockToken = [[NSObject alloc] init];
    
    return self;
}

// MARK: - Computed public properties

- (NSString *)configId {
    return self.adUnitConfig.configId;
}

// MARK: - Computed protected properties

- (PBMBidResponse *)lastBidResponse {
    PBMBidResponse *result = nil;
    @synchronized (self.stateLockToken) {
        result = self.lastResponseUnsafe;
    }
    return result;
}

- (PBMDemandResponseInfo *)lastDemandResponseInfo {
    PBMDemandResponseInfo *result = nil;
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
        PBMFetchDemandResult const previousFetchNotCompletedYet = PBMFetchDemandResult_SDKMisuse_PreviousFetchNotCompletedYet;
        completion([[PBMDemandResponseInfo alloc] initWithFetchDemandResult:previousFetchNotCompletedYet
                                                                        bid:nil
                                                                   configId:self.configId
                                                           winNotifierBlock:self.winNotifierBlock]);
        return;
    }
    self.completion = [completion copy];
    
    @weakify(self);
    [self.bidRequester requestBidsWithCompletion:^(PBMBidResponse *response, NSError *error) {
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

// MARK: - Private methods

- (void)handleDemandResponse:(PBMBidResponse *)bidResponse error:(NSError *)error {
    PBMFetchDemandCompletionHandler theCompletion = nil;
    PBMDemandResponseInfo *result = nil;
    
    @synchronized (self.stateLockToken) {
        theCompletion = self.completion;
        
        self.bidRequester = nil;
        self.completion = nil;
        self.lastResponseUnsafe = bidResponse;
        
        if (error) {
            result = [[PBMDemandResponseInfo alloc] initWithFetchDemandResult:[PBMError demandResultFromError:error]
                                                                          bid:nil
                                                                     configId:self.configId
                                                             winNotifierBlock:self.winNotifierBlock];
        } else if (!bidResponse.winningBid) {
            result = [[PBMDemandResponseInfo alloc] initWithFetchDemandResult:PBMFetchDemandResult_DemandNoBids
                                                                          bid:nil
                                                                     configId:self.configId
                                                             winNotifierBlock:self.winNotifierBlock];
        } else {
            result = [[PBMDemandResponseInfo alloc] initWithFetchDemandResult:PBMFetchDemandResult_Ok
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
