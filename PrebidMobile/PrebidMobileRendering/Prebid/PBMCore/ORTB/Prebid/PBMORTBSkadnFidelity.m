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

#import "PBMORTBSkadnFidelity.h"
#import "PBMORTBAbstract+Protected.h"

@implementation PBMORTBSkadnFidelity

- (instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary {
    if (self = [super init]) {
        _fidelity = jsonDictionary[@"fidelity"];
        _nonce = [[NSUUID alloc] initWithUUIDString:jsonDictionary[@"nonce"]];
        _timestamp = jsonDictionary[@"timestamp"];
        _signature = jsonDictionary[@"signature"];
    }
    return self;
}

- (PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary * const ret = [[PBMMutableJsonDictionary alloc] init];

    ret[@"fidelity"] = self.fidelity;
    ret[@"nonce"] = [self.nonce UUIDString];
    ret[@"timestamp"] = self.timestamp;
    ret[@"signature"] = self.signature;
    
    [ret pbmRemoveEmptyVals];
    
    return ret;
}

@end
