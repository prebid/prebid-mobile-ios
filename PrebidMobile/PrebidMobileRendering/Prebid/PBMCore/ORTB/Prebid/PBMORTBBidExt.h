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

@class PBMORTBBidExtPrebid;
@class PBMORTBBidExtSkadn;

#if DEBUG
@class PBMORTBExtPrebidPassthrough;
#endif

NS_ASSUME_NONNULL_BEGIN

@interface PBMORTBBidExt : PBMORTBAbstract

@property (nonatomic, strong, nullable) PBMORTBBidExtPrebid *prebid;
@property (nonatomic, copy, nullable) NSDictionary *bidder;

@property (nonatomic, strong, nullable) PBMORTBBidExtSkadn *skadn;

// This part is dedicating to test server-side ad configurations.
// Need to be removed when ext.prebid.passthrough will be available.
#if DEBUG
@property (nonatomic, copy, nullable) NSArray<PBMORTBExtPrebidPassthrough *> *passthrough;
#endif

@end

NS_ASSUME_NONNULL_END
