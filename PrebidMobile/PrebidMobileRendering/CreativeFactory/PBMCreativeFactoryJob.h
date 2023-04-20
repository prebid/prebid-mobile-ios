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
#import "PBMCreativeResolutionDelegate.h"

@class PBMCreativeModel;
@class PBMAbstractCreative;
@class PBMTransaction;
@class PBMCreativeFactoryJob;

@protocol PrebidServerConnectionProtocol;

typedef enum PBMCreativeFactoryJobState : NSUInteger {
    PBMCreativeFactoryJobStateInitialized,
    PBMCreativeFactoryJobStateRunning,
    PBMCreativeFactoryJobStateSuccess,
    PBMCreativeFactoryJobStateError
} PBMCreativeFactoryJobState;

typedef void(^PBMCreativeFactoryJobFinishedCallback)(PBMCreativeFactoryJob * _Nonnull, NSError * _Nullable);

@interface PBMCreativeFactoryJob : NSObject <PBMCreativeResolutionDelegate>

@property (nonatomic, strong, nonnull) PBMAbstractCreative *creative;
@property (nonatomic, assign) PBMCreativeFactoryJobState state;

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initFromCreativeModel:(nonnull PBMCreativeModel *)creativeModel
                                  transaction:(nonnull PBMTransaction *)transaction
                                  serverConnection:(nonnull id<PrebidServerConnectionProtocol>)serverConnection
                              finishedCallback:(nonnull PBMCreativeFactoryJobFinishedCallback)finishedCallback
                              NS_DESIGNATED_INITIALIZER;

- (void)startJob;

@end
