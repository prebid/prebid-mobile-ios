//
//  PBMORTBNoBidReason.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 5.24: No-Bid Reason Codes

typedef NS_ENUM(NSInteger, PBMORTBNoBidReasonCode) {
    kPBMORTBNoBidReasonCode_UnknownError = 0,
    kPBMORTBNoBidReasonCode_TechnicalError,
    kPBMORTBNoBidReasonCode_InvalidRequest,
    kPBMORTBNoBidReasonCode_KnownWebSpider,
    kPBMORTBNoBidReasonCode_SuspectedNonHumanTraffic,
    kPBMORTBNoBidReasonCode_CloudDataCenterOrProxyIP,
    kPBMORTBNoBidReasonCode_UnsupportedDevice,
    kPBMORTBNoBidReasonCode_BlockedPublisherOrSite,
    kPBMORTBNoBidReasonCode_UnmatchedUser,
    kPBMORTBNoBidReasonCode_DailyReaderCapMet,
    kPBMORTBNoBidReasonCode_DailyDomainCapMet,
};



#pragma mark - String representation

/// No-Bid Reason Codes convertion helper class
@interface PBMORTBNoBidReason : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (NSString *)noBidReasonFromCode:(NSInteger)noBidReasonCode;

@end

NS_ASSUME_NONNULL_END
