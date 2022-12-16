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

// TODO: Merge with Prebid class after migrating codebase to Swift

/// Internal class
/// isOriginalAPI - true if it is used Original API, false if Rendering
@interface PrebidInternal : NSObject

@property (nonatomic, assign) BOOL isOriginalAPI;

@property (nonatomic, nullable) NSString * displaymanager;
@property (nonatomic, nullable) NSString * displaymanagerver;

-(instancetype _Nonnull )init;

+ (instancetype _Nonnull)shared;

@end
