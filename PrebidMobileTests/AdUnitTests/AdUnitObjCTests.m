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
    [adUnit clearAppContent];
    [adUnit clearUserData];
    
    Prebid.shared.useExternalClickthroughBrowser = false;
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

// MARK: - [DEPRECATED API] adunit context data

- (void)testContextData {
    NSSet *set = [NSSet setWithArray:@[@"value2"]];
    [adUnit addContextDataWithKey:@"key1" value:@"value1"];
    [adUnit updateContextDataWithKey:@"key12" value:set];
    [adUnit removeContextDataForKey:@"key1"];
    [adUnit clearContextData];
}

// MARK: - [DEPRECATED API] adunit context keywords

- (void)testContextKeywords {
    NSSet *set = [NSSet setWithArray:@[@"value2"]];
    [adUnit addContextKeywords:set];
    [adUnit removeContextKeyword:@"value2"];
    [adUnit clearContextKeywords];
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

// MARK: - global context data aka inventory data (app.content.data)

- (void)testSetAppContent {
    PBMORTBContentData *appDataObject1 = [PBMORTBContentData new];
    appDataObject1.id = @"data id";
    appDataObject1.name = @"test name";
    
    PBMORTBContentData *appDataObject2 = [PBMORTBContentData new];
    appDataObject1.id = @"data id";
    appDataObject1.name = @"test name";
    
    PBMORTBAppContent *appContent = [PBMORTBAppContent new];
    appContent.album = @"test album";
    appContent.data = @[appDataObject1, appDataObject2];
    
    [adUnit setAppContent:appContent];
    
    PBMORTBAppContent *resultAppContent = [adUnit getAppContent];
    XCTAssertEqual(2, resultAppContent.data.count);
    XCTAssertEqual(resultAppContent.data.firstObject, appDataObject1);
    XCTAssertEqual(appContent, resultAppContent);
}

- (void)testClearAppContent {
    PBMORTBContentData *appDataObject1 = [PBMORTBContentData new];
    appDataObject1.id = @"data id";
    appDataObject1.name = @"test name";
    
    PBMORTBContentData *appDataObject2 = [PBMORTBContentData new];
    appDataObject1.id = @"data id";
    appDataObject1.name = @"test name";
    
    PBMORTBAppContent *appContent = [PBMORTBAppContent new];
    appContent.album = @"test album";
    appContent.data = @[appDataObject1, appDataObject2];
    
    [adUnit setAppContent:appContent];
    
    PBMORTBAppContent *resultAppContent1 = [adUnit getAppContent];
    XCTAssertNotNil(resultAppContent1);
    [adUnit clearAppContent];
    PBMORTBAppContent *resultAppContent2 = [adUnit getAppContent];
    XCTAssertNil(resultAppContent2);
}

- (void)testAddAppContentDataObject {
    PBMORTBContentData *appDataObject1 = [PBMORTBContentData new];
    appDataObject1.id = @"data id";
    appDataObject1.name = @"test name";
    
    PBMORTBContentData *appDataObject2 = [PBMORTBContentData new];
    appDataObject1.id = @"data id";
    appDataObject1.name = @"test name";
    
    [adUnit addAppContentData:@[appDataObject1, appDataObject2]];
    NSArray<PBMORTBContentData*> *objects = [adUnit getAppContent].data;
    
    XCTAssertEqual(2, objects.count);
    XCTAssertEqual(objects.firstObject, appDataObject1);
}

- (void)testRemoveAppContentDataObjects {
    PBMORTBContentData *appDataObject = [PBMORTBContentData new];
    appDataObject.id = @"data id";
    appDataObject.name = @"test name";
    
    [adUnit addAppContentData:@[appDataObject]];
    NSArray<PBMORTBContentData*> *objects1 = [adUnit getAppContent].data;
    XCTAssertEqual(1, objects1.count);
    
    [adUnit removeAppContentData:appDataObject];
    NSArray<PBMORTBContentData*> *objects2 = [adUnit getAppContent].data;
    XCTAssertEqual(0, objects2.count);
}

- (void)testClearAppContentDataObjects {
    PBMORTBContentData *appDataObject1 = [PBMORTBContentData new];
    appDataObject1.id = @"data id";
    appDataObject1.name = @"test name";
    
    PBMORTBContentData *appDataObject2 = [PBMORTBContentData new];
    appDataObject1.id = @"data id";
    appDataObject1.name = @"test name";
    
    [adUnit addAppContentData:@[appDataObject1, appDataObject2]];
    NSArray<PBMORTBContentData*> *objects1 = [adUnit getAppContent].data;
    XCTAssertEqual(2, objects1.count);
    
    [adUnit clearAppContentData];
    NSArray<PBMORTBContentData*> *objects2 = [adUnit getAppContent].data;
    XCTAssertEqual(0, objects2.count);
}

//    // MARK: - global user data aka visitor data (user.data)

- (void)testAddUserDataObjects {
    PBMORTBContentData *userDataObject1 = [PBMORTBContentData new];
    userDataObject1.id = @"data id";
    userDataObject1.name = @"test name";
    
    PBMORTBContentData *userDataObject2 = [PBMORTBContentData new];
    userDataObject2.id = @"data id";
    userDataObject2.name = @"test name";
    
    [adUnit addUserData:@[userDataObject1, userDataObject2]];
    
    NSArray<PBMORTBContentData*> *objects = [adUnit getUserData];
    XCTAssertEqual(2, objects.count);
    XCTAssertEqual(objects.firstObject, userDataObject1);
}

- (void)testRemoveUserDataObjects {
    PBMORTBContentData *userDataObject1 = [PBMORTBContentData new];
    userDataObject1.id = @"data id";
    userDataObject1.name = @"test name";
    
    [adUnit addUserData:@[userDataObject1]];
    NSArray<PBMORTBContentData*> *objects1 = [adUnit getUserData];
    XCTAssertEqual(1, objects1.count);
    
    [adUnit removeUserData:userDataObject1];
    NSArray<PBMORTBContentData*> *objects2 = [adUnit getUserData];
    XCTAssertEqual(0, objects2.count);
}

- (void)testClearUserDataObjects {
    PBMORTBContentData *userDataObject1 = [PBMORTBContentData new];
    userDataObject1.id = @"data id";
    userDataObject1.name = @"test name";
    
    PBMORTBContentData *userDataObject2 = [PBMORTBContentData new];
    userDataObject2.id = @"data id";
    userDataObject2.name = @"test name";
    
    [adUnit addUserData:@[userDataObject1, userDataObject2]];
    NSArray<PBMORTBContentData*> *objects1 = [adUnit getUserData];
    XCTAssertEqual(2, objects1.count);
    
    [adUnit clearUserData];
    NSArray<PBMORTBContentData*> *objects2 = [adUnit getUserData];
    XCTAssertEqual(0, objects2.count);
}

@end
