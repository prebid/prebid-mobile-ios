/*   Copyright 2018-2026 Prebid.org, Inc.

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

@import PrebidMobile;

NS_ASSUME_NONNULL_BEGIN

/// A sample provider of Extended IDs (EIDs).
///
/// A real provider gets its IDs from its own SDK or service, keeps the latest ones, and hands them to
/// Prebid from `getExtendedIds`. Once it is registered with `+[Prebid registerPlugin:as:]` as
/// `PluginCapability.extendedIds`, the SDK adds its IDs to every bid request, after the IDs set through
/// `Targeting`.
@interface SampleExtendedIdProvider : NSObject <ExtendedIdProvider>

/// Identifies the provider. Registering a second provider with the same name and version is ignored.
@property (nonatomic, readonly) ExtendedIdProviderInfo *providerInfo;

@end

NS_ASSUME_NONNULL_END
