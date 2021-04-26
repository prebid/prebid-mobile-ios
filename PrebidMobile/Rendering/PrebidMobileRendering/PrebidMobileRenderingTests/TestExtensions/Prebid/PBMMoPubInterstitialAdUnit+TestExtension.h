//
//  OXAMoPubInterstitialAdUnit+TestExtension.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import "PBMMoPubInterstitialAdUnit.h"

@protocol PBMServerConnectionProtocol;

@interface PBMMoPubInterstitialAdUnit ()
- (void)fetchDemandWithObject:(NSObject *)adObject
                   connection:(id<PBMServerConnectionProtocol>)connection
             sdkConfiguration:(PBMSDKConfiguration *)sdkConfiguration
                    targeting:(PBMTargeting *)targeting
                   completion:(void (^)(PBMFetchDemandResult))completion;
@end
