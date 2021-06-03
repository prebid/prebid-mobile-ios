//
//  PBMUserConsentResolver.m
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import "PBMUserConsentResolver.h"
#import "PBMUserConsentDataManager.h"

@interface PBMUserConsentResolver()
@property (nonatomic, strong, nonnull, readonly) PBMUserConsentDataManager *consentDataManager;
@end

// MARK: -

@implementation PBMUserConsentResolver

- (instancetype)initWithConsentDataManager:(PBMUserConsentDataManager *)consentDataManager {
    if (!(self = [super init])) {
        return nil;
    }
    _consentDataManager = consentDataManager;
    return self;
}

- (NSNumber *)isSubjectToGDPR {
    if (![self shouldReturnGDRPConsentData]) {
        return nil;
    }
    if ([self shouldUseTCFv2]) {
        NSString *gdprApplies = self.consentDataManager.tcf2gdrpApplies;
        return @([gdprApplies boolValue] ? 1 : 0);
    } else {
        PBMIABConsentSubjectToGDPR subjectToGDPR = self.consentDataManager.subjectToGDPR;
        return @((subjectToGDPR == PBMIABConsentSubjectToGDPRYes) ?  1 : 0);
    }
}

- (NSString *)gdprConsentString {
    if (![self shouldReturnGDRPConsentData]) {
        return nil;
    }
    if ([self shouldUseTCFv2]) {
        return self.consentDataManager.tcf2consentString;
    } else {
        return self.consentDataManager.gdprConsentString;
    }
}

//fetch advertising identifier based TCF 2.0 Purpose1 value
//truth table
/*
                     deviceAccessConsent=true   deviceAccessConsent=false  deviceAccessConsent undefined
gdprApplies=false        Yes, read IDFA             No, don’t read IDFA           Yes, read IDFA
gdprApplies=true         Yes, read IDFA             No, don’t read IDFA           No, don’t read IDFA
gdprApplies=undefined    Yes, read IDFA             No, don’t read IDFA           Yes, read IDFA
*/
- (BOOL)canAccessDeviceData {
    const NSNumber *gdprApplies = self.isSubjectToGDPR;
    const NSUInteger deviceAccessConsentIndex = 0;
    const NSNumber *deviceAccessConsent = [self getPurposeConsent:deviceAccessConsentIndex];
    
    // deviceAccess undefined and gdprApplies undefined
    if (deviceAccessConsent == nil && gdprApplies == nil) {
        return YES;
    }
    
    // deviceAccess undefined and gdprApplies false
    if (deviceAccessConsent == nil && gdprApplies.boolValue == false) {
        return YES;
    }
    
    // gdprApplies = true
    // deviceAccess is set (true/false) or still is nil (i.e. false)
    return deviceAccessConsent.boolValue;
}

- (NSNumber *)getPurposeConsent:(NSUInteger)index {
    const NSString * purposeConstentsString = self.consentDataManager.tcf2purposeConsentsString;
    if (!purposeConstentsString || purposeConstentsString.length <= index) {
        return nil;
    }
    return @([purposeConstentsString characterAtIndex:index] == '1');
}

// MARK: - Private Helpers

- (BOOL)shouldReturnGDRPConsentData {
    if ([self shouldUseTCFv2]) {
        return (self.consentDataManager.tcf2gdrpApplies != nil);
    } else {
        PBMIABConsentSubjectToGDPR subjectToGDPR = self.consentDataManager.subjectToGDPR;
        return subjectToGDPR != PBMIABConsentSubjectToGDPRUnknown;
    }
}

- (BOOL)shouldUseTCFv2 {
    return (self.consentDataManager.tcf2cmpSdkID != nil);
}

@end
