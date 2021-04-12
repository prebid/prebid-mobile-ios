//
//  OXABaseAdUnit.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXABaseAdUnit.h"
#import "OXABaseAdUnit+Protected.h"

#import "OXAAdUnitConfig.h"
#import "OXABidRequester.h"
#import "OXABidRequesterFactory.h"
#import "OXABidResponse.h"
#import "OXADemandResponseInfo+Internal.h"
#import "OXAError.h"
#import "OXAWinNotifier.h"
#import "OXMServerConnection.h"

#import "OXMConstants.h"
#import "OXMMacros.h"


@interface OXABaseAdUnit ()

@property (nonatomic, copy, nonnull, readonly) OXABidRequesterFactoryBlock bidRequesterFactory;

@property (nonatomic, strong, nullable) id<OXABidRequesterProtocol> bidRequester; /// also serves as 'isLoading' flag
@property (nonatomic, copy, nullable) OXAFetchDemandCompletionHandler completion;

@property (nonatomic, strong, nullable) OXABidResponse *lastResponseUnsafe; /// backing storage, not protected by 'stateLockToken'
@property (nonatomic, strong, nullable) OXADemandResponseInfo *lastDemandResponseInfoUnsafe; /// backing storage, not protected by 'stateLockToken'

@end


@implementation OXABaseAdUnit

// MARK: - Lifecycle

- (instancetype)initWithConfigID:(NSString *)configID
             bidRequesterFactory:(OXABidRequesterFactoryBlock)bidRequesterFactory
                winNotifierBlock:(OXAWinNotifierBlock)winNotifierBlock
{
    if (!(self = [super init])) {
        return nil;
    }
    _adUnitConfig = [[OXAAdUnitConfig alloc] initWithConfigId:configID];
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

- (OXABidResponse *)lastBidResponse {
    OXABidResponse *result = nil;
    @synchronized (self.stateLockToken) {
        result = self.lastResponseUnsafe;
    }
    return result;
}

- (OXADemandResponseInfo *)lastDemandResponseInfo {
    OXADemandResponseInfo *result = nil;
    @synchronized (self.stateLockToken) {
        result = self.lastDemandResponseInfoUnsafe;
    }
    return result;
}

// MARK: - Ad Request

- (void)fetchDemandWithCompletion:(OXAFetchDemandCompletionHandler)completion {
    BOOL requestAlreadyInProgress = NO;
    @synchronized (self.stateLockToken) {
        if (self.bidRequester) {
            requestAlreadyInProgress = YES; // Report failure outside of '@synchronized' scope
        } else {
            self.bidRequester = self.bidRequesterFactory(self.adUnitConfig);
        }
    }
    if (requestAlreadyInProgress) {
        OXAFetchDemandResult const previousFetchNotCompletedYet = OXAFetchDemandResult_SDKMisuse_PreviousFetchNotCompletedYet;
        completion([[OXADemandResponseInfo alloc] initWithFetchDemandResult:previousFetchNotCompletedYet
                                                                        bid:nil
                                                                   configId:self.configId
                                                           winNotifierBlock:self.winNotifierBlock]);
        return;
    }
    self.completion = [completion copy];
    
    @weakify(self);
    [self.bidRequester requestBidsWithCompletion:^(OXABidResponse *response, NSError *error) {
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

- (void)handleDemandResponse:(OXABidResponse *)bidResponse error:(NSError *)error {
    OXAFetchDemandCompletionHandler theCompletion = nil;
    OXADemandResponseInfo *result = nil;
    
    @synchronized (self.stateLockToken) {
        theCompletion = self.completion;
        
        self.bidRequester = nil;
        self.completion = nil;
        self.lastResponseUnsafe = bidResponse;
        
        if (error) {
            result = [[OXADemandResponseInfo alloc] initWithFetchDemandResult:[OXAError demandResultFromError:error]
                                                                          bid:nil
                                                                     configId:self.configId
                                                             winNotifierBlock:self.winNotifierBlock];
        } else if (!bidResponse.winningBid) {
            result = [[OXADemandResponseInfo alloc] initWithFetchDemandResult:OXAFetchDemandResult_DemandNoBids
                                                                          bid:nil
                                                                     configId:self.configId
                                                             winNotifierBlock:self.winNotifierBlock];
        } else {
            result = [[OXADemandResponseInfo alloc] initWithFetchDemandResult:OXAFetchDemandResult_Ok
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
