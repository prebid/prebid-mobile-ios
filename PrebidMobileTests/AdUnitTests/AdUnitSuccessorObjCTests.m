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


- (void)tearDown {
    Prebid.shared.useExternalClickthroughBrowser = false;
}

//MARK: - BannerAdUnit
- (void)testBannerAdUnitCreation {
    AdUnit *adunit = [[BannerAdUnit alloc] initWithConfigId:configId size:CGSizeMake(300, 250)];
    XCTAssertNotNil(adunit);
}

- (void)testBannerParametersCreation {

    //given
    BannerAdUnit *bannerAdUnit = [[BannerAdUnit alloc] initWithConfigId:@"6ace8c7d-88c0-4623-8117-75bc3f0a2e45" size:CGSizeMake(300, 250)];
    
    BannerParameters* parameters = [[BannerParameters alloc] init];
    parameters.api = @[PBApi.VPAID_1, PBApi.VPAID_2];
    
    bannerAdUnit.bannerParameters = parameters;
    
    //when
    BannerParameters* testedBannerParameters = bannerAdUnit.bannerParameters;
    
    //then
    XCTAssertNotNil(testedBannerParameters);
    XCTAssertNotNil(testedBannerParameters.api);
    XCTAssertEqual(2, testedBannerParameters.api.count);
    XCTAssert([testedBannerParameters.api containsObject:[[PBApi alloc] initWithIntegerLiteral: 1]] && [testedBannerParameters.api containsObject:[[PBApi alloc] initWithIntegerLiteral: 2]]);

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

- (void)testInstreamVideoAdUnitCreation {
    //when
    AdUnit *adunit = [[VideoAdUnit alloc] initWithConfigId:configId size:CGSizeMake(300, 250)];
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

//MARK: - VideoBaseAdUnit
- (void)testVideoParametersCreation {
    VideoParameters *parameters = [[VideoParameters alloc] initWithMimes:@[@"video/x-flv", @"video/mp4"]];
    
    parameters.api = @[PBApi.VPAID_1, PBApi.VPAID_2];
    parameters.maxBitrate = [[SingleContainerInt alloc] initWithIntegerLiteral: 1500];
    parameters.minBitrate = [[SingleContainerInt alloc] initWithIntegerLiteral: 300];;
    parameters.maxDuration = [[SingleContainerInt alloc] initWithIntegerLiteral: 30];
    parameters.minDuration = [[SingleContainerInt alloc] initWithIntegerLiteral: 5];
    parameters.playbackMethod = @[PBPlaybackMethod.AutoPlaySoundOn, PBPlaybackMethod.ClickToPlay];
    parameters.protocols = @[PBProtocols.VAST_2_0, PBProtocols.VAST_3_0];
    parameters.startDelay = PBStartDelay.PreRoll;
    
    //given
    BannerAdUnit *videoAdUnit = [[BannerAdUnit alloc] initWithConfigId:@"6ace8c7d-88c0-4623-8117-75bc3f0a2e45" size:CGSizeMake(300, 250)];
    videoAdUnit.adFormats = [NSSet setWithObject:AdFormat.video];
    videoAdUnit.videoParameters = parameters;
    
    InterstitialAdUnit *videoInterstitialAdUnit = [[InterstitialAdUnit alloc] initWithConfigId:@"6ace8c7d-88c0-4623-8117-75bc3f0a2e45"];
    videoInterstitialAdUnit.adFormats = [NSSet setWithObject:AdFormat.video];
    videoInterstitialAdUnit.videoParameters = parameters;
    
    RewardedVideoAdUnit *rewardedVideoAdUnit = [[RewardedVideoAdUnit alloc] initWithConfigId:@"6ace8c7d-88c0-4623-8117-75bc3f0a2e45"];
    rewardedVideoAdUnit.videoParameters = parameters;
    
    XCTAssert(videoAdUnit.videoParameters == parameters);
    XCTAssert(videoInterstitialAdUnit.videoParameters == parameters);
    XCTAssert(rewardedVideoAdUnit.videoParameters == parameters);
}

@end
