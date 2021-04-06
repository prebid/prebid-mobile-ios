//
//  OXMUserConsentResolver.m
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import "OXMUserConsentResolver.h"
#import "OXMUserConsentDataManager.h"

@interface OXMUserConsentResolver()
@property (nonatomic, strong, nonnull, readonly) OXMUserConsentDataManager *consentDataManager;
@end

// MARK: -

@implementation OXMUserConsentResolver

- (instancetype)initWithConsentDataManager:(OXMUserConsentDataManager *)consentDataManager {
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
        OXMIABConsentSubjectToGDPR subjectToGDPR = self.consentDataManager.subjectToGDPR;
        return @((subjectToGDPR == OXMIABConsentSubjectToGDPRYes) ?  1 : 0);
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

// MARK: - Private Helpers

- (BOOL)shouldReturnGDRPConsentData {
    if ([self shouldUseTCFv2]) {
        return (self.consentDataManager.tcf2gdrpApplies != nil);
    } else {
        OXMIABConsentSubjectToGDPR subjectToGDPR = self.consentDataManager.subjectToGDPR;
        return subjectToGDPR != OXMIABConsentSubjectToGDPRUnknown;
    }
}

- (BOOL)shouldUseTCFv2 {
    return (self.consentDataManager.tcf2cmpSdkID != nil);
}

@end
