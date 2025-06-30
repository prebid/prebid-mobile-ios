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

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 3.2.3: Regs

//This object contains any legal, governmental, or industry regulations that apply to the request. The
//coppa flag signals whether or not the request falls under the United States Federal Trade Commission’s
//regulations for the United States Children’s Online Privacy Protection Act (“COPPA”).
@interface PBMORTBRegs : PBMORTBAbstract
    
//Int. Flag indicating if this request is subject to the COPPA regulations established by the USA FTC, where 0 = no, 1 = yes
@property (nonatomic, strong, nullable) NSNumber *coppa;

@property (nonatomic, strong, nullable) NSString *gpp;
@property (nonatomic, strong, nullable) NSArray<NSNumber *> *gppSID;

/// Placeholder for exchange-specific extensions to OpenRTB.
@property (nonatomic, strong, nullable) NSMutableDictionary<NSString *, id> *ext;

@end

NS_ASSUME_NONNULL_END
