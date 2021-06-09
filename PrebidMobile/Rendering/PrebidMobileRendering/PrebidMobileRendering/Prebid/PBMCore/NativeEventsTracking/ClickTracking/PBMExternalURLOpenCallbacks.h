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

#import "PBMURLOpenResultHandlerBlock.h"
#import "PBMVoidBlock.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMExternalURLOpenCallbacks : NSObject

@property (nonatomic, copy, readonly) PBMURLOpenResultHandlerBlock urlOpenedCallback;
@property (nonatomic, copy, readonly, nullable) PBMVoidBlock onClickthroughExitBlock;

- (instancetype)initWithUrlOpenedCallback:(PBMURLOpenResultHandlerBlock)urlOpenedCallback
                  onClickthroughExitBlock:(nullable PBMVoidBlock)onClickthroughExitBlock NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
