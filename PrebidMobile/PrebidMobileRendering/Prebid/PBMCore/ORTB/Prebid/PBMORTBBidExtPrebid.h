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

@class PBMORTBBidExtPrebidCache;
@class PBMORTBExtPrebidPassthrough;
@class PBMORTBExtPrebidEvents;

NS_ASSUME_NONNULL_BEGIN

@interface PBMORTBBidExtPrebid : PBMORTBAbstract

@property (nonatomic, strong, nullable) PBMORTBBidExtPrebidCache *cache;
@property (nonatomic, copy, nullable) NSDictionary<NSString *, NSString *> *targeting;
@property (nonatomic, copy, nullable) NSString *type;
@property (nonatomic, copy, nullable) NSArray<PBMORTBExtPrebidPassthrough *> *passthrough;
@property (nonatomic, strong, nullable) PBMORTBExtPrebidEvents *events;

@end

NS_ASSUME_NONNULL_END
