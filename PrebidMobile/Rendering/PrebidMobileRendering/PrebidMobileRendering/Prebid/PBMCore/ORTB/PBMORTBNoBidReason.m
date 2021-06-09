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

#import "PBMORTBNoBidReason.h"

@implementation PBMORTBNoBidReason

+ (NSString *)noBidReasonFromCode:(NSInteger)noBidReasonCode {
    switch (noBidReasonCode) {
        case kPBMORTBNoBidReasonCode_UnknownError:
            return @"Unknown Error";
        case kPBMORTBNoBidReasonCode_TechnicalError:
            return @"Technical Error";
        case kPBMORTBNoBidReasonCode_InvalidRequest:
            return @"Invalid Request";
        case kPBMORTBNoBidReasonCode_KnownWebSpider:
            return @"Known Web Spider";
        case kPBMORTBNoBidReasonCode_SuspectedNonHumanTraffic:
            return @"Suspected Non-Human Traffic";
        case kPBMORTBNoBidReasonCode_CloudDataCenterOrProxyIP:
            return @"Cloud, Data center, or Proxy IP";
        case kPBMORTBNoBidReasonCode_UnsupportedDevice:
            return @"Unsupported Device";
        case kPBMORTBNoBidReasonCode_BlockedPublisherOrSite:
            return @"Blocked Publisher or Site";
        case kPBMORTBNoBidReasonCode_UnmatchedUser:
            return @"Unmatched User";
        case kPBMORTBNoBidReasonCode_DailyReaderCapMet:
            return @"Daily Reader Cap Met";
        case kPBMORTBNoBidReasonCode_DailyDomainCapMet:
            return @"Daily Domain Cap Met";
            
        default:
            return [self noBidReasonFromCode:kPBMORTBNoBidReasonCode_UnknownError];
    }
}

@end
