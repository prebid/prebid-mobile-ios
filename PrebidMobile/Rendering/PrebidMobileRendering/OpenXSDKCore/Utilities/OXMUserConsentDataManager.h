//
//  OXMUserConsentDataManager.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Represenets if General Data Protection Regulation (GDPR) should be applied.
 */
typedef NS_CLOSED_ENUM(NSUInteger, OXMIABConsentSubjectToGDPR) {
    OXMIABConsentSubjectToGDPRUnknown NS_SWIFT_NAME(unknown),
    OXMIABConsentSubjectToGDPRYes NS_SWIFT_NAME(yes),
    OXMIABConsentSubjectToGDPRNo NS_SWIFT_NAME(no),
};

/**
 @c OXMUserConsentDataManager is responsible retrieving user consent according to the
 IAB Transparency & Consent Framework

 The design of the framework is that a publisher integrated Consent Management
 Platform (CMP) is responsible for storing user consent applicability and data
 in @c NSUserDefaults. All advertising SDKs are to query this data regularly for
 updates and pass that data downstream and act accordingly.

 This class adds an observer to user defaults and passes consent related data
 to OpenX servers where usage determination is handled.
 */
@interface OXMUserConsentDataManager : NSObject

/**
 Returns @c OXMIABConsentSubjectToGDPR enum describing whether or not this user
 is subject to GDPR.
 */
@property (nonatomic, assign) OXMIABConsentSubjectToGDPR subjectToGDPR;

/*
 The encoded GDPR consent string.
 */
@property (nonatomic, strong, nullable) NSString *gdprConsentString;

// TCFv2
@property (nonatomic, strong, nullable) NSString *tcf2cmpSdkID;
@property (nonatomic, strong, nullable) NSString *tcf2gdrpApplies;
@property (nonatomic, strong, nullable) NSString *tcf2consentString;


/*
 The encoded CCPA consent string.
 */
@property (nonatomic, strong, nullable) NSString *usPrivacyString;

#pragma mark - Initialization
/**
 Preferred method of using `OXMUserConsentDataManager`.
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
