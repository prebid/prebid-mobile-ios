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

//Superclass
#import "PBMAbstractCreative.h"
#import "PBMVideoViewDelegate.h"

@class PBMRewardedConfig;

@interface PBMVideoCreative : PBMAbstractCreative <PBMVideoViewDelegate>

@property (class, readonly) NSInteger maxSizeForPreRenderContent;

- (nonnull instancetype)initWithCreativeModel:(nonnull PBMCreativeModel *)creativeModel
                                  transaction:(nonnull PBMTransaction *)transaction
                                    videoData:(nonnull NSData *)data;

- (void)close;

- (BOOL)isPlaybackFinished;

@end
