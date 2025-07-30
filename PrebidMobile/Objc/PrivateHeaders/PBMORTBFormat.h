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

#pragma mark - 3.2.10: Format

//This object represents an allowed size (i.e., height and width combination) or Flex Ad parameters for a
//    banner impression. These are typically used in an array where multiple sizes are permitted. It is
//recommended that either the w/h pair or the wratio/hratio/wmin set (i.e., for Flex Ads) be specified.
@interface PBMORTBFormat : PBMORTBAbstract

//Int. Width in device independent pixels (DIPS).
@property (nonatomic, strong, nullable) NSNumber *w;

//Int. Height in device independent pixels (DIPS).
@property (nonatomic, strong, nullable) NSNumber *h;

//Int. Relative width when expressing size as a ratio.
@property (nonatomic, strong, nullable) NSNumber *wratio;

//Int. Relative height when expressing size as a ratio.
@property (nonatomic, strong, nullable) NSNumber *hratio;

//Int. The minimum width in device independent pixels (DIPS) at which the ad will be displayed the size is expressed as a ratio.
@property (nonatomic, strong, nullable) NSNumber *wmin;

//Placeholder for exchange-specific extensions to OpenRTB.
//Note: ext is not supported.

@end

NS_ASSUME_NONNULL_END
