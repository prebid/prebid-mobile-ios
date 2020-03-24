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
    VideoAdUnit *videoAdUnit = [[VideoAdUnit alloc] initWithConfigId:@"6ace8c7d-88c0-4623-8117-75bc3f0a2e45" size:CGSizeMake(300, 250) type: PBVideoPlacementTypeInBanner];
    VideoInterstitialAdUnit *videoInterstitialAdUnit = [[VideoInterstitialAdUnit alloc] initWithConfigId:@"6ace8c7d-88c0-4623-8117-75bc3f0a2e45"];
    RewardedVideoAdUnit *rewardedVideoAdUnit = [[RewardedVideoAdUnit alloc] initWithConfigId:@"6ace8c7d-88c0-4623-8117-75bc3f0a2e45"];

    NSArray *videoBaseAdUnitArr = @[videoAdUnit, videoInterstitialAdUnit, rewardedVideoAdUnit ];

    for (VideoBaseAdUnit *videoBaseAdUnit in videoBaseAdUnitArr) {
        [self checkVideoParametersHelper:videoBaseAdUnit];
    }
}

- (void) checkVideoParametersHelper: (VideoBaseAdUnit*) videoBaseAdUnit {
    PBVideoAdUnitParameters *parameters = [[PBVideoAdUnitParameters alloc] init];
    
    parameters.api = @[PBApi.VPAID_1, PBApi.VPAID_2];
    parameters.maxBitrate = [[SingleContainerInt alloc] initWithIntegerLiteral: 1500];
    parameters.minBitrate = [[SingleContainerInt alloc] initWithIntegerLiteral: 300];;
    parameters.maxDuration = [[SingleContainerInt alloc] initWithIntegerLiteral: 30];
    parameters.minDuration = [[SingleContainerInt alloc] initWithIntegerLiteral: 5];
    parameters.mimes = @[@"video/x-flv", @"video/mp4"];
    parameters.playbackMethod = @[PBPlaybackMethod.AutoPlaySoundOn, PBPlaybackMethod.ClickToPlay];
    parameters.protocols = @[PBProtocols.VAST_2_0, PBProtocols.VAST_3_0];
    parameters.startDelay = PBStartDelay.PreRoll;
    videoBaseAdUnit.parameters = parameters;
    
    //when
    PBVideoAdUnitParameters* testedParameters = videoBaseAdUnit.parameters;
    
    //then
    XCTAssertNotNil(testedParameters.api);
    XCTAssertEqual(2, testedParameters.api.count);
    XCTAssert([testedParameters.api containsObject:[[PBApi alloc] initWithIntegerLiteral: 1]] && [testedParameters.api containsObject:[[PBApi alloc] initWithIntegerLiteral: 2]]);
    XCTAssertNotNil(testedParameters.maxBitrate);
    XCTAssertEqual(1500, testedParameters.maxBitrate.value);
    XCTAssertNotNil(testedParameters.minBitrate);
    XCTAssertEqual(300, testedParameters.minBitrate.value);
    XCTAssertNotNil(testedParameters.maxDuration);
    XCTAssertEqual(30, testedParameters.maxDuration.value);
    XCTAssertNotNil(testedParameters.minDuration);
    XCTAssertEqual(5, testedParameters.minDuration.value);
    XCTAssertNotNil(testedParameters.mimes);
    XCTAssertEqual(2, testedParameters.mimes.count);
    XCTAssert([testedParameters.mimes containsObject:@"video/x-flv"] && [testedParameters.mimes containsObject:@"video/mp4"]);
    XCTAssertNotNil(testedParameters.playbackMethod);
    XCTAssertEqual(2, testedParameters.playbackMethod.count);
    XCTAssert([testedParameters.playbackMethod containsObject:[[PBPlaybackMethod alloc] initWithIntegerLiteral: 1]] && [testedParameters.playbackMethod containsObject:[[PBPlaybackMethod alloc] initWithIntegerLiteral: 3]]);
    XCTAssertNotNil(testedParameters.protocols);
    XCTAssertEqual(2, testedParameters.protocols.count);
    XCTAssert([testedParameters.protocols containsObject:[[PBProtocols alloc] initWithIntegerLiteral: 2]] && [testedParameters.protocols containsObject:[[PBProtocols alloc] initWithIntegerLiteral: 3]]);
    XCTAssertNotNil(testedParameters.startDelay);
    XCTAssertEqualObjects([[PBStartDelay alloc] initWithIntegerLiteral: 0], testedParameters.startDelay);

}

@end
