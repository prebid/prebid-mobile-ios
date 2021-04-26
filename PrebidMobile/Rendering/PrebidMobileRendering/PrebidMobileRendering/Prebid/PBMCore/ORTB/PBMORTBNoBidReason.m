//
//  PBMORTBNoBidReason.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

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
