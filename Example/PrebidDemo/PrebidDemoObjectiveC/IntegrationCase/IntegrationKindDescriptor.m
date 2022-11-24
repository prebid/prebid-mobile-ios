/*   Copyright 2019-2022 Prebid.org, Inc.
 
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
#import "IntegrationKindDescriptor.h"
#import "IntegrationKind.h"

@implementation IntegrationKindDescriptor

+ (NSString*)getDescriptionForIntegrationKind:(IntegrationKind)integrationKind {
    switch (integrationKind) {
            
        case IntegrationKindGAMOriginal:
            return @"GAM (Original API)";
        case IntegrationKindGAM:
            return @"GAM";
        case IntegrationKindInApp:
            return @"In-App";
        case IntegrationKindAdMob:
            return @"AdMob";
        case IntegrationKindMAX:
            return @"MAX";
        case IntegrationKindAll:
            return @"All";
    }
    
}

@end
