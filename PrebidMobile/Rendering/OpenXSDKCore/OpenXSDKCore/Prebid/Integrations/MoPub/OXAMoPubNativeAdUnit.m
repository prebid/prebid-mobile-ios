//
//  OXAMoPubNativeAdUnit.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAMoPubNativeAdUnit.h"

#import "OXANativeAdUnit.h"
#import "OXAMoPubUtils.h"
#import "OXAMoPubUtils+Private.h"

#import "OXMMacros.h"

@interface OXAMoPubNativeAdUnit ()

//This is an MPNativeAdRequestTargeting object with properties keywords and localExtra
//But we can't use it inderectly as don't want to have additional MoPub dependency in the SDK core
@property (nonatomic, weak, nullable) id<OXAMoPubAdObjectProtocol> adObject;
@property (nonatomic, copy, nullable) void (^completion)(OXAFetchDemandResult);

@property (nonatomic, strong) OXANativeAdUnit *nativeAdUnit;

@end

@implementation OXAMoPubNativeAdUnit

// MARK: + (public convenience init)

- (instancetype)initWithConfigID:(NSString *)configID
           nativeAdConfiguration:(OXANativeAdConfiguration *)nativeAdConfiguration {
    return self = [self initWithNativeAdUnit:[[OXANativeAdUnit alloc] initWithConfigID:configID
                                                                 nativeAdConfiguration:nativeAdConfiguration]];
}

- (instancetype)initWithNativeAdUnit:(OXANativeAdUnit *)nativeAdUnit {
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

- (OXANativeAdConfiguration *)nativeAdConfig {
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

- (void)fetchDemandWithObject:(NSObject *)adObject completion:(void (^)(OXAFetchDemandResult))completion {
    
    if (![OXAMoPubUtils isCorrectAdObject:adObject]) {
        if (completion) {
            completion(OXAFetchDemandResult_WrongArguments);
        }
        return;
    }
    
    self.completion = completion;
    
    self.adObject = (id<OXAMoPubAdObjectProtocol>)adObject;
    [OXAMoPubUtils cleanUpAdObject:self.adObject];
    
    @weakify(self);
    [self.nativeAdUnit fetchDemandWithCompletion:^(OXADemandResponseInfo * _Nonnull demandResponseInfo){
        @strongify(self);
        if (!self) {
            return;
        }
        
        if (demandResponseInfo.fetchDemandResult != OXAFetchDemandResult_Ok) {
            [self completeWithResult:demandResponseInfo.fetchDemandResult];
            return;
        }
        
        OXAFetchDemandResult demandResult = OXAFetchDemandResult_WrongArguments;
        if ([OXAMoPubUtils setUpAdObject:self.adObject
                            withConfigId:self.configId
                           targetingInfo:demandResponseInfo.bid.targetingInfo
                             extraObject:demandResponseInfo
                                  forKey:OXAMoPubAdNativeResponseKey]) {
            demandResult = OXAFetchDemandResult_Ok;
        }
        
        
        [self completeWithResult:demandResult];
    }];
}

- (void)completeWithResult:(OXAFetchDemandResult)demandResult {
    void (^ const completion)(OXAFetchDemandResult) = self.completion;
    
    if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(demandResult);
        });
    }
}

@end
