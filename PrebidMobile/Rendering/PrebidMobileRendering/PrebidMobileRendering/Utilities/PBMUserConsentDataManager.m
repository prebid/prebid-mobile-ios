//
//  PBMUserConsentDataManager.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMUserConsentDataManager.h"

// TCF v1 constants
NSString *const IABConsentSubjectToGDPRKey = @"IABConsent_SubjectToGDPR";
NSString *const IABConsentConsentStringKey = @"IABConsent_ConsentString";

// TCF v2 constants
NSString *const IABTCF2CMPSDKIDKey = @"IABTCF_CmpSdkID";
NSString *const IABTCF2SubjectToGDPRKey = @"IABTCF_gdprApplies";
NSString *const IABTCF2ConsentStringKey = @"IABTCF_TCString";
NSString *const IABTCF2PurposeConsentsStringKey = @"IABTCF_PurposeConsents";

// CCPA
NSString *const IABUSPrivacyStringKey = @"IABUSPrivacy_String";

@implementation PBMUserConsentDataManager {
    NSUserDefaults *_userDefaults;
}

+ (instancetype)singleton {
    static id singleton = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[[self class] alloc] init];
    });

    return singleton;
}

- (instancetype)init {
    return [self initWithUserDefaults:NSUserDefaults.standardUserDefaults];
}

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.subjectToGDPR = PBMIABConsentSubjectToGDPRUnknown;
    _userDefaults = (userDefaults) ? userDefaults : NSUserDefaults.standardUserDefaults;

    [self updateUserConsent];

    // Note that it was decided we always subscribe to changes in NSUserDefault
    // rather than attempt to check for a potential `IABConsent_CMPPresent` flag.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsChanged) name:NSUserDefaultsDidChangeNotification object:nil];

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateUserConsent {
    // We have to check for an object b/c this key has 3 valid values; 0, 1 and `nil`.
    // TODO: How is "nil" going to be represented? No key or value with text "Nil"
    if ([_userDefaults objectForKey:IABConsentSubjectToGDPRKey]) {
        self.subjectToGDPR = ([_userDefaults boolForKey:IABConsentSubjectToGDPRKey]) ? PBMIABConsentSubjectToGDPRYes : PBMIABConsentSubjectToGDPRNo;
    } else {
        self.subjectToGDPR = PBMIABConsentSubjectToGDPRUnknown;
    }

    self.gdprConsentString = [_userDefaults stringForKey:IABConsentConsentStringKey];
    
    self.usPrivacyString = [_userDefaults stringForKey:IABUSPrivacyStringKey];
    
    self.tcf2cmpSdkID = [_userDefaults stringForKey:IABTCF2CMPSDKIDKey];
    self.tcf2gdrpApplies = [_userDefaults stringForKey:IABTCF2SubjectToGDPRKey];
    self.tcf2consentString = [_userDefaults stringForKey:IABTCF2ConsentStringKey];
    self.tcf2purposeConsentsString = [_userDefaults stringForKey:IABTCF2PurposeConsentsStringKey];
}

- (void)userDefaultsChanged {
    [self updateUserConsent];
}

@end
