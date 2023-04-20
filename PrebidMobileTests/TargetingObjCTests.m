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
#import "PrebidMobile/PrebidMobile.h"

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
    [Targeting.shared clearUserData];
    [Targeting.shared clearUserKeywords];
    [Targeting.shared clearYearOfBirth];
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

- (void)testGender {
    //given
    int genderFemale = PBMGenderFemale;
    
    //when
    Targeting.shared.userGender = genderFemale;
    
    //then
    XCTAssertEqual(genderFemale, Targeting.shared.userGender);
}

- (void)testitunesID {
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

- (void)testLocationPrecision {
    //given
    NSNumber *locationPrecision1 = @1;
    int locationPrecision2 = 2;
    NSNumber *locationPrecision3 = @3;
    NSNumber *locationPrecision4 = nil;
    
    //when
    [Targeting.shared setLocationPrecision: locationPrecision1];
    NSNumber *result1 = [Targeting.shared getLocationPrecision];
    
    [Targeting.shared setLocationPrecision: [NSNumber numberWithInt:locationPrecision2]];
    int result2 = [[Targeting.shared getLocationPrecision] intValue];
    
    [Targeting.shared setLocationPrecision: locationPrecision3];
    int result3 = [[Targeting.shared getLocationPrecision] intValue];
    
    [Targeting.shared setLocationPrecision: locationPrecision4];
    NSNumber *result4 = [Targeting.shared getLocationPrecision];
    
    //then
    XCTAssertEqualObjects(locationPrecision1, result1);
    XCTAssertEqual(locationPrecision2, result2);
    XCTAssertEqual(3, result3);
    XCTAssertNil(result4);
    
}

// MARK: - Year Of Birth
- (void)testYearOfBirth {
    //given
    NSError *error = nil;
    int yearOfBirth = 1985;
    
    //when
    [Targeting.shared setYearOfBirthWithYob:yearOfBirth];
    long value1 = Targeting.shared.yearOfBirth;
    
    [Targeting.shared clearYearOfBirth];
    long value2 = Targeting.shared.yearOfBirth;
    
    //then
    XCTAssertNil(error);
    XCTAssertEqual(yearOfBirth, value1);
    XCTAssertEqual(0, value2);
}

- (void)testYearOfBirthInvalid {
    
    [Targeting.shared setYearOfBirthWithYob:-1];
    XCTAssertTrue(Targeting.shared.yearOfBirth == 0);
    [Targeting.shared setYearOfBirthWithYob:999];
    XCTAssertTrue(Targeting.shared.yearOfBirth == 0);
    [Targeting.shared setYearOfBirthWithYob:10000];
    XCTAssertTrue(Targeting.shared.yearOfBirth == 0);
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
- (void)testsubjectToGDPR_PB {
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
    NSString *bidderNameRubicon = Prebid.bidderNameRubiconProject;
    NSString *bidderNameAppNexus = Prebid.bidderNameAppNexus;
    
    //when
    [Targeting.shared addBidderToAccessControlList:bidderNameRubicon];
    [Targeting.shared removeBidderFromAccessControlList:bidderNameAppNexus];
    [Targeting.shared clearAccessControlList];

}

- (void)testUserData {
     //given
     NSString *key = @"key1";
     NSString *value = @"value10";
     NSMutableSet *set = [[NSMutableSet alloc] initWithArray:@[@"a", @"b"]];

     //when
     [Targeting.shared addUserDataWithKey:key value:value];
     [Targeting.shared updateUserDataWithKey:key value:set];
     [Targeting.shared removeUserDataFor:key];
     [Targeting.shared clearUserData];

 }

// MARK: - [DEPRECATED API] app.ext.data

- (void)testContextData {
     //given
     NSString *key = @"key1";
     NSString *value = @"value10";
     NSMutableSet *set = [[NSMutableSet alloc] initWithArray:@[@"a", @"b"]];

     //when
     [Targeting.shared addContextDataWithKey:key value:value];
     [Targeting.shared updateContextDataWithKey:key value:set];
     [Targeting.shared removeContextDataFor:key];
     [Targeting.shared clearContextData];
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

// MARK: - [DEPRECATED API] app.keywords

- (void)testContextKeyword {
    //given
    NSString *keyword = @"keyword";
    NSMutableSet *set = [[NSMutableSet alloc] initWithArray:@[@"a", @"b"]];
    
    //when
    [Targeting.shared addContextKeyword:keyword];
    [Targeting.shared addContextKeywords:set];
    [Targeting.shared removeContextKeyword:keyword];
    [Targeting.shared clearContextKeywords];
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
