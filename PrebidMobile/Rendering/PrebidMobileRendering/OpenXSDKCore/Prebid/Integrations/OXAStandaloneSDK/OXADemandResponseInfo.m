//
//  OXADemandResponseInfo.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXADemandResponseInfo.h"
#import "OXADemandResponseInfo+Internal.h"

#import "OXANativeAd+FromMarkup.h"
#import "OXANativeAdMarkup.h"

#import "OXMLog.h"
#import "OXMMacros.h"

@implementation OXADemandResponseInfo

- (instancetype)initWithFetchDemandResult:(OXAFetchDemandResult)fetchDemandResult
                                      bid:(nullable OXABid *)bid
                                 configId:(nullable NSString *)configId
                         winNotifierBlock:(OXAWinNotifierBlock)winNotifierBlock
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

- (void)getAdMarkupStringWithCompletion:(OXAAdMarkupStringHandler)completion {
    if (!self.bid) {
        completion(nil);
        return;
    }
    self.winNotifierBlock(self.bid, completion);
}

- (void)getNativeAdWithCompletion:(OXANativeAdHandler)completion {
    [self getAdMarkupStringWithCompletion:^(NSString * _Nullable adMarkupString) {
        if (!adMarkupString) {
            completion(nil);
            return;
        }
        
        NSError *markupParsingError = nil;
        OXANativeAdMarkup * const nativeAdMarkup = [[OXANativeAdMarkup alloc] initWithJsonString:adMarkupString
                                                                                           error:&markupParsingError];
        if (!nativeAdMarkup) {
            if (markupParsingError) {
                OXMLogError(@"%@", markupParsingError.localizedDescription);
            }
            completion(nil);
            return;
        }
        
        completion([[OXANativeAd alloc] initWithNativeAdMarkup:nativeAdMarkup]);
    }];
}

@end
