//
//  OXMVastAdsBuilder.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OXMVastParser;
@class OXMVastResponse;
@class OXASDKConfiguration;
@class OXMVastAbstractAd;

@protocol OXMServerConnectionProtocol;

//TODO: alter OXMServerConnection to deliver NSData.
//Otherwise, done.

typedef void(^OXMVastAdsBuilderCompletionBlock)(NSArray<OXMVastAbstractAd *> * _Nullable, NSError * _Nullable);

@interface OXMVastAdsBuilder : NSObject

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithConnection:(nonnull id<OXMServerConnectionProtocol>)serverConnection NS_DESIGNATED_INITIALIZER;

- (void)buildAds:(nonnull NSData *)data completion:(nonnull OXMVastAdsBuilderCompletionBlock)completionBlock;

- (BOOL)checkHasNoAdsAndFireURIs:(nonnull OXMVastResponse *)vastResponse  NS_SWIFT_NAME(checkHasNoAdsAndFireURIs(vastResponse:));

@end
