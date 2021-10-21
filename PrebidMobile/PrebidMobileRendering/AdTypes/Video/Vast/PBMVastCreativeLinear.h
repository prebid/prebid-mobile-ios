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

#import "PBMVastCreativeAbstract.h"
#import "PBMVastTrackingEvents.h"
#import "PBMVastMediaFile.h"
#import "PBMVastIcon.h"

//TODO: describe Vast XML structure

@interface PBMVastCreativeLinear : PBMVastCreativeAbstract

@property (nonatomic, strong, nonnull) NSMutableArray<PBMVastIcon *> *icons;
@property (nonatomic, strong, nullable) NSNumber *skipOffset;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, strong, nonnull) NSMutableArray<PBMVastMediaFile *> *mediaFiles;
@property (nonatomic, strong, nonnull) PBMVastTrackingEvents *vastTrackingEvents;

@property (nonatomic, copy, nullable) NSString *clickThroughURI;
@property (nonatomic, strong, nonnull) NSMutableArray<NSString *> *clickTrackingURIs;

- (nullable PBMVastMediaFile *)bestMediaFile;

@end
