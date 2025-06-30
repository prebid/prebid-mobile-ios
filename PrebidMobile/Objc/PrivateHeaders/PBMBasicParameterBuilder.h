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

#import <Foundation/Foundation.h>

#import "PBMParameterBuilderProtocol.h"

@class Prebid;
@class Targeting;
@class PBMAdConfiguration;

NS_ASSUME_NONNULL_BEGIN
@interface PBMBasicParameterBuilder : NSObject <PBMParameterBuilder>

@property (class, readonly) NSString *platformKey;
@property (class, readonly) NSString *platformValue;
@property (class, readonly) NSString *allowRedirectsKey;
@property (class, readonly) NSString *allowRedirectsVal;
@property (class, readonly) NSString *sdkVersionKey;
@property (class, readonly) NSString *urlKey;
@property (class, readonly) NSString *rewardedVideoKey;
@property (class, readonly) NSString *rewardedVideoValue;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAdConfiguration:(PBMAdConfiguration *)adConfiguration
                       sdkConfiguration:(Prebid *)sdkConfiguration
                             sdkVersion:(NSString *)sdkVersion
                              targeting:(Targeting *)targeting NS_DESIGNATED_INITIALIZER;

@end
NS_ASSUME_NONNULL_END
