/*   Copyright 2017 Prebid.org, Inc.
 
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

#import <Foundation/Foundation.h>
#import "PBAdUnit.h"
#import "PBBannerAdUnit.h"
#import "PBInterstitialAdUnit.h"
#import <XCTest/XCTest.h>

NSString *const kTestAdUnitId = @"TestAdUnit";
NSString *const kTestBannerAdUnitId = @"TestBannerAdUnit";
NSString *const kTestInterstitialAdUnitId = @"TestInterstitialAdUnit";
NSString *const kTestConfigId = @"testconfigid";

@interface PCAdUnitTests : XCTestCase

@end

@implementation PCAdUnitTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testBannerAdCreation {
    PBBannerAdUnit *bannerAdUnit = [[PBBannerAdUnit alloc] initWithAdUnitIdentifier:kTestBannerAdUnitId andConfigId:kTestConfigId];
    XCTAssertTrue(bannerAdUnit.adType == PBAdUnitTypeBanner);
    XCTAssertTrue([kTestBannerAdUnitId isEqualToString:bannerAdUnit.identifier]);
}

- (void)testInterstitialAdCreation {
    PBInterstitialAdUnit *interstitialAdUnit = [[PBInterstitialAdUnit alloc] initWithAdUnitIdentifier:kTestInterstitialAdUnitId andConfigId:kTestConfigId];
    XCTAssertTrue(interstitialAdUnit.adType == PBAdUnitTypeInterstitial);
    XCTAssertTrue([kTestInterstitialAdUnitId isEqualToString:interstitialAdUnit.identifier]);

    NSMutableArray *expectedSizeArray = [[NSMutableArray alloc] init];
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    int size[11][2] = {{300, 250}, {300, 600}, {320, 250}, {254, 133}, {580, 400}, {320, 320}, {320, 160}, {320, 480}, {336, 280}, {320, 400}, {1, 1}};
    for (int i = 0; i < 11; i++) {
        CGSize sizeObj = CGSizeMake(size[i][0], size[i][1]);
        if (sizeObj.width <= screenSize.size.width && sizeObj.height <= screenSize.size.height) {
            [expectedSizeArray addObject:[NSValue valueWithCGSize:sizeObj]];
        }
    }
    XCTAssertTrue([interstitialAdUnit.adSizes isEqualToArray:expectedSizeArray]);
}

- (void)testAddSizeToAdUnit {
    PBAdUnit *adUnit = [[PBAdUnit alloc] initWithIdentifier:kTestAdUnitId andAdType:PBAdUnitTypeBanner andConfigId:kTestConfigId];

    CGSize bannerSize = CGSizeMake(320, 50);
    [adUnit addSize:bannerSize];

    XCTAssertTrue(adUnit.adSizes.count == 1);
    XCTAssertTrue([adUnit.adSizes containsObject:[NSValue valueWithCGSize:bannerSize]]);
}

- (void)testAddMultipleSizesToAdUnit {
    PBAdUnit *adUnit = [[PBAdUnit alloc] initWithIdentifier:kTestAdUnitId andAdType:PBAdUnitTypeBanner andConfigId:kTestConfigId];
    
    CGSize bannerSize = CGSizeMake(320, 50);
    CGSize bannerSize2 = CGSizeMake(320, 250);
    [adUnit addSize:bannerSize];
    [adUnit addSize:bannerSize2];
    
    XCTAssertTrue(adUnit.adSizes.count == 2);
    XCTAssertTrue([adUnit.adSizes containsObject:[NSValue valueWithCGSize:bannerSize]]);
    XCTAssertTrue([adUnit.adSizes containsObject:[NSValue valueWithCGSize:bannerSize2]]);
}

- (void)testGenerateUUIDForAdUnit {
    PBAdUnit *adUnit = [[PBAdUnit alloc] initWithIdentifier:kTestAdUnitId andAdType:PBAdUnitTypeBanner andConfigId:kTestConfigId];
    NSString *adUnitUUIDOriginal = adUnit.uuid;

    [adUnit generateUUID];
    XCTAssertFalse([adUnitUUIDOriginal isEqualToString:adUnit.uuid]);
}

- (void)testIsEqualToAdUnit {
    PBBannerAdUnit *bannerAdUnit1 = [[PBBannerAdUnit alloc] initWithAdUnitIdentifier:kTestBannerAdUnitId andConfigId:kTestConfigId];
    PBBannerAdUnit *bannerAdUnit2 = [[PBBannerAdUnit alloc] initWithAdUnitIdentifier:kTestBannerAdUnitId andConfigId:kTestConfigId];
    XCTAssertTrue([bannerAdUnit1 isEqualToAdUnit:bannerAdUnit2]);
}

- (void)testShouldExpireAllBidsInitialAdUnit {
    PBAdUnit *adUnit = [[PBAdUnit alloc] initWithIdentifier:kTestAdUnitId andAdType:PBAdUnitTypeBanner andConfigId:kTestConfigId];
    XCTAssertTrue([adUnit shouldExpireAllBids:[NSDate date].timeIntervalSince1970]);
}

- (void)testShouldExpireAllBidsAdUnitWithSetTimeToExpire {
    PBAdUnit *adUnit = [[PBAdUnit alloc] initWithIdentifier:kTestAdUnitId andAdType:PBAdUnitTypeBanner andConfigId:kTestConfigId];
    [adUnit setTimeIntervalToExpireAllBids:[NSDate dateWithTimeIntervalSinceNow:5].timeIntervalSince1970];
    XCTAssertFalse([adUnit shouldExpireAllBids:[NSDate date].timeIntervalSince1970]);
}

- (void)testAdUnitSetTimeToExpireUsesLongerTimeToExpire {
    PBAdUnit *adUnit = [[PBAdUnit alloc] initWithIdentifier:kTestAdUnitId andAdType:PBAdUnitTypeBanner andConfigId:kTestConfigId];
    
    NSTimeInterval longTimeToExpire = [NSDate dateWithTimeIntervalSinceNow:270].timeIntervalSince1970;
    NSTimeInterval shortTimeToExpire = [NSDate dateWithTimeIntervalSinceNow:2].timeIntervalSince1970;
    NSTimeInterval timeInBetween = [NSDate dateWithTimeIntervalSinceNow:50].timeIntervalSince1970;
    
    [adUnit setTimeIntervalToExpireAllBids:longTimeToExpire];
    [adUnit setTimeIntervalToExpireAllBids:shortTimeToExpire];
    
    XCTAssertFalse([adUnit shouldExpireAllBids:timeInBetween]);
}

@end
