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
#import "PrebidMobile/PrebidMobile.h"

@interface PrebidObjcTests : XCTestCase

@end

@implementation PrebidObjcTests

- (void)testServerHost {
    //given
    PrebidHost case1 = PrebidHostAppnexus;
    PrebidHost case2 = PrebidHostRubicon;
    
    //when
    Prebid.shared.prebidServerHost = case1;
    PrebidHost result1 = Prebid.shared.prebidServerHost;
    Prebid.shared.prebidServerHost = case2;
    PrebidHost result2 = Prebid.shared.prebidServerHost;
    
    //then
    XCTAssertEqual(case1, result1);
    XCTAssertEqual(case2, result2);
}

- (void)testServerHostCustomInvalid {
    //given
    NSError *error = nil;
    
    //when
    [Prebid.shared setCustomPrebidServerWithUrl:@"wrong url" error:&error];
    
    //then
    XCTAssertNotNil(error);
}

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

- (void)testBidderName {
    XCTAssertEqualObjects(@"appnexus", Prebid.bidderNameAppNexus);
    XCTAssertEqualObjects(@"rubicon", Prebid.bidderNameRubiconProject);
}

- (void)testPbsDebug {
    //given
    BOOL pbsDebug = true;
    
    //when
    Prebid.shared.pbsDebug = pbsDebug;
    
    //then
    XCTAssertEqual(pbsDebug, Prebid.shared.pbsDebug);
}

@end
