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

#import "PBMExternalURLOpenerBlock.h"
#import "PBMExternalURLOpenCallbacks.h"

NS_ASSUME_NONNULL_BEGIN

// will return ('nop', nil) container if passed NO; otherwise -- will return completion handlers.
typedef PBMExternalURLOpenCallbacks * _Nonnull (^PBMCanOpenURLResultHandlerBlock)(BOOL willOpenURL);

// pass 'YES' to 'compatibilityCheckHandler' to get URL handling completion block;
// if incompatible, call 'compatibilityCheckHandler' with NO.
typedef void (^PBMURLOpenAttempterBlock)(NSURL *url, PBMCanOpenURLResultHandlerBlock compatibilityCheckHandler);

NS_ASSUME_NONNULL_END
