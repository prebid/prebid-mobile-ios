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

#import "PBMORTBRewardedCompletionVideoEndcard.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMORTBRewardedCompletionVideo : PBMORTBAbstract

/// The period of time that the ad is on the screen and the user earns a reward
@property (nonatomic, strong, nullable) NSNumber *time;

/// The playback part when the user earns a reward
@property (nonatomic, strong, nullable) NSString *playbackevent;

/// Endcard completion criteria
@property (nonatomic, strong, nullable) PBMORTBRewardedCompletionVideoEndcard *endcard;


@end

NS_ASSUME_NONNULL_END
