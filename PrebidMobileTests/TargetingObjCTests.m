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
#import <CoreLocation/CoreLocation.h>
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

@interface TargetingObjCTests : XCTestCase

@end

@implementation TargetingObjCTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    Targeting.shared.coppa = nil;
    Targeting.shared.subjectToGDPR = nil;
    Targeting.shared.gdprConsentString = nil;
    Targeting.shared.purposeConsents = nil;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IABConsent_SubjectToGDPR"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IABConsent_SubjectToGDPR"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IABTCF_gdprApplies"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IABConsent_ConsentString"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IABTCF_TCString"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IABTCF_PurposeConsents"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [Targeting.shared clearAppExtData];
    [Targeting.shared clearAppKeywords];
    [Targeting.shared clearAccessControlList];
}

- (void)testStoreURL {
    //given
    NSString *storeURL = @"https://itunes.apple.com/app/id123456789";
    
    //when
    Targeting.shared.storeURL = storeURL;
    NSString *result = Targeting.shared.storeURL;

    //then
    XCTAssertEqualObjects(storeURL, result);
}

- (void)testDomain {
    //given
    NSString *domain = @"appdomain.com";
    
    //when
    Targeting.shared.domain = domain;
    NSString *result = Targeting.shared.domain;

    //then
    XCTAssertEqualObjects(domain, result);
}

- (void)testItunesID {
    //given
    NSString *itunesID = @"54673893";
    
    //when
    Targeting.shared.itunesID = itunesID;
    NSString *result = Targeting.shared.itunesID;

    //then
    XCTAssertEqualObjects(itunesID, result);
}

- (void)testOmidPartnerNameAndVersion {
    //given
    NSString *partnerName = @"PartnerName";
    NSString *partnerVersion = @"1.0";
    
    //when
    Targeting.shared.omidPartnerName = partnerName;
    Targeting.shared.omidPartnerVersion = partnerVersion;

    //then
    XCTAssertEqualObjects(partnerName, Targeting.shared.omidPartnerName);
    XCTAssertEqualObjects(partnerVersion, Targeting.shared.omidPartnerVersion);
}

- (void)testLocation {
    
    //given
    CLLocation *location = [[CLLocation alloc] initWithLatitude:100 longitude:100];
    
    //when
    Targeting.shared.location = location;
    
    //then
    XCTAssertEqual(location, Targeting.shared.location);
    
}

//MARK: - COPPA
- (void)testSubjectToCOPPA {
    //given
    Targeting.shared.coppa = @(1);
    
    //then
    XCTAssertTrue([Targeting.shared.coppa isEqual:@(1)]);
    
    //defer
    Targeting.shared.coppa = nil;
}

//MARK: - GDPR Subject

- (void)testSubjectToGDPR_PB {
    //given
    NSNumber *subjectToGDPR1 = @YES;
    BOOL subjectToGDPR2 = YES;
    NSNumber *subjectToGDPR3 = @YES;
    NSNumber *subjectToGDPR4 = nil;
    
    //when
    [Targeting.shared setSubjectToGDPR:subjectToGDPR1];
    NSNumber *result1 = [Targeting.shared getSubjectToGDPR];
    
    [Targeting.shared setSubjectToGDPR:[NSNumber numberWithBool:subjectToGDPR2]];
    BOOL result2 = [[Targeting.shared getSubjectToGDPR] boolValue];
    
    [Targeting.shared setSubjectToGDPR:subjectToGDPR3];
    BOOL result3 = [Targeting.shared getSubjectToGDPR];
    
    [Targeting.shared setSubjectToGDPR:subjectToGDPR4];
    NSNumber *result4 = [Targeting.shared getSubjectToGDPR];

    //then
    XCTAssertEqualObjects(subjectToGDPR1, result1);
    XCTAssertEqual(subjectToGDPR2, result2);
    XCTAssertEqual(YES, result3);
    XCTAssertNil(result4);
    
}

//MARK: - GDPR Consent
- (void)testGdprConsentStringPB {
    //given
    Targeting.shared.gdprConsentString = @"testconsent PB";
    
    //when
    NSString *gdprConsent = Targeting.shared.gdprConsentString;

    //then
    XCTAssertEqualObjects(@"testconsent PB", gdprConsent);
    
    //defer
    Targeting.shared.gdprConsentString = nil;
}

//MARK: - PurposeConsents
- (void)testPurposeConsentsPB {
    //given
    NSString *purposeConsents = @"100000000000000000000000";
    Targeting.shared.purposeConsents = purposeConsents;
    
    //when
    NSString *result = Targeting.shared.purposeConsents;

    //then
    XCTAssertEqualObjects(purposeConsents, result);
    
    //defer
    Targeting.shared.purposeConsents = nil;
}

- (void)testGetDeviceAccessConsent {
    //given
    Targeting.shared.purposeConsents = @"100000000000000000000000";

    //when
    NSNumber *deviceAccessConsent = [Targeting.shared getDeviceAccessConsentObjc];

    //then
    XCTAssertEqual(1, deviceAccessConsent.intValue);
    
    //defer
    Targeting.shared.purposeConsents = nil;
}

- (void)testAccessControlList {
    //given
    NSString *bidderName = @"test-bidder";
    
    //when
    [Targeting.shared addBidderToAccessControlList:bidderName];
    [Targeting.shared removeBidderFromAccessControlList:bidderName];
    [Targeting.shared clearAccessControlList];
}

// MARK: - app.ext.data

- (void)testExtData {
     //given
     NSString *key = @"key1";
     NSString *value = @"value10";
     NSMutableSet *set = [[NSMutableSet alloc] initWithArray:@[@"a", @"b"]];

     //when
     [Targeting.shared addAppExtDataWithKey:key value:value];
     [Targeting.shared updateAppExtDataWithKey:key value:set];
     [Targeting.shared removeAppExtDataFor:key];
     [Targeting.shared clearAppExtData];
 }

- (void)testUserKeyword {
    //given
    NSString *keyword = @"keyword";
    NSMutableSet *set = [[NSMutableSet alloc] initWithArray:@[@"a", @"b"]];
    
    //when
    [Targeting.shared addUserKeyword:keyword];
    [Targeting.shared addUserKeywords:set];
    [Targeting.shared removeUserKeyword:keyword];
    [Targeting.shared clearUserKeywords];
}

// MARK: - app.keywords

- (void)testExtKeyword {
    //given
    NSString *keyword = @"keyword";
    NSMutableSet *set = [[NSMutableSet alloc] initWithArray:@[@"a", @"b"]];
    
    //when
    [Targeting.shared addAppKeyword:keyword];
    [Targeting.shared addAppKeywords:set];
    [Targeting.shared removeAppKeyword:keyword];
    [Targeting.shared clearAppKeywords];
}

@end
