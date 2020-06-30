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

@interface AdUnitObjCTests : XCTestCase

@end

@implementation AdUnitObjCTests

AdUnit *adUnit;

+ (void) setUp {
    adUnit = [[BannerAdUnit alloc] initWithConfigId:@"1001-1" size:CGSizeMake(300, 250)];

}

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    [Targeting.shared clearUserKeywords];
}

- (void)testFetchDemand {

    NSObject *testObject = [[NSObject alloc] init];
    [adUnit fetchDemandWithAdObject:testObject completion:^(enum ResultCode result) {
    }];
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

- (void)testUserKeyword {
    NSSet *set = [NSSet setWithArray:@[@"value2"]];
    [adUnit addUserKeywordWithKey:@"key1" value:@"value1"];
    [adUnit addUserKeywordsWithKey:@"key2" value:set];
    [adUnit removeUserKeywordForKey:@"key1"];
    [adUnit clearUserKeywords];
}

- (void)testContextData {
    NSSet *set = [NSSet setWithArray:@[@"value2"]];
    [adUnit addContextDataWithKey:@"key1" value:@"value1"];
    [adUnit updateContextDataWithKey:@"key12" value:set];
    [adUnit removeContextDataForKey:@"key1"];
    [adUnit clearContextData];
}

- (void)testContextKeywords {
    NSSet *set = [NSSet setWithArray:@[@"value2"]];
    [adUnit addContextKeywords:set];
    [adUnit removeContextKeyword:@"value2"];
    [adUnit clearContextKeywords];
}

@end
