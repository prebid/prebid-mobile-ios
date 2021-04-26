//
//  PBMCreativeModelCollectionMakerVAST.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMCreativeModelMakerResult.h"

@class PBMCreativeModel;
@class PBMAdConfiguration;
@class PBMAdRequestResponseVAST;

@protocol PBMServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN
@interface PBMCreativeModelCollectionMakerVAST : NSObject

@property (strong)PBMAdConfiguration *adConfiguration;
@property (strong)id<PBMServerConnectionProtocol> serverConnection;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithServerConnection:(id<PBMServerConnectionProtocol>)pbmServer
                            adConfiguration:(PBMAdConfiguration *)adConfiguration;

- (void)makeModels:(PBMAdRequestResponseVAST *)requestResponse
   successCallback:(PBMCreativeModelMakerSuccessCallback)successCallback
   failureCallback:(PBMCreativeModelMakerFailureCallback)failureCallback;

@end
NS_ASSUME_NONNULL_END
