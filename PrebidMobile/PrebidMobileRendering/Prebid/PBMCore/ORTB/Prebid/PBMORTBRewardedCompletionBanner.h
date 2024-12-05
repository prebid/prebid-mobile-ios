/*   Copyright 2018-2024 Prebid.org, Inc.

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
#import "PBMORTBAbstract+Protected.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMORTBRewardedCompletionBanner : PBMORTBAbstract

/// The period of time that the ad is on the screen and the user earns a reward
@property (nonatomic, strong, nullable) NSNumber *time;

/// The URL with a custom schema that will be sent by the creative and should be caught by the SDK
@property (nonatomic, strong, nullable) NSString *event;

@end

NS_ASSUME_NONNULL_END
