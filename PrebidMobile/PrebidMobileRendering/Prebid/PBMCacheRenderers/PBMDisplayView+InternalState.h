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

#ifndef PBMDisplayView_InternalState_h
#define PBMDisplayView_InternalState_h

#import "PBMDisplayView.h"

@class AdUnitConfig;
@protocol ServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface PBMDisplayView ()

@property (nonatomic, strong, readonly, nullable) id<ServerConnectionProtocol> connection;

- (instancetype)initWithFrame:(CGRect)frame bid:(Bid *)bid adConfiguration:(AdUnitConfig *)adConfiguration;

@end

NS_ASSUME_NONNULL_END

#endif /* PBMDisplayView_InternalState_h */
