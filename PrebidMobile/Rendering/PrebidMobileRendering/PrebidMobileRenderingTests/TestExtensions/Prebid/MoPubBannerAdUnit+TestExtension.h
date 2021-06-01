//
//  OXAMoPubBannerAdUnit+TestExtension.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@protocol PBMServerConnectionProtocol;

@interface MoPubBannerAdUnit ()
- (void)fetchDemandWithObject:(NSObject *)adObject
                   connection:(id<PBMServerConnectionProtocol>)connection
             sdkConfiguration:(PrebidRenderingConfig *)sdkConfiguration
                    targeting:(PrebidRenderingTargeting *)targeting
                   completion:(void (^)(PBMFetchDemandResult))completion;
@end
