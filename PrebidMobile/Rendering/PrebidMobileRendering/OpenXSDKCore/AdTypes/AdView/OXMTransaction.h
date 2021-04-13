//
//  OXMTransaction.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol OXMTransactionDelegate;

@class WKWebView;
@class UIView;
@class OXMModalManager;
@class OXMAdConfiguration;
@class OXMCreativeModel;
@class OXMAbstractCreative;
@class OXMAdDetails;
@class OXMOpenMeasurementSession;
@class OXMOpenMeasurementWrapper;

@protocol OXMServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN
@interface OXMTransaction : NSObject

@property (nonatomic, readonly, nonnull) OXMAdConfiguration *adConfiguration; // If need to change use resetAdConfiguration
@property (nonatomic, strong) NSMutableArray<OXMAbstractCreative *> *creatives;
@property (nonatomic, strong) NSArray<OXMCreativeModel *> *creativeModels;
@property (nonatomic, strong, nullable) OXMOpenMeasurementSession *measurementSession;
@property (nonatomic, strong) OXMOpenMeasurementWrapper *measurementWrapper;

/**
 SKAdNetwork parameters about an App Store product.
 Used in the StoreKit
 */
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *skadnetProductParameters;

@property (atomic, weak, nullable) id<OXMTransactionDelegate> delegate;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithServerConnection:(id<OXMServerConnectionProtocol>)connection
                         adConfiguration:(OXMAdConfiguration *)adConfiguration
                                  models:(NSArray<OXMCreativeModel *> *)creativeModels NS_DESIGNATED_INITIALIZER;

- (void)startCreativeFactory;
- (nullable OXMAdDetails *)getAdDetails;
- (nullable OXMAbstractCreative *)getFirstCreative;
- (nullable OXMAbstractCreative *)getCreativeAfter:(OXMAbstractCreative *)creative;
- (nullable NSString*)revenueForCreativeAfter:(OXMAbstractCreative *)creative;
- (void)resetAdConfiguration:(OXMAdConfiguration *)adConfiguration;

@end
NS_ASSUME_NONNULL_END
