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

#import "PBMORTBAbstract+Protected.h"
#import "PBMORTBBidExtSkadnSKOverlay.h"

@implementation PBMORTBBidExtSkadnSKOverlay

- (instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary {
    if (self = [super init]) {
        _delay = jsonDictionary[@"delay"];
        _endcarddelay = jsonDictionary[@"endcarddelay"];
        _dismissible = jsonDictionary[@"dismissible"];
        _pos = jsonDictionary[@"pos"];
    }
    
    return self;
}

- (PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary * const ret = [[PBMMutableJsonDictionary alloc] init];
    
    ret[@"delay"] = self.delay;
    ret[@"endcarddelay"] = self.endcarddelay;
    ret[@"dismissible"] = self.dismissible;
    ret[@"pos"] = self.pos;
    
    [ret pbmRemoveEmptyVals];
    
    return ret;
}

@end
