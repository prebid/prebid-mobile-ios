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

#import "PrebidMobileSwiftHeaders.h"

#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

@interface InternalUserConsentDataManager : NSObject

@property (nonatomic, nonnull, class, readonly) NSString * IABUSPrivacy_StringKey NS_SWIFT_NAME(IABUSPrivacy_StringKey);

@property (nonatomic, nonnull, class, readonly) NSString * IABGPP_HDR_GppString NS_SWIFT_NAME(IABGPP_HDR_GppString);

@property (nonatomic, nonnull, class, readonly) NSString * IABGPP_GppSID NS_SWIFT_NAME(IABGPP_GppSID);

@property (nonatomic, nullable, class, readonly) NSString * usPrivacyString;

@property (nonatomic, nullable, class, readonly) NSString * gppHDRString;
@property (nonatomic, nullable, class, readonly) NSMutableArray<NSNumber *> * gppSID;

@end
