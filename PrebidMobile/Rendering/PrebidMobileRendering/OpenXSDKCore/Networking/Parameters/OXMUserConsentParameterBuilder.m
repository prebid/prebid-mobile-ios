//
//  OXMUserConsentParameterBuilder.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMUserConsentParameterBuilder.h"
#import "OXMUserConsentDataManager.h"
#import "OXMUserConsentResolver.h"
#import "OXMORTB.h"

@interface OXMUserConsentParameterBuilder ()

@property (nonatomic, strong) OXMUserConsentDataManager *userConsentManager;

@end

@implementation OXMUserConsentParameterBuilder

- (instancetype)init {
    return [self initWithUserConsentManager:[OXMUserConsentDataManager singleton]];
}

- (instancetype)initWithUserConsentManager:(OXMUserConsentDataManager *)userConsentManager {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.userConsentManager = (userConsentManager) ? userConsentManager : [OXMUserConsentDataManager singleton];

    return self;
}

- (void)buildBidRequest:(nonnull OXMORTBBidRequest *)bidRequest {
    OXMUserConsentResolver *consentResolver = [[OXMUserConsentResolver alloc] initWithConsentDataManager:self.userConsentManager];
    
    // GDPR
    bidRequest.regs.ext[@"gdpr"] = consentResolver.isSubjectToGDPR;
    bidRequest.user.ext[@"consent"] = consentResolver.gdprConsentString;
    
    // CCPA
    bidRequest.regs.ext[@"us_privacy"] = self.userConsentManager.usPrivacyString;
}

@end
