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

@interface AdUnitSuccessorObjCTests : XCTestCase

@end

@implementation AdUnitSuccessorObjCTests

NSString * const configId = @"1001-1";

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

//MARK: - BannerAdUnit
- (void)testBannerAdUnitCreation {
    AdUnit *adunit = [[BannerAdUnit alloc] initWithConfigId:configId size:CGSizeMake(300, 250)];
    XCTAssertNotNil(adunit);
}

//MARK: - InterstitialAdUnit
- (void)testInterstitialAdUnitCreation {
    AdUnit *adunit = [[InterstitialAdUnit alloc] initWithConfigId:configId];
    XCTAssertNotNil(adunit);
}

- (void)testInterstitialAdUnitConvenienceCreation {
    AdUnit *adunit = [[InterstitialAdUnit alloc] initWithConfigId:configId minWidthPerc:50 minHeightPerc:70];
    XCTAssertNotNil(adunit);
}

//MARK: - VideoAdUnit
- (void)testVideoAdUnitCreation {
    //when
    AdUnit *adunit = [[VideoAdUnit alloc] initWithConfigId:configId size:CGSizeMake(300, 250)];
    XCTAssertNotNil(adunit);
}

- (void)testVideoAdUnitCreationDeprecated {
    //when
    AdUnit *adunit = [[VideoAdUnit alloc] initWithConfigId:configId size:CGSizeMake(300, 250) type:PBVideoPlacementTypeInBanner];
    XCTAssertNotNil(adunit);
}

//MARK: - VideoInterstitialAdUnit
- (void)testVideoInterstitialAdUnitCreation {
    //when
    AdUnit *adunit = [[VideoInterstitialAdUnit alloc] initWithConfigId:configId];
    XCTAssertNotNil(adunit);
}

//MARK: - RewardedVideoAdUnit
- (void)testRewardedVideoAdUnitCreation {
    //when
    AdUnit *adunit = [[RewardedVideoAdUnit alloc] initWithConfigId:configId];
    XCTAssertNotNil(adunit);
}

@end
