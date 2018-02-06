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

#import <XCTest/XCTest.h>
#import "PBServerRequestBuilder.h"
#import "PBServerAdapter.h"
#import "PBException.h"
#import "PBHost.h"

static NSString *const kPrebidMobileVersion = @"0.1.1";
static NSString *const kAPNPrebidServerUrl = @"https://prebid.adnxs.com/pbs/v1/auction";
static NSString *const kRPPrebidServerUrl = @"https://prebid-server.rubiconproject.com/auction";


@interface PBServerAdapterTests : XCTestCase<PBBidResponseDelegate>

@property (nonatomic, strong) NSArray *adUnits;

@end

@implementation PBServerAdapterTests

- (void)setUp {
    [super setUp];
    PBAdUnit *adUnit = [[PBAdUnit alloc] initWithIdentifier:@"test_identifier" andAdType:PBAdUnitTypeBanner andConfigId:@"test_config_id"];
    [adUnit addSize:CGSizeMake(250, 300)];
    self.adUnits = @[adUnit];
}

- (void)tearDown {
    self.adUnits = nil;
    [super tearDown];
}


- (void)testRequestBodyForAdUnit {
    
    NSURL *hostURL = [NSURL URLWithString:kAPNPrebidServerUrl];
    
    [[PBServerRequestBuilder sharedInstance] setHostURL: hostURL];
    NSURLRequest *request = [[PBServerRequestBuilder sharedInstance] buildRequest:self.adUnits withAccountId:@"account_id" shouldCacheLocal:NO withSecureParams:NO];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Dummy expectation"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        
        
        NSError* error;
        NSDictionary* requestBody = [NSJSONSerialization JSONObjectWithData:[request HTTPBody]
                                                                    options:kNilOptions
                                                                      error:&error];
        
        XCTAssertNotNil(requestBody);
        
        XCTAssertEqualObjects(requestBody[@"app"][@"publisher"][@"id"], @"account_id");
        
        NSDictionary *app = requestBody[@"app"][@"ext"][@"prebid"];
        XCTAssertEqualObjects(app[@"version"], kPrebidMobileVersion);
        
        XCTAssertEqualObjects(app[@"source"], @"prebid-mobile");
        
        NSDictionary *device = requestBody[@"device"];
        XCTAssertEqualObjects(device[@"os"], @"iOS");
        XCTAssertEqualObjects(device[@"make"], @"Apple");
        
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:20.0 handler:nil];
}

- (void)testBuildRequestForAdUnitsInvalidHost {
    PBServerAdapter *serverAdapter = [[PBServerAdapter alloc] initWithAccountId:@"test_account_id" andHost:PBServerHostAppNexus];
    @try {
        [serverAdapter requestBidsWithAdUnits:self.adUnits withDelegate:self];
    } @catch (PBException *exception) {
        NSExceptionName expectedException = @"PBHostInvalidException";
        XCTAssertNotNil(exception);
        XCTAssertEqual(exception.name, expectedException);
    }
}

- (void)testBuildRequestForAdUnitsValidHost {
    
    NSURL *hostURL = [NSURL URLWithString:kRPPrebidServerUrl];
    
    [[PBServerRequestBuilder sharedInstance] setHostURL: hostURL];
    NSURLRequest *request = [[PBServerRequestBuilder sharedInstance] buildRequest:self.adUnits withAccountId:@"account_id" shouldCacheLocal:NO withSecureParams:NO];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Dummy expectation"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        
        XCTAssertEqualObjects(request.URL, [NSURL URLWithString:kRPPrebidServerUrl]);
        
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:20.0 handler:nil];

}

- (void)testRequestBodyForAdUnitWithDFPAdServer {
    
    NSURL *hostURL = [NSURL URLWithString:kAPNPrebidServerUrl];
    
    [[PBServerRequestBuilder sharedInstance] setHostURL: hostURL];
    NSURLRequest *request = [[PBServerRequestBuilder sharedInstance] buildRequest:self.adUnits withAccountId:@"account_id" shouldCacheLocal:YES withSecureParams:NO];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Dummy expectation"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        
        
        NSError* error;
        NSDictionary* requestBody = [NSJSONSerialization JSONObjectWithData:[request HTTPBody]
                                                                    options:kNilOptions
                                                                      error:&error];
        
        XCTAssertNotNil(requestBody);
        
        XCTAssertNil(requestBody[@"ext"][@"prebid"][@"cache"]);
        
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:20.0 handler:nil];
    
    
}

