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

#import "SampleExtendedIdProvider.h"

static NSString * const SampleExtendedIdProviderSource = @"sample-id-provider.example";

@interface SampleExtendedIdProvider ()

// `getExtendedIds` may be called on any thread, possibly concurrently, so the ID is behind a lock.
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, copy, nullable) NSString *userId;

@end

@implementation SampleExtendedIdProvider

- (instancetype)init {
    self = [super init];
    if (self) {
        _providerInfo = [[ExtendedIdProviderInfo alloc] initWithName:SampleExtendedIdProviderSource version:@"1.0.0"];
        _lock = [NSLock new];
    }
    return self;
}

/// Called once inside `+[Prebid registerPlugin:as:]`. Start keeping your IDs current here, for example by
/// listening to your own SDK. This sample makes up an ID instead.
- (void)onRegister {
    [self.lock lock];
    self.userId = [NSUUID UUID].UUIDString;
    [self.lock unlock];

    NSLog(@"SampleExtendedIdProvider registered");
}

/// Called on every bid request, so return the IDs you already have, without network calls or other
/// blocking work. Return an empty array while you have none.
- (NSArray<id<ExtendedId>> *)getExtendedIds {
    [self.lock lock];
    NSString *userId = self.userId;
    [self.lock unlock];

    if (!userId) {
        return @[];
    }

    // Agent type 1: the ID belongs to this device
    UserUniqueID *uid = [[UserUniqueID alloc] initWithUniqueId:userId aType:@1 ext:nil];

    // An EID you already have as an OpenRTB dictionary can be returned as `[[RawExtendedId alloc] initWithJson:]`.
    return @[[[ExternalUserId alloc] initWithSource:SampleExtendedIdProviderSource uids:@[uid] ext:nil]];
}

/// Called inside `+[Prebid unregisterPlugin:as:]`. Stop keeping your IDs current here. Bid requests that
/// are already being built may still call `getExtendedIds`, so keep it working.
- (void)onUnregister {
    NSLog(@"SampleExtendedIdProvider unregistered");
}

@end
