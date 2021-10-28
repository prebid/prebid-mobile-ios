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

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeFunctions : NSObject

/**
 Populates macroses in an native ad template by values from the targeitn dictionary.
 Replaces macroses:
 %%PATTERN:_key_%% by the value targeting[_key_]:
 
 pbNativeTagData.cachePath = "%%PATTERN:hb_cache_path%%"; => pbNativeTagData.cachePath = "/abc";
 
 Replacecs the macros
 %%PATTERN:TARGETINGMAP%%
 by the json representation of the targeting
 
 Macroses for absent keys are replaced by the `null` value:
 
 pbNativeTagData.custom = "%%PATTERN:absent_key%%"; => pbNativeTagData.custom = null;
 */

+ (nullable NSString *)populateNativeAdTemplate:(NSString *)nativeTemplate
                 withTargeting:(NSDictionary<NSString *, NSString *> *)targeting
                         error:(NSError * _Nullable __autoreleasing * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
