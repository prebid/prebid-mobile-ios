/*   Copyright 2018 Prebid.org, Inc.
 
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
#import "PBAdUnit.h"

@interface PBServerRequestBuilder : NSObject

@property (nonatomic, assign, readwrite) NSURL * _Nonnull hostURL;

+ (instancetype _Nullable )sharedInstance;


- (NSURLRequest *_Nullable)buildRequest:(nullable NSArray<PBAdUnit *> *)adUnits withAccountId:(NSString *_Nullable) accountID withSecureParams:(BOOL) isSecure withPriceGranularity:(NSString *_Nonnull) priceGranularity;

@end
