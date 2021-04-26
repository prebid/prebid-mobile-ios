//
//  PBMDemandResponseInfo.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMDemandResponseInfo.h"
#import "PBMDemandResponseInfo+Internal.h"

#import "PBMNativeAd+FromMarkup.h"
#import "PBMNativeAdMarkup.h"

#import "PBMLog.h"
#import "PBMMacros.h"

@implementation PBMDemandResponseInfo

- (instancetype)initWithFetchDemandResult:(PBMFetchDemandResult)fetchDemandResult
                                      bid:(nullable PBMBid *)bid
                                 configId:(nullable NSString *)configId
                         winNotifierBlock:(PBMWinNotifierBlock)winNotifierBlock
{
    if (!(self = [super init])) {
        return nil;
    }
    _fetchDemandResult = fetchDemandResult;
    _bid = bid;
    _configId = [configId copy];
    _winNotifierBlock = [winNotifierBlock copy];
    return self;
}

- (void)getAdMarkupStringWithCompletion:(PBMAdMarkupStringHandler)completion {
    if (!self.bid) {
        completion(nil);
        return;
    }
    self.winNotifierBlock(self.bid, completion);
}

- (void)getNativeAdWithCompletion:(PBMNativeAdHandler)completion {
    [self getAdMarkupStringWithCompletion:^(NSString * _Nullable adMarkupString) {
        if (!adMarkupString) {
            completion(nil);
            return;
        }
        
        NSError *markupParsingError = nil;
        PBMNativeAdMarkup * const nativeAdMarkup = [[PBMNativeAdMarkup alloc] initWithJsonString:adMarkupString
                                                                                           error:&markupParsingError];
        if (!nativeAdMarkup) {
            if (markupParsingError) {
                PBMLogError(@"%@", markupParsingError.localizedDescription);
            }
            completion(nil);
            return;
        }
        
        completion([[PBMNativeAd alloc] initWithNativeAdMarkup:nativeAdMarkup]);
    }];
}

@end
