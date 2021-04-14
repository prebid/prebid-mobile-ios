//
//  OXAMoPubInterstitialAdUnit+TestExtension.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import "OXAMoPubInterstitialAdUnit.h"

@protocol OXMServerConnectionProtocol;

@interface OXAMoPubInterstitialAdUnit ()
- (void)fetchDemandWithObject:(NSObject *)adObject
                   connection:(id<OXMServerConnectionProtocol>)connection
             sdkConfiguration:(OXASDKConfiguration *)sdkConfiguration
                    targeting:(OXATargeting *)targeting
                   completion:(void (^)(OXAFetchDemandResult))completion;
@end
