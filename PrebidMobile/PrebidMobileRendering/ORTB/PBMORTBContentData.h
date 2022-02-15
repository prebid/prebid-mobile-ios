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

@class PBMORTBContentSegment;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - ext.prebid

@interface PBMORTBContentData : PBMORTBAbstract

/// Exchange-specific ID for the data provider.
@property (nonatomic, copy, nullable) NSString *id;
/// Exchange-specific name for the data provider.
@property (nonatomic, copy, nullable) NSString *name;
/// Segment objects are essentially key-value pairs that convey specific units of data.
@property (nonatomic, copy, nullable) NSArray<PBMORTBContentSegment *> *segment;
/// Placeholder for exchange-specific extensions to OpenRTB.
@property (nonatomic, strong, nullable) NSMutableDictionary<NSString *, NSObject *> *ext;

@end

NS_ASSUME_NONNULL_END
