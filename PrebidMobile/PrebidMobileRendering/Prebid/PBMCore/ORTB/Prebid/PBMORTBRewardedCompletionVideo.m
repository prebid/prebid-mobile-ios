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

#import "PBMORTBRewardedCompletionVideo.h"

@implementation PBMORTBRewardedCompletionVideo

- (instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    
    _time = [jsonDictionary[@"time"] nullToNil];
    _playbackevent = [jsonDictionary[@"playbackevent"] nullToNil];
    _endcard = [[PBMORTBRewardedCompletionVideoEndcard alloc] initWithJsonDictionary:[jsonDictionary[@"endcard"] nullToNil]];
    
    return self;
}

- (PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary * const ret = [[PBMMutableJsonDictionary alloc] init];
    
    ret[@"time"] = self.time;
    ret[@"playbackevent"] = self.playbackevent;
    ret[@"endcard"] = [self.endcard toJsonDictionary];
    
    [ret pbmRemoveEmptyVals];
    
    return ret;
}

@end
