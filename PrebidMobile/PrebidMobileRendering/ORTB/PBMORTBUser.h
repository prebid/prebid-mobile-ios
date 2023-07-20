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

#import "PBMORTBAbstract.h"

@class PBMORTBGeo;
@class PBMORTBContentData;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 3.2.20: User

//This object contains information known or derived about the human user of the device (i.e., the
//    audience for advertising). The user id is an exchange artifact and may be subject to rotation or other
//privacy policies. However, this user ID must be stable long enough to serve reasonably as the basis for
//    frequency capping and retargeting.
@interface PBMORTBUser : PBMORTBAbstract

//Exchange-specific ID for the user. At least one of id or buyerid is recommended
//id not supported


//Buyer-specific ID for the user as mapped by the exchange for the buyer. At least one of buyerid or id is recommended.
@property (nonatomic, copy, nullable) NSString *buyeruid;

//Year of birth as a 4-digit integer
@property (nonatomic, strong, nullable) NSNumber *yob;

//Gender, where “M” = male, “F” = female, “O” = known to be other (i.e., omitted is unknown)
@property (nonatomic, copy, nullable) NSString *gender;

//Comma separated list of keywords, interests, or intent
@property (nonatomic, copy, nullable) NSString *keywords;

//Optional feature to pass bidder data that was set in the exchange’s cookie.
//The string must be in base85 cookie safe characters and be in any format.
//Proper JSON encoding must be used to include “escaped” quotation marks
@property (nonatomic, copy, nullable) NSString *customdata;

//Location of the user’s home base defined by a Geo object. This is not necessarily their current location
@property (nonatomic, strong) PBMORTBGeo *geo;

//Additional user data. Each Data object (Section 3.2.21) represents a different data source.
@property (nonatomic, strong, nullable) NSArray<PBMORTBContentData *> *data;

// Placeholder for exchange-specific extensions to OpenRTB.
@property (nonatomic, strong, nullable) NSMutableDictionary<NSString *, NSObject *> *ext;

//Exchange-specific ID for the user.
@property (nonatomic, copy, nullable) NSString *userid;

- (instancetype)init;

- (void)appendEids:(NSArray<NSDictionary<NSString *, id> *> *)eids;

@end

NS_ASSUME_NONNULL_END
