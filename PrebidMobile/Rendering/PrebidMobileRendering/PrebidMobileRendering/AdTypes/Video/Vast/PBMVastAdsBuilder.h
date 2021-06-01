//
//  PBMVastAdsBuilder.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PBMVastParser;
@class PBMVastResponse;
@class PrebidRenderingConfig;
@class PBMVastAbstractAd;

@protocol PBMServerConnectionProtocol;

//TODO: alter PBMServerConnection to deliver NSData.
//Otherwise, done.

typedef void(^PBMVastAdsBuilderCompletionBlock)(NSArray<PBMVastAbstractAd *> * _Nullable, NSError * _Nullable);

@interface PBMVastAdsBuilder : NSObject

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithConnection:(nonnull id<PBMServerConnectionProtocol>)serverConnection NS_DESIGNATED_INITIALIZER;

- (void)buildAds:(nonnull NSData *)data completion:(nonnull PBMVastAdsBuilderCompletionBlock)completionBlock;

- (BOOL)checkHasNoAdsAndFireURIs:(nonnull PBMVastResponse *)vastResponse  NS_SWIFT_NAME(checkHasNoAdsAndFireURIs(vastResponse:));

@end
