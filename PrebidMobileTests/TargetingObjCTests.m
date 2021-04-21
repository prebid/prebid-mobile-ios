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
    Targeting.shared.subjectToCOPPA = false;
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
    
    [Targeting.shared clearYearOfBirth];
    [Targeting.shared clearAccessControlList];
    [Targeting.shared clearContextData];
    [Targeting.shared clearContextKeywords];
    [Targeting.shared clearUserKeywords];
    [Targeting.shared clearUserData];
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
    int genderFemale = GenderFemale;
    
    //when
    Targeting.shared.gender = genderFemale;
    
    //then
    XCTAssertEqual(genderFemale, Targeting.shared.gender);
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
    [Targeting.shared setYearOfBirthWithYob:yearOfBirth error:&error];
    long value1 = Targeting.shared.yearOfBirth;
    
    [Targeting.shared clearYearOfBirth];
    long value2 = Targeting.shared.yearOfBirth;
    
    //then
    XCTAssertNil(error);
    XCTAssertEqual(yearOfBirth, value1);
    XCTAssertEqual(0, value2);
}

- (void)testYearOfBirthInvalid {
    
    //when
    NSError *error1 = nil;
    NSError *error2 = nil;
    NSError *error3 = nil;
    
    [Targeting.shared setYearOfBirthWithYob:-1 error:&error1];
    [Targeting.shared setYearOfBirthWithYob:999 error:&error2];
    [Targeting.shared setYearOfBirthWithYob:10000 error:&error3];
    
    //then
    XCTAssertNotNil(error1);
    XCTAssertNotNil(error2);
    XCTAssertNotNil(error3);

}

//MARK: - COPPA
- (void)testSubjectToCOPPA {
    //given
    BOOL subjectToCOPPA = YES;
    Targeting.shared.subjectToCOPPA = subjectToCOPPA;
    
    //when
    BOOL result = Targeting.shared.subjectToCOPPA;

    //then
    XCTAssertEqual(subjectToCOPPA, result);
    
    //defer
    Targeting.shared.subjectToCOPPA = false;
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
    NSNumber *deviceAccessConsent = Targeting.shared.getDeviceAccessConsent;

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
    [Targeting.shared removeUserDataForKey:key];
    [Targeting.shared clearUserData];

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

- (void)testContextData {
    //given
    NSString *key = @"key1";
    NSString *value = @"value10";
    NSMutableSet *set = [[NSMutableSet alloc] initWithArray:@[@"a", @"b"]];
    
    //when
    [Targeting.shared addContextDataWithKey:key value:value];
    [Targeting.shared updateContextDataWithKey:key value:set];
    [Targeting.shared removeContextDataForKey:key];
    [Targeting.shared clearContextData];

}

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

@end
