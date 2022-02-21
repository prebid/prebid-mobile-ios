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

+ (void) setUp {
    adUnit = [[BannerAdUnit alloc] initWithConfigId:@"1001-1" size:CGSizeMake(300, 250)];
}

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    [Targeting.shared clearUserKeywords];
    [adUnit clearAppContentObject];
    [adUnit clearUserDataObjects];
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

// MARK: - global context data aka inventory data (app.content.data)

- (void)testSetAppContent {
    PBAdUnitContentDataObject *appDataObject1 = [PBAdUnitContentDataObject new];
    appDataObject1.id = @"data id";
    appDataObject1.name = @"test name";
    
    PBAdUnitContentDataObject *appDataObject2 = [PBAdUnitContentDataObject new];
    appDataObject1.id = @"data id";
    appDataObject1.name = @"test name";
    
    PBAdUnitContentObject *appContent = [PBAdUnitContentObject new];
    appContent.album = @"test album";
    appContent.data = @[appDataObject1, appDataObject2];
    
    [adUnit setAppContent:appContent];
    
    PBAdUnitContentObject *resultAppContent = [adUnit getAppContentObject];
    XCTAssertEqual(2, resultAppContent.data.count);
    XCTAssertEqual(resultAppContent.data.firstObject, appDataObject1);
    XCTAssertEqual(appContent, resultAppContent);
}

- (void)testClearAppContent {
    PBAdUnitContentDataObject *appDataObject1 = [PBAdUnitContentDataObject new];
    appDataObject1.id = @"data id";
    appDataObject1.name = @"test name";
    
    PBAdUnitContentDataObject *appDataObject2 = [PBAdUnitContentDataObject new];
    appDataObject1.id = @"data id";
    appDataObject1.name = @"test name";
    
    PBAdUnitContentObject *appContent = [PBAdUnitContentObject new];
    appContent.album = @"test album";
    appContent.data = @[appDataObject1, appDataObject2];
    
    [adUnit setAppContent:appContent];
    
    PBAdUnitContentObject *resultAppContent1 = [adUnit getAppContentObject];
    XCTAssertNotNil(resultAppContent1);
    [adUnit clearAppContentObject];
    PBAdUnitContentObject *resultAppContent2 = [adUnit getAppContentObject];
    XCTAssertNil(resultAppContent2);
}

- (void)testAddAppContentDataObject {
    PBAdUnitContentDataObject *appDataObject1 = [PBAdUnitContentDataObject new];
    appDataObject1.id = @"data id";
    appDataObject1.name = @"test name";
    
    PBAdUnitContentDataObject *appDataObject2 = [PBAdUnitContentDataObject new];
    appDataObject1.id = @"data id";
    appDataObject1.name = @"test name";
    
    [adUnit addAppContentDataObjects:@[appDataObject1, appDataObject2]];
    NSArray<PBAdUnitContentDataObject*> *objects = [adUnit getAppContentObject].data;
    
    XCTAssertEqual(2, objects.count);
    XCTAssertEqual(objects.firstObject, appDataObject1);
}

- (void)testRemoveAppContentDataObjects {
    PBAdUnitContentDataObject *appDataObject = [PBAdUnitContentDataObject new];
    appDataObject.id = @"data id";
    appDataObject.name = @"test name";
    
    [adUnit addAppContentDataObjects:@[appDataObject]];
    NSArray<PBAdUnitContentDataObject*> *objects1 = [adUnit getAppContentObject].data;
    XCTAssertEqual(1, objects1.count);
    
    [adUnit removeAppContentDataObject:appDataObject];
    NSArray<PBAdUnitContentDataObject*> *objects2 = [adUnit getAppContentObject].data;
    XCTAssertEqual(0, objects2.count);
}

- (void)testClearAppContentDataObjects {
    PBAdUnitContentDataObject *appDataObject1 = [PBAdUnitContentDataObject new];
    appDataObject1.id = @"data id";
    appDataObject1.name = @"test name";
    
    PBAdUnitContentDataObject *appDataObject2 = [PBAdUnitContentDataObject new];
    appDataObject1.id = @"data id";
    appDataObject1.name = @"test name";
    
    [adUnit addAppContentDataObjects:@[appDataObject1, appDataObject2]];
    NSArray<PBAdUnitContentDataObject*> *objects1 = [adUnit getAppContentObject].data;
    XCTAssertEqual(2, objects1.count);
    
    [adUnit clearAppContentDataObjects];
    NSArray<PBAdUnitContentDataObject*> *objects2 = [adUnit getAppContentObject].data;
    XCTAssertEqual(0, objects2.count);
}

//    // MARK: - global user data aka visitor data (user.data)

- (void)testAddUserDataObjects {
    PBAdUnitContentDataObject *userDataObject1 = [PBAdUnitContentDataObject new];
    userDataObject1.id = @"data id";
    userDataObject1.name = @"test name";
    
    PBAdUnitContentDataObject *userDataObject2 = [PBAdUnitContentDataObject new];
    userDataObject2.id = @"data id";
    userDataObject2.name = @"test name";
    
    [adUnit addUserDataObjects:@[userDataObject1, userDataObject2]];
    
    NSArray<PBAdUnitContentDataObject*> *objects = [adUnit getUserDataObjects];
    XCTAssertEqual(2, objects.count);
    XCTAssertEqual(objects.firstObject, userDataObject1);
}

- (void)testRemoveUserDataObjects {
    PBAdUnitContentDataObject *userDataObject1 = [PBAdUnitContentDataObject new];
    userDataObject1.id = @"data id";
    userDataObject1.name = @"test name";
    
    [adUnit addUserDataObjects:@[userDataObject1]];
    NSArray<PBAdUnitContentDataObject*> *objects1 = [adUnit getUserDataObjects];
    XCTAssertEqual(1, objects1.count);
    
    [adUnit removeUserDataObject:userDataObject1];
    NSArray<PBAdUnitContentDataObject*> *objects2 = [adUnit getUserDataObjects];
    XCTAssertEqual(0, objects2.count);
}

- (void)testClearUserDataObjects {
    PBAdUnitContentDataObject *userDataObject1 = [PBAdUnitContentDataObject new];
    userDataObject1.id = @"data id";
    userDataObject1.name = @"test name";
    
    PBAdUnitContentDataObject *userDataObject2 = [PBAdUnitContentDataObject new];
    userDataObject2.id = @"data id";
    userDataObject2.name = @"test name";
    
    [adUnit addUserDataObjects:@[userDataObject1, userDataObject2]];
    NSArray<PBAdUnitContentDataObject*> *objects1 = [adUnit getUserDataObjects];
    XCTAssertEqual(2, objects1.count);
    
    [adUnit clearUserDataObjects];
    NSArray<PBAdUnitContentDataObject*> *objects2 = [adUnit getUserDataObjects];
    XCTAssertEqual(0, objects2.count);
}

@end
