//
//  OXAMoPubBannerAdUnit+TestExtension.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMMoPubBannerAdUnit.h"

@protocol PBMServerConnectionProtocol;

@interface PBMMoPubBannerAdUnit ()
- (void)fetchDemandWithObject:(NSObject *)adObject
                   connection:(id<PBMServerConnectionProtocol>)connection
             sdkConfiguration:(PBMSDKConfiguration *)sdkConfiguration
                    targeting:(PBMTargeting *)targeting
                   completion:(void (^)(PBMFetchDemandResult))completion;
@end
