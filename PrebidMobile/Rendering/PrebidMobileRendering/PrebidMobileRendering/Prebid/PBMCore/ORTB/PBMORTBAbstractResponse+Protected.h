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

#ifndef PBMORTBAbstractResponse_Protected_h
#define PBMORTBAbstractResponse_Protected_h

#import "PBMORTBAbstractResponse.h"
#import "PBMORTBAbstract+Protected.h"

@interface PBMORTBAbstractResponse<ExtType> ()

- (nullable instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary extParser:(ExtType _Nullable (^ _Nonnull)(PBMJsonDictionary * _Nonnull))extParser;

- (void)populateJsonDictionary:(nonnull PBMMutableJsonDictionary *)jsonDictionary;

@property (nonatomic, readonly, nullable) PBMJsonDictionary *extAsJsonDictionary;

@end

#endif /* PBMORTBAbstractResponse_Protected_h */
