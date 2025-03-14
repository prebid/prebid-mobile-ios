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
#import "PBMORTBBidExtSkadn.h"

@protocol PBMTransactionDelegate;

@class Bid;
@class WKWebView;
@class UIView;
@class PBMModalManager;
@class PBMAdConfiguration;
@class PBMCreativeModel;
@class PBMAbstractCreative;
@class PBMAdDetails;
@class PBMOpenMeasurementSession;
@class PBMOpenMeasurementWrapper;
@class PBMAdConfiguration;
@class PBMORTBBidExtSkadn;

@protocol PrebidServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN
@interface PBMTransaction : NSObject

@property (nonatomic, readonly, nonnull) PBMAdConfiguration *adConfiguration; // If need to change use resetAdConfiguration
@property (nonatomic, strong) NSMutableArray<PBMAbstractCreative *> *creatives;
@property (nonatomic, strong) NSArray<PBMCreativeModel *> *creativeModels;
@property (nonatomic, strong, nullable) PBMOpenMeasurementSession *measurementSession;
@property (nonatomic, strong) PBMOpenMeasurementWrapper *measurementWrapper;

@property (nonatomic, strong, nullable) Bid * bid;

@property (atomic, weak, nullable) id<PBMTransactionDelegate> delegate;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithServerConnection:(id<PrebidServerConnectionProtocol>)connection
                         adConfiguration:(PBMAdConfiguration *)adConfiguration
                                  models:(NSArray<PBMCreativeModel *> *)creativeModels NS_DESIGNATED_INITIALIZER;

- (void)startCreativeFactory;
- (nullable PBMAdDetails *)getAdDetails;
- (nullable PBMAbstractCreative *)getFirstCreative;
- (nullable PBMAbstractCreative *)getCreativeAfter:(PBMAbstractCreative *)creative;
- (nullable NSString*)revenueForCreativeAfter:(PBMAbstractCreative *)creative;
- (void)resetAdConfiguration:(PBMAdConfiguration *)adConfiguration;

@end
NS_ASSUME_NONNULL_END
