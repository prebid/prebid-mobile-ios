/*   Copyright 2018-2019 Prebid.org, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#import <XCTest/XCTest.h>
#import "SwiftImport.h"

@interface PrebidObjcTestsRenderer : NSObject <PrebidMobilePluginRenderer>

@end

@implementation PrebidObjcTestsRenderer

- (NSString *)name {
    return @"PrebidObjcTestsRenderer";
}

- (NSString *)version {
    return @"1.0";
}

- (NSDictionary<NSString *, id> *)data {
    return nil;
}

- (UIView<PrebidMobileDisplayViewProtocol> *)createBannerViewWith:(CGRect)frame
                                                              bid:(Bid *)bid
                                                  adConfiguration:(AdUnitConfig *)adConfiguration
                                                  loadingDelegate:(id<DisplayViewLoadingDelegate>)loadingDelegate
                                              interactionDelegate:(id<DisplayViewInteractionDelegate>)interactionDelegate {
    return nil;
}

- (id<PrebidMobileInterstitialControllerProtocol>)createInterstitialControllerWithBid:(Bid *)bid
                                                                      adConfiguration:(AdUnitConfig *)adConfiguration
                                                                      loadingDelegate:(id<InterstitialControllerLoadingDelegate>)loadingDelegate
                                                                  interactionDelegate:(id<InterstitialControllerInteractionDelegate>)interactionDelegate {
    return nil;
}

@end

@interface PrebidObjcTestsIdProvider : NSObject <ExtendedIdProvider>

@property (nonatomic, readonly) ExtendedIdProviderInfo *providerInfo;

@end

@implementation PrebidObjcTestsIdProvider

- (instancetype)init {
    self = [super init];
    if (self) {
        _providerInfo = [[ExtendedIdProviderInfo alloc] initWithName:@"PrebidObjcTestsIdProvider" version:@"1.0"];
    }
    return self;
}

- (NSArray<id<ExtendedId>> *)getExtendedIds {
    UserUniqueID *uid = [[UserUniqueID alloc] initWithUniqueId:@"objc-id" aType:@1 ext:nil];
    return @[[[ExternalUserId alloc] initWithSource:@"objc.example.com" uids:@[uid] ext:nil]];
}

@end

@interface PrebidObjcTests : XCTestCase

@end

@implementation PrebidObjcTests


- (void)testAccountId {
    //given
    NSString *serverAccountId = @"123";
    
    //when
    Prebid.shared.prebidServerAccountId = serverAccountId;
    
    //then
    XCTAssertEqualObjects(serverAccountId, Prebid.shared.prebidServerAccountId);
}

- (void)testStoredAuctionResponse {
    //given
    NSString *storedAuctionResponse = @"111122223333";
    
    //when
    Prebid.shared.storedAuctionResponse = storedAuctionResponse;
    
    //then
    XCTAssertEqualObjects(storedAuctionResponse, Prebid.shared.storedAuctionResponse);
}

- (void)testAddStoredBidResponse {
    [Prebid.shared addStoredBidResponseWithBidder:@"rubicon" responseId:@"221155"];
}

- (void)testClearStoredBidResponses {
    [Prebid.shared clearStoredBidResponses];
}

- (void)testShareGeoLocation {
    //given
    BOOL case1 = YES;
    BOOL case2 = NO;
    
    //when
    Prebid.shared.shareGeoLocation = case1;
    BOOL result1 = Prebid.shared.shareGeoLocation;
    
    Prebid.shared.shareGeoLocation = case2;
    BOOL result2 = Prebid.shared.shareGeoLocation;
    
    //rhen
    XCTAssertEqual(case1, result1);
    XCTAssertEqual(case2, result2);
}

- (void)testTimeoutMillis {
    //given
    int timeoutMillis =  3000;
    
    //when
    Prebid.shared.timeoutMillis = timeoutMillis;
    
    //then
    XCTAssertEqual(timeoutMillis, Prebid.shared.timeoutMillis);
}

- (void)testLogLevel {
    [Prebid.shared setLogLevel:PBMLogLevel.debug];
}

- (void)testPbsDebug {
    //given
    BOOL pbsDebug = true;
    
    //when
    Prebid.shared.pbsDebug = pbsDebug;
    
    //then
    XCTAssertEqual(pbsDebug, Prebid.shared.pbsDebug);
}

- (void)testRegisterPlugin {
    //given
    PrebidObjcTestsRenderer *renderer = [PrebidObjcTestsRenderer new];
    
    //when
    [Prebid registerPlugin:renderer as:PluginCapability.renderer];
    
    //then
    XCTAssertTrue([Prebid containsPlugin:renderer as:PluginCapability.renderer]);
    
    //when
    [Prebid unregisterPlugin:renderer as:PluginCapability.renderer];
    
    //then
    XCTAssertFalse([Prebid containsPlugin:renderer as:PluginCapability.renderer]);
}

- (void)testRegisterPluginWithoutCapabilityProtocol {
    //given
    NSObject *object = [NSObject new];
    
    //when
    [Prebid registerPlugin:object as:PluginCapability.renderer];
    
    //then
    XCTAssertFalse([Prebid containsPlugin:object as:PluginCapability.renderer]);
}

- (void)testRegisterExtendedIdProvider {
    //given
    PrebidObjcTestsIdProvider *provider = [PrebidObjcTestsIdProvider new];
    
    //when
    [Prebid registerPlugin:provider as:PluginCapability.extendedIds];
    
    //then
    XCTAssertTrue([Prebid containsPlugin:provider as:PluginCapability.extendedIds]);
    XCTAssertTrue([[[Targeting.shared getExtendedIds] valueForKey:@"source"] containsObject:@"objc.example.com"]);
    
    //when
    [Prebid unregisterPlugin:provider as:PluginCapability.extendedIds];
    
    //then
    XCTAssertFalse([Prebid containsPlugin:provider as:PluginCapability.extendedIds]);
    XCTAssertFalse([[[Targeting.shared getExtendedIds] valueForKey:@"source"] containsObject:@"objc.example.com"]);
}

- (void)testPluginInfo {
    PrebidPluginInfo *info = [[PrebidPluginInfo alloc] initWithName:@"plugin" version:@"1.0"];
    
    XCTAssertEqualObjects(info, [[PrebidPluginInfo alloc] initWithName:@"plugin" version:@"1.0"]);
    XCTAssertNotEqualObjects(info, [[PrebidPluginInfo alloc] initWithName:@"plugin" version:@"2.0"]);
    XCTAssertEqualObjects(info.description, @"plugin/1.0");
    XCTAssertEqualObjects(PluginCapability.renderer.name, @"renderer");
    XCTAssertEqualObjects(PluginCapability.extendedIds.name, @"extendedIds");
}

@end
