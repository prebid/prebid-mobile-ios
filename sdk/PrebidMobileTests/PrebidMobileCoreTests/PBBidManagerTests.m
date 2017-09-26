/*   Copyright 2017 APPNEXUS INC
 
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

#import "PBServerAdapter.h"
#import "PBAdUnit.h"
#import "PBBannerAdUnit.h"
#import "PBBidManager.h"
#import "PBBidResponse.h"
#import "PBException.h"
#import "PBInterstitialAdUnit.h"
#import "PBMockServerAdapter.h"
#import <XCTest/XCTest.h>

NSString *const kBidManagerTestAdUnitId = @"TestAdUnitId";

@interface PBBidManager (Testing)

@property (nonatomic, strong) NSMutableSet<PBAdUnit *> *adUnits;
@property (nonatomic, strong) NSMutableDictionary <NSString *, PBBidResponse *> *__nullable bidsMap;
@property (nonatomic, strong) PBServerAdapter *demandAdapter;
- (void)startNewAuction:(PBAdUnit *)adUnit;
- (void)saveBidResponses:(nonnull NSArray<PBBidResponse *> *)bidResponse;
- (void)checkForBidsExpired;
- (void)registerAdUnit:(PBAdUnit *)adUnit;
- (NSArray<PBBidResponse *> *)getBids:(PBAdUnit *)adUnit;

@end

@interface PBBidManagerTests : XCTestCase

@property (nonatomic, strong) NSString *accountId;

@end

@implementation PBBidManagerTests

- (void)setUp {
    self.accountId = @"aecd6ef7-b992-4e99-9bb8-65e2d984e1dd";
    [super setUp];
}

- (void)tearDown {
    [PBBidManager resetSharedInstance];
    [super tearDown];
}

#pragma mark - Test register ad units tests

- (void)testRegisterBannerAdUnit {
    PBAdUnit *returnedUnit = nil;
    PBAdUnit *bannerAdUnit = [[PBBannerAdUnit alloc] initWithAdUnitIdentifier:@"bmt1" andConfigId:@"0b33e7ae-cf61-4003-8404-0711eea6e673"];
    [bannerAdUnit addSize:CGSizeMake(320, 50)];

    [[PBBidManager sharedInstance] registerAdUnits:@[bannerAdUnit] withAccountId:self.accountId];
    returnedUnit = [[PBBidManager sharedInstance] adUnitByIdentifier:[bannerAdUnit identifier]];

    XCTAssertNotNil(returnedUnit);
    XCTAssertEqualObjects(returnedUnit.identifier, bannerAdUnit.identifier);
}

- (void)testRegisterInterstitialAdUnit {
    PBAdUnit *returnedUnit = nil;
    PBAdUnit *interstitialAdUnit = [[PBInterstitialAdUnit alloc] initWithAdUnitIdentifier:@"bmt2" andConfigId:@"0b33e7ae-cf61-4003-8404-0711eea6e673"];

    [[PBBidManager sharedInstance] registerAdUnits:@[interstitialAdUnit] withAccountId:self.accountId];
    returnedUnit = [[PBBidManager sharedInstance] adUnitByIdentifier:[interstitialAdUnit identifier]];

    XCTAssertNotNil(returnedUnit);
    XCTAssertEqualObjects(returnedUnit.identifier, interstitialAdUnit.identifier);
}

- (void)testRegisterMultipleAdUnits {
    PBAdUnit *returnedAdUnit = nil;
    PBAdUnit *returnedInterstitialAdUnit = nil;
    PBAdUnit *bannerAdUnit = [[PBBannerAdUnit alloc] initWithAdUnitIdentifier:@"bmt3" andConfigId:@"0b33e7ae-cf61-4003-8404-0711eea6e673"];
    [bannerAdUnit addSize:CGSizeMake(320, 50)];
    PBAdUnit *interstitialAdUnit = [[PBInterstitialAdUnit alloc] initWithAdUnitIdentifier:@"bmt4" andConfigId:@"0b33e7ae-cf61-4003-8404-0711eea6e673"];

    [[PBBidManager sharedInstance] registerAdUnits:@[bannerAdUnit, interstitialAdUnit] withAccountId:self.accountId];
    returnedAdUnit = [[PBBidManager sharedInstance] adUnitByIdentifier:[bannerAdUnit identifier]];
    returnedInterstitialAdUnit = [[PBBidManager sharedInstance] adUnitByIdentifier:[interstitialAdUnit identifier]];

    XCTAssertNotNil(returnedAdUnit);
    XCTAssertEqualObjects(returnedAdUnit.identifier, bannerAdUnit.identifier);
    XCTAssertNotNil(returnedInterstitialAdUnit);
    XCTAssertEqualObjects(returnedInterstitialAdUnit.identifier, interstitialAdUnit.identifier);
}

- (void)testRegisterBannerAdUnitNoSizeException {
    PBBannerAdUnit *bannerAdUnit = [[PBBannerAdUnit alloc] initWithAdUnitIdentifier:@"bmt4" andConfigId:@"0b33e7ae-cf61-4003-8404-0711eea6e673"];
    @try {
        [[PBBidManager sharedInstance] registerAdUnits:@[bannerAdUnit] withAccountId:self.accountId];
    } @catch (PBException *exception) {
        NSExceptionName expectedException = @"PBAdUnitNoSizeException";
        XCTAssertNotNil(exception);
        XCTAssertEqual(exception.name, expectedException);
    }
    PBAdUnit *returnedAdUnit = [[PBBidManager sharedInstance] adUnitByIdentifier:[bannerAdUnit identifier]];
    XCTAssertNil(returnedAdUnit);
}

- (void)testRegisterAdUnitWithSameIdentifier {
    PBAdUnit *returnedUnit = nil;
    PBAdUnit *bannerAdUnit1 = [[PBBannerAdUnit alloc] initWithAdUnitIdentifier:@"sameid" andConfigId:@"0b33e7ae-cf61-4003-8404-0711eea6e673"];
    [bannerAdUnit1 addSize:CGSizeMake(320, 50)];
    PBAdUnit *bannerAdUnit2 = [[PBBannerAdUnit alloc] initWithAdUnitIdentifier:@"sameid" andConfigId:@"0b33e7ae-cf61-4003-8404-0711eea6e673"];
    [bannerAdUnit2 addSize:CGSizeMake(320, 50)];

    [[PBBidManager sharedInstance] registerAdUnits:@[bannerAdUnit1, bannerAdUnit2] withAccountId:self.accountId];
    returnedUnit = [[PBBidManager sharedInstance] adUnitByIdentifier:[bannerAdUnit1 identifier]];

    XCTAssertNotNil(returnedUnit);
    XCTAssertEqualObjects(returnedUnit.identifier, bannerAdUnit1.identifier);
}

#pragma mark - Test winning bid for ad unit

- (void)testWinningBidForAdUnit {
    PBAdUnit *bannerAdUnit = [[PBBannerAdUnit alloc] initWithAdUnitIdentifier:@"bmt45" andConfigId:@"0b33e7ae-cf61-4003-8404-0711eea6e673"];
    [bannerAdUnit addSize:CGSizeMake(320, 50)];
    [[PBBidManager sharedInstance] registerAdUnits:@[bannerAdUnit] withAccountId:self.accountId];
    
    NSDictionary *testAdServerTargeting = @{@"hb_pb":@"4.14", @"hb_cache_id":@"0000-0000-000-0000"};
    PBBidResponse *bidResponse = [PBBidResponse bidResponseWithAdUnitId:bannerAdUnit.identifier adServerTargeting:testAdServerTargeting];
    NSDictionary *testAdServerTargeting2 = @{@"hb_pb_appnexus":@"0.14", @"hb_cache_id_appnexus":@"0000-0000-000-0000"};
    PBBidResponse *bidResponse2 = [PBBidResponse bidResponseWithAdUnitId:bannerAdUnit.identifier adServerTargeting:testAdServerTargeting2];
    [[PBBidManager sharedInstance] saveBidResponses:@[bidResponse, bidResponse2]];

    NSArray *bids = [[PBBidManager sharedInstance] getBids:bannerAdUnit];
    PBBidResponse *topBid = [bids firstObject];
    XCTAssertEqual([bids count], 2);
    XCTAssertEqual(topBid.customKeywords[@"hb_pb"], @"4.14");
}

#pragma mark - Test keywords for winning bid for ad unit tests

- (void)testKeywordsForWinningBidForAdUnit {
    PBAdUnit *bannerAdUnit = [[PBBannerAdUnit alloc] initWithAdUnitIdentifier:@"bmt5" andConfigId:@"0b33e7ae-cf61-4003-8404-0711eea6e673"];
    [bannerAdUnit addSize:CGSizeMake(320, 50)];
    [[PBBidManager sharedInstance] registerAdUnits:@[bannerAdUnit] withAccountId:self.accountId];
    
    NSDictionary *testAdServerTargeting = @{@"hb_pb":@"4.14", @"hb_cache_id":@"0000-0000-000-0000", @"hb_bidder": @"appnexus"};
    PBBidResponse *bidResponse = [PBBidResponse bidResponseWithAdUnitId:bannerAdUnit.identifier adServerTargeting:testAdServerTargeting];
    [[PBBidManager sharedInstance] saveBidResponses:@[bidResponse]];

    NSDictionary *keywords = [[PBBidManager sharedInstance] keywordsForWinningBidForAdUnit:bannerAdUnit];
    NSDictionary *expectedKeywords = @{@"hb_pb": @"4.14",
                                       @"hb_cache_id" : @"0000-0000-000-0000",
                                       @"hb_bidder" : @"appnexus"};
    XCTAssertTrue([keywords isEqualToDictionary:expectedKeywords]);
}

#pragma mark - Test assert ad unit registered tests

- (void)testAssertAdUnitRegistered {
    PBAdUnit *bannerAdUnit = [[PBBannerAdUnit alloc] initWithAdUnitIdentifier:@"bmt6" andConfigId:@"0b33e7ae-cf61-4003-8404-0711eea6e673"];
    [bannerAdUnit addSize:CGSizeMake(320, 50)];
    [[PBBidManager sharedInstance] registerAdUnits:@[bannerAdUnit] withAccountId:self.accountId];
    [[PBBidManager sharedInstance] assertAdUnitRegistered:bannerAdUnit.identifier];
}

- (void)testAssertAdUnitNotRegistered {
    PBAdUnit *bannerAdUnit = [[PBBannerAdUnit alloc] initWithAdUnitIdentifier:@"bmt7" andConfigId:@"0b33e7ae-cf61-4003-8404-0711eea6e673"];
    [bannerAdUnit addSize:CGSizeMake(320, 50)];
    @try {
        [[PBBidManager sharedInstance] assertAdUnitRegistered:bannerAdUnit.identifier];
    } @catch (PBException *exception) {
        NSExceptionName expectedException = @"PBAdUnitNotRegisteredException";
        XCTAssertNotNil(exception);
        XCTAssertEqual(exception.name, expectedException);
    }
    PBAdUnit *returnedAdUnit = [[PBBidManager sharedInstance] adUnitByIdentifier:[bannerAdUnit identifier]];
    XCTAssertNil(returnedAdUnit);
}

#pragma mark - Test attach top bid helper tests

- (void)testAttachTopBidHelperWithReadyBid {
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    PBAdUnit *adUnit = [[PBBannerAdUnit alloc] initWithAdUnitIdentifier:@"bmt8" andConfigId:@"0b33e7ae-cf61-4003-8404-0711eea6e673"];
    [adUnit addSize:CGSizeMake(320, 50)];
    [[PBBidManager sharedInstance] registerAdUnits:@[adUnit] withAccountId:self.accountId];

    NSDictionary *testAdServerTargeting = @{@"hb_pb":@"4.14", @"hb_cache_id":@"0000-0000-000-0000", @"hb_bidder": @"appnexus"};
    PBBidResponse *bidResponse = [PBBidResponse bidResponseWithAdUnitId:adUnit.identifier adServerTargeting:testAdServerTargeting];
    [[PBBidManager sharedInstance] saveBidResponses:@[bidResponse]];

    [[PBBidManager sharedInstance] attachTopBidHelperForAdUnitId:adUnit.identifier andTimeout:500 completionHandler:^{
        NSDictionary *bidKeywords = [[PBBidManager sharedInstance] keywordsForWinningBidForAdUnit:adUnit];
        XCTAssertNotNil(bidKeywords);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testAttachTopBidHelperWithReadyBidAfterSomeTime {
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    PBAdUnit *adUnit = [[PBBannerAdUnit alloc] initWithAdUnitIdentifier:@"bmt9" andConfigId:@"0b33e7ae-cf61-4003-8404-0711eea6e673"];
    [adUnit addSize:CGSizeMake(320, 50)];
    [[PBBidManager sharedInstance] registerAdUnits:@[adUnit] withAccountId:self.accountId];

    // Save a bid after 200 milliseconds - before the timeout of 500 ms but not immediately
    NSDictionary *testAdServerTargeting = @{@"hb_pb":@"4.14", @"hb_cache_id":@"0000-0000-000-0000", @"hb_bidder": @"appnexus"};
    PBBidResponse *bidResponse = [PBBidResponse bidResponseWithAdUnitId:adUnit.identifier adServerTargeting:testAdServerTargeting];
    NSArray *array = [NSArray arrayWithObjects:bidResponse, nil];
    [[PBBidManager sharedInstance] performSelector:@selector(saveBidResponses:) withObject:array afterDelay:0.2];

    [[PBBidManager sharedInstance] attachTopBidHelperForAdUnitId:adUnit.identifier andTimeout:500 completionHandler:^{
        NSDictionary *bidKeywords = [[PBBidManager sharedInstance] keywordsForWinningBidForAdUnit:adUnit];
        XCTAssertNotNil(bidKeywords);
        [expectation fulfill];
    }];
    // Wait for the expectation for 1 second
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testAttachTopBidHelperWithNoReadyBid {
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    PBAdUnit *adUnit = [[PBBannerAdUnit alloc] initWithAdUnitIdentifier:@"bmt10" andConfigId:@"0b33e7ae-cf61-4003-8404-0711eea6e673"];
    [adUnit addSize:CGSizeMake(320, 50)];
    [[PBBidManager sharedInstance] registerAdUnits:@[adUnit] withAccountId:self.accountId];

    [[PBBidManager sharedInstance] attachTopBidHelperForAdUnitId:adUnit.identifier andTimeout:500 completionHandler:^{
        NSDictionary *bidKeywords = [[PBBidManager sharedInstance] keywordsForWinningBidForAdUnit:adUnit];
        XCTAssertNil(bidKeywords);
        [expectation fulfill];
    }];
    // Wait for the expectation for 1 second
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

#pragma mark - Test start new auction tests

- (void)testStartNewAuction {
    PBAdUnit *adUnit = [[PBBannerAdUnit alloc] initWithAdUnitIdentifier:@"bmt11" andConfigId:@"0b33e7ae-cf61-4003-8404-0711eea6e673"];
    [adUnit addSize:CGSizeMake(320, 50)];
    NSString *originalUUID = adUnit.uuid;
    [[PBBidManager sharedInstance] registerAdUnits:@[adUnit] withAccountId:self.accountId];
    
    NSDictionary *testAdServerTargeting = @{@"hb_pb":@"4.14", @"hb_cache_id":@"0000-0000-000-0000", @"hb_bidder": @"appnexus"};
    PBBidResponse *bidResponse = [PBBidResponse bidResponseWithAdUnitId:adUnit.identifier adServerTargeting:testAdServerTargeting];
    [[PBBidManager sharedInstance] saveBidResponses:@[bidResponse]];

    XCTAssertNotNil([[[PBBidManager sharedInstance] bidsMap] objectForKey:adUnit.identifier]);

    [[PBBidManager sharedInstance] startNewAuction:adUnit];

    XCTAssertNil([[[PBBidManager sharedInstance] bidsMap] objectForKey:adUnit.identifier]);
    XCTAssertFalse([originalUUID isEqualToString:adUnit.uuid]);
}

#pragma mark - Test bids expired tests

- (void)testCheckForBidsExpired {
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    // This test is a bit confusing. The first ad unit is registered to initialize Prebid and the ad units set using the public API.
    PBAdUnit *adUnitTest = [[PBBannerAdUnit alloc] initWithAdUnitIdentifier:@"bmt21" andConfigId:@"0b33e7ae-cf61-4003-8404-0711eea6e673"];
    [adUnitTest addSize:CGSizeMake(320, 50)];
    [[PBBidManager sharedInstance] registerAdUnits:@[adUnitTest] withAccountId:self.accountId];

    // We initialize this ad unit using the private function to ensure a request doesn't go out and the timeToExpireAfter doesn't get reset
    // to 4 min and 30 seconds instead of 1 second for testing.
    PBAdUnit *adUnit = [[PBBannerAdUnit alloc] initWithAdUnitIdentifier:@"bmt12" andConfigId:@"0b33e7ae-cf61-4003-8404-0711eea6e673"];
    [adUnit addSize:CGSizeMake(320, 50)];
    [[PBBidManager sharedInstance] registerAdUnit:adUnit];
    
    NSDictionary *testAdServerTargeting = @{@"hb_pb":@"4.14", @"hb_cache_id":@"0000-0000-000-0000", @"hb_bidder": @"appnexus"};
    PBBidResponse *bidResponse = [PBBidResponse bidResponseWithAdUnitId:adUnit.identifier adServerTargeting:testAdServerTargeting];
    bidResponse.timeToExpireAfter = 1;
    [[PBBidManager sharedInstance] saveBidResponses:@[bidResponse]];

    NSString *originalUUID = adUnit.uuid;

    double delayInSeconds = 2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [[PBBidManager sharedInstance] checkForBidsExpired];
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:3 handler:^(NSError *error){
        XCTAssertFalse([originalUUID isEqualToString:adUnit.uuid]);
    }];
}

- (void)testCheckForBidsExpiredNoBid {
    PBAdUnit *adUnit = [[PBBannerAdUnit alloc] initWithAdUnitIdentifier:@"bmt13" andConfigId:@"0b33e7ae-cf61-4003-8404-0711eea6e673"];
    [adUnit addSize:CGSizeMake(320, 50)];
    [[PBBidManager sharedInstance] registerAdUnits:@[adUnit] withAccountId:self.accountId];

    // On no bid response bids should not be considered expired
    NSString *originalUUID = adUnit.uuid;

    [[PBBidManager sharedInstance] checkForBidsExpired];
    XCTAssertTrue([originalUUID isEqualToString:adUnit.uuid]);
}

@end
