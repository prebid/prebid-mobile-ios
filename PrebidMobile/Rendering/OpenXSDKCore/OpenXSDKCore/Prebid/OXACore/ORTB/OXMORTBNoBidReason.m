//
//  OXMORTBNoBidReason.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBNoBidReason.h"

@implementation OXMORTBNoBidReason

+ (NSString *)noBidReasonFromCode:(NSInteger)noBidReasonCode {
    switch (noBidReasonCode) {
        case kOXMORTBNoBidReasonCode_UnknownError:
            return @"Unknown Error";
        case kOXMORTBNoBidReasonCode_TechnicalError:
            return @"Technical Error";
        case kOXMORTBNoBidReasonCode_InvalidRequest:
            return @"Invalid Request";
        case kOXMORTBNoBidReasonCode_KnownWebSpider:
            return @"Known Web Spider";
        case kOXMORTBNoBidReasonCode_SuspectedNonHumanTraffic:
            return @"Suspected Non-Human Traffic";
        case kOXMORTBNoBidReasonCode_CloudDataCenterOrProxyIP:
            return @"Cloud, Data center, or Proxy IP";
        case kOXMORTBNoBidReasonCode_UnsupportedDevice:
            return @"Unsupported Device";
        case kOXMORTBNoBidReasonCode_BlockedPublisherOrSite:
            return @"Blocked Publisher or Site";
        case kOXMORTBNoBidReasonCode_UnmatchedUser:
            return @"Unmatched User";
        case kOXMORTBNoBidReasonCode_DailyReaderCapMet:
            return @"Daily Reader Cap Met";
        case kOXMORTBNoBidReasonCode_DailyDomainCapMet:
            return @"Daily Domain Cap Met";
            
        default:
            return [self noBidReasonFromCode:kOXMORTBNoBidReasonCode_UnknownError];
    }
}

@end
