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
#import <UIKit/UIKit.h>
#import "PBMConstants.h"

NS_ASSUME_NONNULL_BEGIN
@interface PBMFunctions : NSObject

+ (NSString *)sdkVersion;
+ (nonnull NSArray<NSString *> *)supportedSKAdNetworkVersions;
+ (NSDictionary<NSString *, NSString *> *)extractVideoAdParamsFromTheURLString:(NSString *)urlString forKeys:(NSArray *)keys;
+ (BOOL)canLoadVideoAdWithDomain:(NSString *)domain adUnitID:(nullable NSString *)adUnitID adUnitGroupID:(nullable NSString *)adUnitGroupID;
+ (nullable NSArray<PBMJsonDictionary *> *)dictionariesForPassthrough:(id)passthrough;
//FIXME: move to private fucntions ??
#pragma mark - SDK Info

+ (nonnull NSBundle *)bundleForSDK;
+ (nullable NSString *)infoPlistValueFor:(nonnull NSString *)key
    NS_SWIFT_NAME(infoPlistValue(_:));

@end
NS_ASSUME_NONNULL_END