- (void)testRequestBodyForAdUnitWithMoPubAdServer {
    NSURL *hostURL = [NSURL URLWithString:kAPNPrebidServerUrl];
    
    [[PBServerRequestBuilder sharedInstance] setHostURL: hostURL];
    NSURLRequest *request = [[PBServerRequestBuilder sharedInstance] buildRequest:self.adUnits withAccountId:@"account_id" shouldCacheLocal:NO withSecureParams:NO];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Dummy expectation"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        
        
        NSError* error;
        NSDictionary* requestBody = [NSJSONSerialization JSONObjectWithData:[request HTTPBody]
                                                                    options:kNilOptions
                                                                      error:&error];
        
        XCTAssertNotNil(requestBody);
        
        XCTAssertNotNil(requestBody[@"ext"][@"prebid"][@"cache"]);
        
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:20.0 handler:nil];

    
}

-(void) testBatchRequestBidsWithAdUnits{
    PBAdUnit *adUnit1 = [[PBAdUnit alloc] initWithIdentifier:@"test1" andAdType:PBAdUnitTypeBanner andConfigId:@"config1"];
    [adUnit1 addSize:CGSizeMake(250, 300)];
    
    PBAdUnit *adUnit2 = [[PBAdUnit alloc] initWithIdentifier:@"test2" andAdType:PBAdUnitTypeBanner andConfigId:@"config2"];
    [adUnit2 addSize:CGSizeMake(250, 300)];
    
    PBAdUnit *adUnit3 = [[PBAdUnit alloc] initWithIdentifier:@"test3" andAdType:PBAdUnitTypeBanner andConfigId:@"config3"];
    [adUnit3 addSize:CGSizeMake(250, 300)];
    
    PBAdUnit *adUnit4 = [[PBAdUnit alloc] initWithIdentifier:@"test4" andAdType:PBAdUnitTypeBanner andConfigId:@"config4"];
    [adUnit4 addSize:CGSizeMake(250, 300)];
    
    PBAdUnit *adUnit5 = [[PBAdUnit alloc] initWithIdentifier:@"test5" andAdType:PBAdUnitTypeBanner andConfigId:@"config5"];
    [adUnit5 addSize:CGSizeMake(250, 300)];
    
    PBAdUnit *adUnit6 = [[PBAdUnit alloc] initWithIdentifier:@"test6" andAdType:PBAdUnitTypeBanner andConfigId:@"config6"];
    [adUnit6 addSize:CGSizeMake(250, 300)];
    
    PBAdUnit *adUnit7 = [[PBAdUnit alloc] initWithIdentifier:@"test7" andAdType:PBAdUnitTypeBanner andConfigId:@"config7"];
    [adUnit7 addSize:CGSizeMake(250, 300)];
    
    PBAdUnit *adUnit8 = [[PBAdUnit alloc] initWithIdentifier:@"test8" andAdType:PBAdUnitTypeBanner andConfigId:@"config8"];
    [adUnit8 addSize:CGSizeMake(250, 300)];
    
    PBAdUnit *adUnit9 = [[PBAdUnit alloc] initWithIdentifier:@"test9" andAdType:PBAdUnitTypeBanner andConfigId:@"config9"];
    [adUnit9 addSize:CGSizeMake(250, 300)];
    
    PBAdUnit *adUnit10 = [[PBAdUnit alloc] initWithIdentifier:@"test10" andAdType:PBAdUnitTypeBanner andConfigId:@"config10"];
    [adUnit10 addSize:CGSizeMake(250, 300)];
    
    PBAdUnit *adUnit11 = [[PBAdUnit alloc] initWithIdentifier:@"test11" andAdType:PBAdUnitTypeBanner andConfigId:@"config11"];
    [adUnit11 addSize:CGSizeMake(250, 300)];
    
    PBAdUnit *adUnit12 = [[PBAdUnit alloc] initWithIdentifier:@"test12" andAdType:PBAdUnitTypeBanner andConfigId:@"config12"];
    [adUnit12 addSize:CGSizeMake(250, 300)];
    
    NSArray *adUnitsArray = @[adUnit1,adUnit2,adUnit3,adUnit4,adUnit5,adUnit6,adUnit7,adUnit8,adUnit9,adUnit10, adUnit11, adUnit12];
    
    PBServerAdapter *serverAdapter = [[PBServerAdapter alloc] initWithAccountId:@"test_account_id" andHost:PBServerHostAppNexus];
    @try {
        [serverAdapter requestBidsWithAdUnits:adUnitsArray withDelegate:self];
    } @catch (PBException *exception) {
        NSExceptionName expectedException = @"PBHostInvalidException";
        XCTAssertNotNil(exception);
        XCTAssertEqual(exception.name, expectedException);
    }
    
    
}

- (void)didCompleteWithError:(nonnull NSError *)error {
    
}

- (void)didReceiveSuccessResponse:(nonnull NSArray<PBBidResponse *> *)bid {
    
}

@end
