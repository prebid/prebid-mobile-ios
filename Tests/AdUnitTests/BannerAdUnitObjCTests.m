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

@interface BannerAdUnitObjCTests : XCTestCase

@end

@implementation BannerAdUnitObjCTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void) testBannerParametersCreation {

    //given
    BannerAdUnit *bannerAdUnit = [[BannerAdUnit alloc] initWithConfigId:@"6ace8c7d-88c0-4623-8117-75bc3f0a2e45" size:CGSizeMake(300, 250)];
    
    BannerAdUnitParameters* bannerParameters = [[BannerAdUnitParameters alloc] init];
    bannerParameters.api = @[@1, @2];
    
    bannerAdUnit.bannerParameters = bannerParameters;
    
    //when
    BannerAdUnitParameters* testedBannerParameters = bannerAdUnit.bannerParameters;
    
    //then
    XCTAssertNotNil(testedBannerParameters);
    XCTAssertNotNil(testedBannerParameters.api);
    XCTAssertEqual(2, testedBannerParameters.api.count);
    XCTAssert([testedBannerParameters.api containsObject:@1] && [testedBannerParameters.api containsObject:@2]);

}

@end
