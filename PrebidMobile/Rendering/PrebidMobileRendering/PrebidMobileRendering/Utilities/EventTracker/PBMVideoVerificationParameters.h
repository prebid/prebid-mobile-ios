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

@class PBMVastTrackingEvents;

@interface PBMVideoVerificationResource : NSObject

@property (nonatomic, strong, nullable) NSString *url;
@property (nonatomic, strong, nullable) NSString *vendorKey;
@property (nonatomic, strong, nullable) NSString *params;
@property (nonatomic, strong, nullable) NSString *apiFramework;

@property (nonatomic, strong, nullable) PBMVastTrackingEvents *trackingEvents;

@end

@interface PBMVideoVerificationParameters : NSObject

@property (nonatomic, strong, nonnull) NSMutableArray<PBMVideoVerificationResource *> *verificationResources;
@property (nonatomic, assign) BOOL autoPlay;

- (nonnull instancetype)init;

@end
