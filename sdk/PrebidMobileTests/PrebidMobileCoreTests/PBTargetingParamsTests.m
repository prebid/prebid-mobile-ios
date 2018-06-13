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

#import "PBTargetingParams.h"
#import <XCTest/XCTest.h>

@interface PBTargetingParamsTests : XCTestCase

@end

@implementation PBTargetingParamsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    [PBTargetingParams resetSharedInstance];
    [super tearDown];
}

- (void)testSetGenderTargeting {
    // Test default gender is unknown
    XCTAssertEqual(PBTargetingParamsGenderUnknown, [[PBTargetingParams sharedInstance] gender]);

    [[PBTargetingParams sharedInstance] setGender:PBTargetingParamsGenderFemale];
    XCTAssertEqual(PBTargetingParamsGenderFemale, [[PBTargetingParams sharedInstance] gender]);
    [[PBTargetingParams sharedInstance] setGender:PBTargetingParamsGenderMale];
    XCTAssertEqual(PBTargetingParamsGenderMale, [[PBTargetingParams sharedInstance] gender]);
    [[PBTargetingParams sharedInstance] setGender:PBTargetingParamsGenderUnknown];
    XCTAssertEqual(PBTargetingParamsGenderUnknown, [[PBTargetingParams sharedInstance] gender]);
}

- (void)testSetLocationTargeting {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:100.0 longitude:100.0];
    [[PBTargetingParams sharedInstance] setLocation:location];
    [[PBTargetingParams sharedInstance] setLocationPrecision:2];
    XCTAssertEqual(location, [[PBTargetingParams sharedInstance] location]);
    XCTAssertEqual(2, [[PBTargetingParams sharedInstance] locationPrecision]);
}

- (void)testSetUserKeywordsWithValue {
    [[PBTargetingParams sharedInstance] setUserKeywords:@"targeting1" withValue:@"value1"];
    [[PBTargetingParams sharedInstance] setUserKeywords:@"targeting2" withValue:@"value2"];
    NSDictionary *customKeywords = [[PBTargetingParams sharedInstance] userKeywords];
    NSDictionary *expectedCustomKeywords = @{@"targeting1" : @[@"value1"], @"targeting2" : @[@"value2"]};
    XCTAssertTrue([customKeywords isEqualToDictionary:expectedCustomKeywords]);
}

- (void)testSetUserKeywordsWithMultipleValues {
    [[PBTargetingParams sharedInstance] setUserKeywords:@"targeting1" withValues:@[@"value1", @"value2", @"value3"]];
    [[PBTargetingParams sharedInstance] setUserKeywords:@"targeting2" withValue:@"value2"];
    NSDictionary *customKeywords = [[PBTargetingParams sharedInstance] userKeywords];
    NSDictionary *expectedCustomKeywords = @{@"targeting1" : @[@"value2", @"value1", @"value3"], @"targeting2" : @[@"value2"]};
    XCTAssertTrue([customKeywords isEqualToDictionary:expectedCustomKeywords]);
}

- (void)testSetUserKeywordsWithDuplicateValues {
    [[PBTargetingParams sharedInstance] setUserKeywords:@"targeting1" withValues:@[@"value2", @"value1", @"value3"]];
    [[PBTargetingParams sharedInstance] setUserKeywords:@"targeting1" withValue:@"value2"];
    NSDictionary *customKeywords = [[PBTargetingParams sharedInstance] userKeywords];
    NSDictionary *expectedCustomKeywords = @{@"targeting1" : @[@"value2"]};
    XCTAssertTrue([customKeywords isEqualToDictionary:expectedCustomKeywords]);
}

- (void)testRemoveUserKeywordWithKey {
    [[PBTargetingParams sharedInstance] setUserKeywords:@"targeting1" withValue:@"value1"];
    [[PBTargetingParams sharedInstance] setUserKeywords:@"targeting2" withValue:@"value2"];
    [[PBTargetingParams sharedInstance] removeUserKeywordWithKey:@"targeting2"];
    NSDictionary *customKeywords = [[PBTargetingParams sharedInstance] userKeywords];
    NSDictionary *expectedCustomKeywords = @{@"targeting1" : @[@"value1"]};
    XCTAssertTrue([customKeywords isEqualToDictionary:expectedCustomKeywords]);
}

- (void)testRemoveUserKeywords {
    [[PBTargetingParams sharedInstance] setUserKeywords:@"targeting1" withValue:@"value1"];
    [[PBTargetingParams sharedInstance] setUserKeywords:@"targeting2" withValue:@"value2"];
    XCTAssertNotNil([[PBTargetingParams sharedInstance] userKeywords]);
    [[PBTargetingParams sharedInstance] removeUserKeywords];
    XCTAssertNil([[PBTargetingParams sharedInstance] userKeywords]);
}

-(void) testGDPRConsentString {
    [[PBTargetingParams sharedInstance] setGdprConsentString:@"testconsent"];
    XCTAssertNotNil([[PBTargetingParams sharedInstance] gdprConsentString]);
    NSString *value = [[PBTargetingParams sharedInstance] gdprConsentString];
    
    XCTAssertTrue([value isEqualToString:@"testconsent"]);
}

-(void) testGDPREnable {
    [[PBTargetingParams sharedInstance] setSubjectToGDPR:FALSE];
    BOOL testGDPR = [[PBTargetingParams sharedInstance] subjectToGDPR];
    
    XCTAssertFalse(testGDPR);
}

@end
