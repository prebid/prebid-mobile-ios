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
#import "PrebidMobileTests-Swift.h"

@interface AdUnitObjCTests : XCTestCase

@end

@implementation AdUnitObjCTests

AdUnit *adUnit;

- (void)setUp {
    adUnit = [[BannerAdUnit alloc] initWithConfigId:@"1001-1" size:CGSizeMake(300, 250)];
}

- (void)tearDown {
    [Targeting.shared clearUserKeywords];
}

- (void)testFetchDemand {
    
    //given
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    NSObject *testObject = [[NSObject alloc] init];
    __block ResultCode resultCode;
    [AdUnitSwizzleHelper toggleFetchDemand];
    
    //when
    [adUnit fetchDemandWithAdObject:testObject completion:^(enum ResultCode result) {
        resultCode = result;
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    [AdUnitSwizzleHelper toggleFetchDemand];
    
    //then
    XCTAssertEqual(ResultCodePrebidDemandFetchSuccess, resultCode);
}

- (void)testFetchDemandBids {
    
    //given
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    __block ResultCode resultCode;
    __block NSDictionary<NSString *, NSString *> *kvDictResult;
    [AdUnitSwizzleHelper toggleFetchDemand];
    
    AdUnitSwizzleHelper.targetingKeywords = @{@"key1" : @"value1"};
    
    //when
    [adUnit fetchDemandWithCompletion:^(enum ResultCode code, NSDictionary<NSString *,NSString *> * _Nullable kvDict) {
        resultCode = code;
        kvDictResult = kvDict;
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    [AdUnitSwizzleHelper toggleFetchDemand];
    
    //then
    XCTAssertEqual(ResultCodePrebidDemandFetchSuccess, resultCode);
    XCTAssertEqual(1, kvDictResult.count);
    XCTAssertEqualObjects(@"value1", kvDictResult[@"key1"]);

}

- (void)testResultCode {
    ResultCode resultCode = ResultCodePrebidDemandFetchSuccess;
    XCTAssertEqual(0, resultCode);
}

- (void)testSetAutoRefreshMillis {
    [adUnit setAutoRefreshMillisWithTime:30000];
}

- (void)testStopAutoRefresh {
    [adUnit stopAutoRefresh];
}

// MARK: adunit ext data aka inventory data (imp[].ext.data)

- (void)testExtData {
    NSSet *set = [NSSet setWithArray:@[@"value2"]];
    [adUnit addExtDataWithKey:@"key1" value:@"value1"];
    [adUnit updateExtDataWithKey:@"key12" value:set];
    [adUnit removeExtDataForKey:@"key1"];
    [adUnit clearExtData];
}

// MARK: adunit ext keywords (imp[].ext.keywords)

- (void)testExtKeywords {
    NSSet *set = [NSSet setWithArray:@[@"value2"]];
    [adUnit addExtKeywords:set];
    [adUnit removeExtKeyword:@"value2"];
    [adUnit clearExtKeywords];
}

@end
