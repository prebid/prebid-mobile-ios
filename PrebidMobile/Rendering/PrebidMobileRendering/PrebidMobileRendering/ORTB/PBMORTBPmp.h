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

@class PBMORTBDeal;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 3.2.11: Pmp

//This object is the private marketplace container for direct deals between buyers and sellers that may
//pertain to this impression. The actual deals are represented as a collection of Deal objects. Refer to
//Section 7.3 for more details.
@interface PBMORTBPmp : PBMORTBAbstract
    
//Int. Indicator of auction eligibility to seats named in the Direct Deals object, where 0 = all bids are accepted, 1 = bids are restricted to the deals specified and the terms thereof
@property (nonatomic, strong, nullable) NSNumber *private_auction;

//Array of Deal (Section 3.2.18) objects that convey the specific deals applicable to this impression
@property (nonatomic, copy) NSArray<PBMORTBDeal *> *deals;

//Placeholder for exchange-specific extensions to OpenRTB.
//Note: ext is not supported.

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
