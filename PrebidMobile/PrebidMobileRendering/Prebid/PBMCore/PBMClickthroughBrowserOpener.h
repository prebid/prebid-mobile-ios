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

#import "PBMURLOpenAttempterBlock.h"
#import "PBMViewControllerProvider.h"
#import "PBMVoidBlock.h"
#import "PBMModalManager.h"
#import "PBMModalState.h"
#import "PBMOpenMeasurementSession.h"

@class Prebid;
@class AdConfiguration;

typedef PBMOpenMeasurementSession * _Nullable (^PBMOpenMeasurementSessionProvider)(void);

NS_ASSUME_NONNULL_BEGIN

@interface PBMClickthroughBrowserOpener : NSObject

- (instancetype)initWithSDKConfiguration:(Prebid *)sdkConfiguration
                         adConfiguration:(nullable AdConfiguration *)adConfiguration
                            modalManager:(PBMModalManager *)modalManager
                  viewControllerProvider:(PBMViewControllerProvider)viewControllerProvider
              measurementSessionProvider:(PBMOpenMeasurementSessionProvider)measurementSessionProvider
             onWillLoadURLInClickthrough:(nullable PBMVoidBlock)onWillLoadURLInClickthrough
                     onWillLeaveAppBlock:(nullable PBMVoidBlock)onWillLeaveAppBlock
               onClickthroughPoppedBlock:(nullable PBMModalStatePopHandler)onClickthroughPoppedBlock
                      onDidLeaveAppBlock:(nullable PBMModalStateAppLeavingHandler)onDidLeaveAppBlock NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (BOOL)openURL:(NSURL *)url onClickthroughExitBlock:(nullable PBMVoidBlock)onClickthroughExitBlock;

- (PBMURLOpenAttempterBlock)asUrlOpenAttempter;

@end

NS_ASSUME_NONNULL_END
