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

// Values chosen to match the IAB Connection Type Spec:
// Unknown: 0
// Ethernet: 1 (skipped because it's not possible on a phone)
// Wifi: 2
// Cellular Unknown: 3
typedef NS_ENUM(NSInteger, PBMNetworkType) {
    PBMNetworkTypeUnknown = 0,
    PBMNetworkTypeWifi = 2,
    PBMNetworkTypeCell = 3,
    PBMNetworkTypeOffline,
};

typedef NSString * PBMNetworkTypeDescription NS_TYPED_EXTENSIBLE_ENUM;

FOUNDATION_EXPORT PBMNetworkTypeDescription const PBMNetworkTypeDescriptionUnknown;
FOUNDATION_EXPORT PBMNetworkTypeDescription const PBMNetworkTypeDescriptionOffline;
FOUNDATION_EXPORT PBMNetworkTypeDescription const PBMNetworkTypeDescriptionWifi;
FOUNDATION_EXPORT PBMNetworkTypeDescription const PBMNetworkTypeDescriptionCell;

FOUNDATION_EXPORT PBMNetworkType pbmNetworkTypeFromDescription(PBMNetworkTypeDescription networkTypeDescription);
FOUNDATION_EXPORT PBMNetworkTypeDescription pbmDescriptionOfNetworkType(PBMNetworkType networkType);
