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
    PrebidConfiguration.shared.prebidServerHost = case1;
    PrebidHost result1 = PrebidConfiguration.shared.prebidServerHost;
    PrebidConfiguration.shared.prebidServerHost = case2;
    PrebidHost result2 = PrebidConfiguration.shared.prebidServerHost;
    
    //then
    XCTAssertEqual(case1, result1);
    XCTAssertEqual(case2, result2);
}

- (void)testServerHostCustomInvalid {
    //given
    NSError *error = nil;
    
    //when
    [PrebidConfiguration.shared setCustomPrebidServerWithUrl:@"wrong url" error:&error];
    
    //then
    XCTAssertNotNil(error);
}

- (void)testAccountId {
    //given
    NSString *serverAccountId = @"123";
    
    //when
    PrebidConfiguration.shared.prebidServerAccountId = serverAccountId;
    
    //then
    XCTAssertEqualObjects(serverAccountId, PrebidConfiguration.shared.prebidServerAccountId);
}

- (void)testStoredAuctionResponse {
    //given
    NSString *storedAuctionResponse = @"111122223333";
    
    //when
    PrebidConfiguration.shared.storedAuctionResponse = storedAuctionResponse;
    
    //then
    XCTAssertEqualObjects(storedAuctionResponse, PrebidConfiguration.shared.storedAuctionResponse);
}

- (void)testAddStoredBidResponse {
    [PrebidConfiguration.shared addStoredBidResponseWithBidder:@"rubicon" responseId:@"221155"];
}

- (void)testClearStoredBidResponses {
    [PrebidConfiguration.shared clearStoredBidResponses];
}

- (void)testShareGeoLocation {
    //given
    BOOL case1 = YES;
    BOOL case2 = NO;
    
    //when
    PrebidConfiguration.shared.shareGeoLocation = case1;
    BOOL result1 = PrebidConfiguration.shared.shareGeoLocation;
    
    PrebidConfiguration.shared.shareGeoLocation = case2;
    BOOL result2 = PrebidConfiguration.shared.shareGeoLocation;
    
    //rhen
    XCTAssertEqual(case1, result1);
    XCTAssertEqual(case2, result2);
}

- (void)testTimeoutMillis {
    //given
    int timeoutMillis =  3000;
    
    //when
    PrebidConfiguration.shared.bidRequestTimeoutMillis = timeoutMillis;
    
    //then
    XCTAssertEqual(timeoutMillis, PrebidConfiguration.shared.bidRequestTimeoutMillis);
}

- (void)testLogLevel {
    [PrebidConfiguration.shared setLogLevel:LogLevel_Debug];
}

- (void)testBidderName {
    XCTAssertEqualObjects(@"appnexus", PrebidConfiguration.bidderNameAppNexus);
    XCTAssertEqualObjects(@"rubicon", PrebidConfiguration.bidderNameRubiconProject);
}

- (void)testPbsDebug {
    //given
    BOOL pbsDebug = true;
    
    //when
    PrebidConfiguration.shared.pbsDebug = pbsDebug;
    
    //then
    XCTAssertEqual(pbsDebug, PrebidConfiguration.shared.pbsDebug);
}

@end
