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

#import "PBMVastAbstractAd.h"

@class PBMVideoVerificationParameters;
@class PBMVastCreativeLinear;

//See PBMVastAbstractAd for VAST structure details

@interface PBMVastInlineAd : PBMVastAbstractAd

@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *advertiser;

@property (nonatomic, strong, nonnull) PBMVideoVerificationParameters *verificationParameters;

// The first Linear creative that has a media file the SDK can play, or nil if there is none.
// VAST validation and creative model creation both select the creative through this method.
- (nullable PBMVastCreativeLinear *)playableLinearCreative;

@end
