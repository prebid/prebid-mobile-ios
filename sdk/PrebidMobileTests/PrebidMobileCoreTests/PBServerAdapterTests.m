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

#import <XCTest/XCTest.h>
#import "PBServerAdapter.h"
#import "PBServerHost.h"

static NSString *const kPrebidMobileVersion = @"0.1.1";
static NSString *const kAPNPrebidServerUrl = @"https://prebid.adnxs.com/pbs/v1/auction";
static NSString *const kRPPrebidServerUrl = @"https://prebid-server.rubiconproject.com/auction";

@interface PBServerAdapter (Testing)

- (NSURLRequest *)buildRequestForAdUnits:(NSArray<PBAdUnit *> *)adUnits;
- (NSDictionary *)requestBodyForAdUnits:(NSArray<PBAdUnit *> *)adUnits;

@end

@interface PBServerAdapterTests : XCTestCase

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
    PBServerAdapter *serverAdapter = [[PBServerAdapter alloc] initWithAccountId:@"test_account_id"];
    NSDictionary *requestBody = [serverAdapter requestBodyForAdUnits:self.adUnits];

    XCTAssertEqualObjects(requestBody[@"account_id"], @"test_account_id");
    XCTAssertEqualObjects(requestBody[@"max_key_length"], @(20));
    XCTAssertEqualObjects(requestBody[@"sort_bids"], @(1));
    XCTAssertEqualObjects(requestBody[@"cache_markup"], @(1));

    NSDictionary *app = requestBody[@"app"];
    XCTAssertEqualObjects(app[@"ver"], kPrebidMobileVersion);

    NSDictionary *sdk = requestBody[@"sdk"];
    XCTAssertEqualObjects(sdk[@"version"], kPrebidMobileVersion);
    XCTAssertEqualObjects(sdk[@"platform"], @"iOS");
    XCTAssertEqualObjects(sdk[@"source"], @"prebid-mobile");

    NSDictionary *device = requestBody[@"device"];
    XCTAssertEqualObjects(device[@"os"], @"iOS");
    XCTAssertEqualObjects(device[@"make"], @"Apple");

    NSArray *requestAdUnits = requestBody[@"ad_units"];
    NSDictionary *jsonAdUnit = (NSDictionary *)[requestAdUnits firstObject];
    XCTAssertEqualObjects(jsonAdUnit[@"config_id"], @"test_config_id");
    XCTAssertEqualObjects(jsonAdUnit[@"code"], @"test_identifier");
    NSArray *sizesArray = jsonAdUnit[@"sizes"];
    XCTAssertTrue([sizesArray count] == 1);
}

- (void)testBuildRequestForAdUnits {
    PBServerAdapter *serverAdapter = [[PBServerAdapter alloc] initWithAccountId:@"test_account_id"];
    NSURLRequest *request = [serverAdapter buildRequestForAdUnits:self.adUnits];
    
    // Test default host
    XCTAssertEqualObjects(request.URL, [NSURL URLWithString:kAPNPrebidServerUrl]);

    [[PBServerHost sharedInstance] setPbsHost:PBSHostRubicon];
    request = [serverAdapter buildRequestForAdUnits:self.adUnits];
    XCTAssertEqualObjects(request.URL, [NSURL URLWithString:kRPPrebidServerUrl]);
    
    [[PBServerHost sharedInstance] setPbsHost:PBSHostAppNexus];
    request = [serverAdapter buildRequestForAdUnits:self.adUnits];
    XCTAssertEqualObjects(request.URL, [NSURL URLWithString:kAPNPrebidServerUrl]);
}

@end
