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

@interface VideoAdUnitObjCTests : XCTestCase

@end

@implementation VideoAdUnitObjCTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void) testVideoParametersCreation {
    
    //given
    VideoAdUnit *videoAdUnit = [[VideoAdUnit alloc] initWithConfigId:@"6ace8c7d-88c0-4623-8117-75bc3f0a2e45" size:CGSizeMake(300, 250) type: VideoPlacementTypeInBanner];
    VideoInterstitialAdUnit *videoInterstitialAdUnit = [[VideoInterstitialAdUnit alloc] initWithConfigId:@"6ace8c7d-88c0-4623-8117-75bc3f0a2e45"];
    RewardedVideoAdUnit *rewardedVideoAdUnit = [[RewardedVideoAdUnit alloc] initWithConfigId:@"6ace8c7d-88c0-4623-8117-75bc3f0a2e45"];

    NSArray *videoBaseAdUnitArr = @[videoAdUnit, videoInterstitialAdUnit, rewardedVideoAdUnit ];

    for (VideoBaseAdUnit *videoBaseAdUnit in videoBaseAdUnitArr) {
        [self checkVideoParametersHelper:videoBaseAdUnit];
    }
}

-(void) checkVideoParametersHelper: (VideoBaseAdUnit*) videoBaseAdUnit {
    VideoAdUnitParameters *parameters = [[VideoAdUnitParameters alloc] init];
    
    parameters.api = @[@1, @2];
    parameters.maxBitrate = @(1500);
    parameters.minBitrate = @(300);
    parameters.maxDuration = @(30);
    parameters.minDuration = @(5);
    parameters.mimes = @[@"video/x-flv", @"video/mp4"];
    parameters.playbackMethod = @[@1, @3];
    parameters.protocols = @[@2, @3];
    parameters.startDelay = @(0);
    videoBaseAdUnit.parameters = parameters;
    
    //when
    VideoAdUnitParameters* testedVideoParameters = videoBaseAdUnit.parameters;
    
    //then
    XCTAssertNotNil(testedVideoParameters.api);
    XCTAssertEqual(2, testedVideoParameters.api.count);
    XCTAssert([testedVideoParameters.api containsObject:@1] && [testedVideoParameters.api containsObject:@2]);
    XCTAssertNotNil(testedVideoParameters.maxBitrate);
    XCTAssertEqual(1500, [testedVideoParameters.maxBitrate intValue]);
    XCTAssertNotNil(testedVideoParameters.minBitrate);
    XCTAssertEqual(300, [testedVideoParameters.minBitrate intValue]);
    XCTAssertNotNil(testedVideoParameters.maxDuration);
    XCTAssertEqual(30, [testedVideoParameters.maxDuration intValue]);
    XCTAssertNotNil(testedVideoParameters.minDuration);
    XCTAssertEqual(5, [testedVideoParameters.minDuration integerValue]);
    XCTAssertNotNil(testedVideoParameters.mimes);
    XCTAssertEqual(2, testedVideoParameters.mimes.count);
    XCTAssert([testedVideoParameters.mimes containsObject:@"video/x-flv"] && [testedVideoParameters.mimes containsObject:@"video/mp4"]);
    XCTAssertNotNil(testedVideoParameters.playbackMethod);
    XCTAssertEqual(2, testedVideoParameters.playbackMethod.count);
    XCTAssert([testedVideoParameters.playbackMethod containsObject:@1] && [testedVideoParameters.playbackMethod containsObject:@3]);
    XCTAssertNotNil(testedVideoParameters.protocols);
    XCTAssertEqual(2, testedVideoParameters.protocols.count);
    XCTAssert([testedVideoParameters.protocols containsObject:@2] && [testedVideoParameters.protocols containsObject:@3]);
    XCTAssertNotNil(testedVideoParameters.startDelay);
    XCTAssertEqual(0, [testedVideoParameters.startDelay intValue]);

}

@end
