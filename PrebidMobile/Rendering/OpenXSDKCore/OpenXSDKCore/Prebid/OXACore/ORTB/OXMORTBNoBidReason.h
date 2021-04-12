//
//  OXMORTBNoBidReason.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 5.24: No-Bid Reason Codes

typedef NS_ENUM(NSInteger, OXMORTBNoBidReasonCode) {
    kOXMORTBNoBidReasonCode_UnknownError = 0,
    kOXMORTBNoBidReasonCode_TechnicalError,
    kOXMORTBNoBidReasonCode_InvalidRequest,
    kOXMORTBNoBidReasonCode_KnownWebSpider,
    kOXMORTBNoBidReasonCode_SuspectedNonHumanTraffic,
    kOXMORTBNoBidReasonCode_CloudDataCenterOrProxyIP,
    kOXMORTBNoBidReasonCode_UnsupportedDevice,
    kOXMORTBNoBidReasonCode_BlockedPublisherOrSite,
    kOXMORTBNoBidReasonCode_UnmatchedUser,
    kOXMORTBNoBidReasonCode_DailyReaderCapMet,
    kOXMORTBNoBidReasonCode_DailyDomainCapMet,
};



#pragma mark - String representation

/// No-Bid Reason Codes convertion helper class
@interface OXMORTBNoBidReason : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (NSString *)noBidReasonFromCode:(NSInteger)noBidReasonCode;

@end

NS_ASSUME_NONNULL_END
