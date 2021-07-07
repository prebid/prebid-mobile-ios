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

@interface PBMORTBNative : PBMORTBAbstract

/// [Required]
/// Request payload complying with the Native Ad Specification.
@property (nonatomic, copy) NSString *request;

/// [Recommended]
/// Version of the Dynamic Native Ads API to which `request` complies; highly recommended for efficient parsing.
@property (nonatomic, copy, nullable) NSString *ver;

/// [Integer Array]
/// List of supported API frameworks for this impression. Refer to List 5.6. If an API is not explicitly listed, it is assumed not to be supported.
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *api;

/// [Integer Array]
/// Blocked creative attributes. Refer to List 5.3.
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *battr;

// Note: ext is not supported.
// Placeholder for exchange-specific extensions to OpenRTB.

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
