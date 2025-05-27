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

@class PBMORTBRewardedReward;
@class PBMORTBRewardedCompletion;
@class PBMORTBRewardedClose;

NS_ASSUME_NONNULL_BEGIN

@interface PBMORTBRewardedConfiguration : PBMORTBAbstract

/// Metadata provided by the publisher to describe the reward.
@property (nonatomic, strong, nullable) PBMORTBRewardedReward * reward;

/// Describes the condition when the SDK should send a signal to the application that the user has earned the reward.
@property (nonatomic, strong, nullable) PBMORTBRewardedCompletion * completion;

/// Describes the close behavior. How should the SDK manage the ad when it is encountered as viewed.
@property (nonatomic, strong, nullable) PBMORTBRewardedClose * close;

@end

NS_ASSUME_NONNULL_END
