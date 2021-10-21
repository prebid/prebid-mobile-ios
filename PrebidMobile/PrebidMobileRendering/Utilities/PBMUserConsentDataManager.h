/*   Copyright 2018-2021 Prebid.org, Inc.

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

/**
 Represenets if General Data Protection Regulation (GDPR) should be applied.
 */
typedef NS_CLOSED_ENUM(NSUInteger, PBMIABConsentSubjectToGDPR) {
    PBMIABConsentSubjectToGDPRUnknown NS_SWIFT_NAME(unknown),
    PBMIABConsentSubjectToGDPRYes NS_SWIFT_NAME(yes),
    PBMIABConsentSubjectToGDPRNo NS_SWIFT_NAME(no),
};

/**
 @c PBMUserConsentDataManager is responsible retrieving user consent according to the
 IAB Transparency & Consent Framework

 The design of the framework is that a publisher integrated Consent Management
 Platform (CMP) is responsible for storing user consent applicability and data
 in @c NSUserDefaults. All advertising SDKs are to query this data regularly for
 updates and pass that data downstream and act accordingly.
 */
@interface PBMUserConsentDataManager : NSObject

/**
 Returns @c PBMIABConsentSubjectToGDPR enum describing whether or not this user
 is subject to GDPR.
 */
@property (nonatomic, assign) PBMIABConsentSubjectToGDPR subjectToGDPR;

/*
 The encoded GDPR consent string.
 */
@property (nonatomic, strong, nullable) NSString *gdprConsentString;

// TCFv2
@property (nonatomic, strong, nullable) NSString *tcf2cmpSdkID;
@property (nonatomic, strong, nullable) NSString *tcf2gdrpApplies;
@property (nonatomic, strong, nullable) NSString *tcf2consentString;
@property (nonatomic, strong, nullable) NSString *tcf2purposeConsentsString;


/*
 The encoded CCPA consent string.
 */
@property (nonatomic, strong, nullable) NSString *usPrivacyString;

#pragma mark - Initialization
/**
 Preferred method of using `PBMUserConsentDataManager`.
 */
@property (class, readonly, nonnull) PBMUserConsentDataManager *shared;

/**
 Convenience initializer that uses the shared user defaults object.
 */
- (nonnull instancetype)init;

#pragma mark - Dependency Injection
/**
 Initializer exposed primarily for dependency injection.
 */
- (nonnull instancetype)initWithUserDefaults:(nullable NSUserDefaults *)userDefaults;

@end
