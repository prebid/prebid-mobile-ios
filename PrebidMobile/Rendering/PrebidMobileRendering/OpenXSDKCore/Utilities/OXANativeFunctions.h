//
//  OXANativeFunctions.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OXANativeFunctions : NSObject

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
