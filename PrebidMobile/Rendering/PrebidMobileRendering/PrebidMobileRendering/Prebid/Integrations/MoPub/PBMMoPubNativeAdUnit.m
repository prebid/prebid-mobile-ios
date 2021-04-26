//
//  PBMMoPubNativeAdUnit.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMMoPubNativeAdUnit.h"

#import "PBMNativeAdUnit.h"
#import "PBMMoPubUtils.h"
#import "PBMMoPubUtils+Private.h"

#import "PBMMacros.h"

@interface PBMMoPubNativeAdUnit ()

//This is an MPNativeAdRequestTargeting object with properties keywords and localExtra
//But we can't use it inderectly as don't want to have additional MoPub dependency in the SDK core
@property (nonatomic, weak, nullable) id<PBMMoPubAdObjectProtocol> adObject;
@property (nonatomic, copy, nullable) void (^completion)(PBMFetchDemandResult);

@property (nonatomic, strong) PBMNativeAdUnit *nativeAdUnit;

@end

@implementation PBMMoPubNativeAdUnit

// MARK: + (public convenience init)

- (instancetype)initWithConfigID:(NSString *)configID
           nativeAdConfiguration:(PBMNativeAdConfiguration *)nativeAdConfiguration {
    return self = [self initWithNativeAdUnit:[[PBMNativeAdUnit alloc] initWithConfigID:configID
                                                                 nativeAdConfiguration:nativeAdConfiguration]];
}

- (instancetype)initWithNativeAdUnit:(PBMNativeAdUnit *)nativeAdUnit {
    if (nativeAdUnit == nil) {
        return nil;
    }
    
    if (!(self = [super init])) {
        return nil;
    }
    
    _nativeAdUnit = nativeAdUnit;
    return self;
}

// MARK: - Computed public properties

- (NSString *)configId {
    return self.nativeAdUnit.configId;
}

- (PBMNativeAdConfiguration *)nativeAdConfig {
    return self.nativeAdUnit.nativeAdConfig;
}

// MARK: - Context Data

- (void)addContextData:(NSString *)data forKey:(NSString *)key {
    [self.nativeAdUnit addContextData:data forKey:key];
}

- (void)updateContextData:(NSSet<NSString *> *)data forKey:(NSString *)key {
    [self.nativeAdUnit updateContextData:data forKey:key];
}

- (void)removeContextDataForKey:(NSString *)key {
    [self.nativeAdUnit removeContextDataForKey:key];
}

- (void)clearContextData {
    [self.nativeAdUnit clearContextData];
}

// MARK: - Ad Request

- (void)fetchDemandWithObject:(NSObject *)adObject completion:(void (^)(PBMFetchDemandResult))completion {
    
    if (![PBMMoPubUtils isCorrectAdObject:adObject]) {
        if (completion) {
            completion(PBMFetchDemandResult_WrongArguments);
        }
        return;
    }
    
    self.completion = completion;
    
    self.adObject = (id<PBMMoPubAdObjectProtocol>)adObject;
    [PBMMoPubUtils cleanUpAdObject:self.adObject];
    
    @weakify(self);
    [self.nativeAdUnit fetchDemandWithCompletion:^(PBMDemandResponseInfo * _Nonnull demandResponseInfo){
        @strongify(self);
        if (!self) {
            return;
        }
        
        if (demandResponseInfo.fetchDemandResult != PBMFetchDemandResult_Ok) {
            [self completeWithResult:demandResponseInfo.fetchDemandResult];
            return;
        }
        
        PBMFetchDemandResult demandResult = PBMFetchDemandResult_WrongArguments;
        if ([PBMMoPubUtils setUpAdObject:self.adObject
                            withConfigId:self.configId
                           targetingInfo:demandResponseInfo.bid.targetingInfo
                             extraObject:demandResponseInfo
                                  forKey:PBMMoPubAdNativeResponseKey]) {
            demandResult = PBMFetchDemandResult_Ok;
        }
        
        
        [self completeWithResult:demandResult];
    }];
}

- (void)completeWithResult:(PBMFetchDemandResult)demandResult {
    void (^ const completion)(PBMFetchDemandResult) = self.completion;
    
    if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(demandResult);
        });
    }
}

@end
