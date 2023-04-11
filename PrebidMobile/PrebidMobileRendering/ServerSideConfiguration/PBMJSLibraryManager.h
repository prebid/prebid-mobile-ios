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
#import "PBMJSLibrary.h"

@protocol PrebidServerConnectionProtocol;
@class PrebidMRAIDScriptProvider;
@class PrebidOMSDKScriptProvider;

typedef NS_ENUM(NSInteger, PBMJSLibraryType) {
    PBMJSLibraryTypeMRAID,
    PBMJSLibraryTypeOMSDK,
};

NS_ASSUME_NONNULL_BEGIN

@interface PBMJSLibraryManager : NSObject

@property (strong, nonatomic, nullable) PBMJSLibrary *remoteMRAIDLibrary;
@property (strong, nonatomic, nullable) PBMJSLibrary *remoteOMSDKLibrary;
@property (strong, nonatomic, nonnull) NSBundle *bundle;

@property (nonatomic, strong, nullable) PrebidMRAIDScriptProvider * mraidProvider;
@property (nonatomic, strong, nullable) PrebidOMSDKScriptProvider * omsdkProvider;

+ (instancetype)sharedManager;
- (nullable NSString *)getMRAIDLibrary;
- (nullable NSString *)getOMSDKLibrary;
- (void)updateJSLibrariesIfNeededWithConnection:(id<PrebidServerConnectionProtocol>)connection;

@end

NS_ASSUME_NONNULL_END
