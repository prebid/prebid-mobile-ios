//
//  PBMAdRequesterVAST.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMAdConfiguration.h"
#import "PBMAdLoadManagerVAST.h"

NS_ASSUME_NONNULL_BEGIN

@class PBMServerResponse;
@protocol PBMServerConnectionProtocol;

@interface PBMAdRequesterVAST : NSObject

@property (nonatomic, strong) PBMAdConfiguration *adConfiguration;
@property (nonatomic, strong) id<PBMServerConnectionProtocol> serverConnection;
@property (nonatomic, weak, nullable) PBMAdLoadManagerVAST *adLoadManager;

- (instancetype)initWithServerConnection:(id<PBMServerConnectionProtocol>)serverConnection
                         adConfiguration:(PBMAdConfiguration *)adConfiguration;
// - (void)load;
- (void)buildVastAdsArray:(NSData *)rawVASTData;

NS_ASSUME_NONNULL_END

@end
