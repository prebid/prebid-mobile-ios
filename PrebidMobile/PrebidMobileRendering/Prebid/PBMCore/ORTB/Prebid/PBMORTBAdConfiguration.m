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

#import "PBMORTBAbstract+Protected.h"
#import "PBMORTBAdConfiguration.h"

@implementation PBMORTBAdConfiguration

- (instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary {
    if (!(self = [super init])) {
        return nil;
    }
    
    _maxVideoDuration = jsonDictionary[@"maxvideoduration"];
    _isMuted = jsonDictionary[@"ismuted"];
    _closeButtonArea = jsonDictionary[@"closebuttonarea"];
    _closeButtonPosition = jsonDictionary[@"closebuttonposition"];
    _skipButtonArea = jsonDictionary[@"skipbuttonarea"];
    _skipButtonPosition = jsonDictionary[@"skipbuttonposition"];
    _skipDelay = jsonDictionary[@"skipdelay"];
    
    return self;
}

- (PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary * const ret = [[PBMMutableJsonDictionary alloc] init];
    
    ret[@"maxvideoduration"] = self.maxVideoDuration;
    ret[@"ismuted"] = self.isMuted;
    ret[@"closebuttonarea"] = self.closeButtonArea;
    ret[@"closebuttonposition"] = self.closeButtonPosition;
    ret[@"skipbuttonarea"] = self.skipButtonArea;
    ret[@"skipbuttonposition"] = self.skipButtonPosition;
    ret[@"skipdelay"] = self.skipDelay;
    
    [ret pbmRemoveEmptyVals];
    
    return ret;
}

@end
