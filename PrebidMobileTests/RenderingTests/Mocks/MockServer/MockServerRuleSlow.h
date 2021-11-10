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

#import "MockServerRule.h"

//As MockServerRule but the data is spaced out in chunks making it useful for testing slow connections.
//By default, numChunks is 10 and timeBetweenChunks is 1 second, meaning the full download will take ~10 seconds.
@interface MockServerRuleSlow : MockServerRule
@property int numChunks;
@property NSTimeInterval timeBetweenChunks;
@end
