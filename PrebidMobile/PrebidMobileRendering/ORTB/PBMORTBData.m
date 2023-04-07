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

#import "PBMORTBData.h"
#import "PBMORTBAbstract+Protected.h"

@implementation PBMORTBData

- (nonnull instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    _pluginRenderers = @[];
    
    return self;
}

- (void)setPluginRenderers:(NSArray<NSString *> *)pluginRenderers {
    _pluginRenderers = pluginRenderers ? [NSArray arrayWithArray:pluginRenderers] : nil;
}

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [[PBMMutableJsonDictionary alloc] init];
    
    if (self.pluginRenderers.count > 0) {
        ret[@"plugin_renderers"] = self.pluginRenderers;
    }
    
    ret = [ret pbmCopyWithoutEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _pluginRenderers = jsonDictionary[@"plugin_renderers"];
    
    return self;
}

@end
