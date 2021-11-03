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

@interface PBMORTBSkadnFidelity : PBMORTBAbstract

// The fidelity-type of the attribution to track
@property (nonatomic, copy, nullable) NSNumber *fidelity;

// SKAdNetwork signature as specified by Apple
@property (nonatomic, copy, nullable) NSString *signature;

// An id unique to each ad response. Refer to Apple’s documentation for the proper UUID format requirements
@property (nonatomic, copy, nullable) NSUUID *nonce;

// Unix time in millis string used at the time of signature
@property (nonatomic, copy, nullable) NSNumber *timestamp;

@end

NS_ASSUME_NONNULL_END
