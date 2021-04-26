//
//  PBMUserConsentParameterBuilder.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMUserConsentParameterBuilder.h"
#import "PBMUserConsentDataManager.h"
#import "PBMUserConsentResolver.h"
#import "PBMORTB.h"

@interface PBMUserConsentParameterBuilder ()

@property (nonatomic, strong) PBMUserConsentDataManager *userConsentManager;

@end

@implementation PBMUserConsentParameterBuilder

- (instancetype)init {
    return [self initWithUserConsentManager:[PBMUserConsentDataManager singleton]];
}

- (instancetype)initWithUserConsentManager:(PBMUserConsentDataManager *)userConsentManager {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.userConsentManager = (userConsentManager) ? userConsentManager : [PBMUserConsentDataManager singleton];

    return self;
}

- (void)buildBidRequest:(nonnull PBMORTBBidRequest *)bidRequest {
    PBMUserConsentResolver *consentResolver = [[PBMUserConsentResolver alloc] initWithConsentDataManager:self.userConsentManager];
    
    // GDPR
    bidRequest.regs.ext[@"gdpr"] = consentResolver.isSubjectToGDPR;
    bidRequest.user.ext[@"consent"] = consentResolver.gdprConsentString;
    
    // CCPA
    bidRequest.regs.ext[@"us_privacy"] = self.userConsentManager.usPrivacyString;
}

@end
