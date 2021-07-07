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
