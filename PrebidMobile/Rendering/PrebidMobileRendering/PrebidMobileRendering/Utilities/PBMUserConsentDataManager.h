//
//  PBMUserConsentDataManager.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

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

 This class adds an observer to user defaults and passes consent related data
 to OpenX servers where usage determination is handled.
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
+ (nonnull instancetype)singleton;

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
