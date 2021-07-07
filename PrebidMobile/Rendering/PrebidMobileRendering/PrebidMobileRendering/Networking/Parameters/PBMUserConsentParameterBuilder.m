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

#import "PBMUserConsentParameterBuilder.h"
#import "PBMUserConsentDataManager.h"
#import "PBMUserConsentResolver.h"
#import "PBMORTB.h"

@interface PBMUserConsentParameterBuilder ()

@property (nonatomic, strong) PBMUserConsentDataManager *userConsentManager;

@end

@implementation PBMUserConsentParameterBuilder

- (instancetype)init {
    return [self initWithUserConsentManager:PBMUserConsentDataManager.shared];
}

- (instancetype)initWithUserConsentManager:(PBMUserConsentDataManager *)userConsentManager {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.userConsentManager = (userConsentManager) ? userConsentManager : PBMUserConsentDataManager.shared;

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
