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

#import "PBMORTBBid.h"
#import "PBMORTBBidExt.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMORTBMacrosHelper : NSObject

@property (nonatomic, strong, nonnull, readonly) NSDictionary<NSString *, NSString *> *macroValues;

// MARK: - Lifecycle
- (instancetype)initWithBid:(PBMORTBBid<PBMORTBBidExt *> *)bid NS_DESIGNATED_INITIALIZER;

// MARK: - API
- (nullable NSString *)replaceMacrosInString:(nullable NSString *)sourceString;

// MARK: - Overrides
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
