//
//  OXMCreativeModelCollectionMakerVAST.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXMCreativeModelMakerResult.h"

@class OXMCreativeModel;
@class OXMAdConfiguration;
@class OXMAdRequestResponseVAST;

@protocol OXMServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN
@interface OXMCreativeModelCollectionMakerVAST : NSObject

@property (strong)OXMAdConfiguration *adConfiguration;
@property (strong)id<OXMServerConnectionProtocol> serverConnection;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithServerConnection:(id<OXMServerConnectionProtocol>)oxmServer
                            adConfiguration:(OXMAdConfiguration *)adConfiguration;

- (void)makeModels:(OXMAdRequestResponseVAST *)requestResponse
   successCallback:(OXMCreativeModelMakerSuccessCallback)successCallback
   failureCallback:(OXMCreativeModelMakerFailureCallback)failureCallback;

@end
NS_ASSUME_NONNULL_END
