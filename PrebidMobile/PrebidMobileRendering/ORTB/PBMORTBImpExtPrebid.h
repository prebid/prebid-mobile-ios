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

#import "PBMORTBAbstract.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMORTBImpExtPrebid : PBMORTBAbstract

@property (nonatomic, copy, nullable) NSString *storedRequestID;
@property (nonatomic, assign) BOOL isRewardedInventory;

//Set as type string, stored auction responses signal Prebid Server to respond with a static response
//matching the storedAuctionResponse found in the Prebid Server Database,
//useful for debugging and integration testing.
@property (nonatomic, strong, nullable) NSString *storedAuctionResponse;

@end

NS_ASSUME_NONNULL_END
