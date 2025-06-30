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
#import "PBMCreativeModelMakerResult.h"

@class PBMCreativeModel;
@class PBMAdConfiguration;
@class PBMAdRequestResponseVAST;

@protocol PrebidServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN
@interface PBMCreativeModelCollectionMakerVAST : NSObject

@property (strong)PBMAdConfiguration *adConfiguration;
@property (strong)id<PrebidServerConnectionProtocol> serverConnection;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithServerConnection:(id<PrebidServerConnectionProtocol>)pbmServer
                            adConfiguration:(PBMAdConfiguration *)adConfiguration;

- (void)makeModels:(PBMAdRequestResponseVAST *)requestResponse
   successCallback:(PBMCreativeModelMakerSuccessCallback)successCallback
   failureCallback:(PBMCreativeModelMakerFailureCallback)failureCallback;

@end
NS_ASSUME_NONNULL_END
