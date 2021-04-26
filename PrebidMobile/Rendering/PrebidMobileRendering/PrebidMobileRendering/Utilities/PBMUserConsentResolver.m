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
