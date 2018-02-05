/*   Copyright 2017 Prebid.org, Inc.
 
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

#import "PBException.h"

@implementation PBException

+ (NSException *)exceptionWithName:(enum PBRaiseException)exceptionName {
    switch (exceptionName) {
        case PBAdUnitNoSizeException:
            return ([super exceptionWithName:@"PBAdUnitNoSizeException" reason:@"Ad unit size object is not specified." userInfo:nil]);
            break;
        case PBAdUnitNoDemandConfigException:
            return ([super exceptionWithName:@"PBAdUnitNoDemandConfigException" reason:@"Ad unit config id is not set in prebid server." userInfo:nil]);
            break;
        case PBAdUnitAlreadyRegisteredException:
            return ([super exceptionWithName:@"PBAdUnitAlreadyRegisteredException" reason:@"Ad unit is already registered." userInfo:nil]);
            break;
        case PBAdUnitNotRegisteredException:
            return ([super exceptionWithName:@"PBAdUnitNotRegisteredException" reason:@"Ad unit is not registered." userInfo:nil]);
            break;
        case PBHostInvalidException:
            return ([super exceptionWithName:@"PBHostInvalidException" reason:@"Prebid server host not valid." userInfo:nil]);
            break;
        default:
            return ([super exceptionWithName:@"PrebidException" reason:@"" userInfo:nil]);
            break;
    }
}

+ (nonnull NSException *)initWithName:(nonnull NSString *)aName reason:(nullable NSString *)aReason userInfo:(nullable NSDictionary *)aUserInfo {

    return ([super exceptionWithName:aName reason:aReason userInfo:aUserInfo]);
}

@end
