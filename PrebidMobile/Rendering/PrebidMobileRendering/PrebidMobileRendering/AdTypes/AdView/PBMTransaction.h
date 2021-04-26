//
//  PBMTransaction.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol PBMTransactionDelegate;

@class WKWebView;
@class UIView;
@class PBMModalManager;
@class PBMAdConfiguration;
@class PBMCreativeModel;
@class PBMAbstractCreative;
@class PBMAdDetails;
@class PBMOpenMeasurementSession;
@class PBMOpenMeasurementWrapper;

@protocol PBMServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN
@interface PBMTransaction : NSObject

@property (nonatomic, readonly, nonnull) PBMAdConfiguration *adConfiguration; // If need to change use resetAdConfiguration
@property (nonatomic, strong) NSMutableArray<PBMAbstractCreative *> *creatives;
@property (nonatomic, strong) NSArray<PBMCreativeModel *> *creativeModels;
@property (nonatomic, strong, nullable) PBMOpenMeasurementSession *measurementSession;
@property (nonatomic, strong) PBMOpenMeasurementWrapper *measurementWrapper;

/**
 SKAdNetwork parameters about an App Store product.
 Used in the StoreKit
 */
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *skadnetProductParameters;

@property (atomic, weak, nullable) id<PBMTransactionDelegate> delegate;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithServerConnection:(id<PBMServerConnectionProtocol>)connection
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
