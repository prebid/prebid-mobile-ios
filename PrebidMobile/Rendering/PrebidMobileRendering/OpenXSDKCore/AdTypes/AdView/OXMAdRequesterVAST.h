//
//  OXMAdRequesterVAST.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXMAdConfiguration.h"
#import "OXMAdLoadManagerVAST.h"

NS_ASSUME_NONNULL_BEGIN

@class OXMServerResponse;
@protocol OXMServerConnectionProtocol;

@interface OXMAdRequesterVAST : NSObject

@property (nonatomic, strong) OXMAdConfiguration *adConfiguration;
@property (nonatomic, strong) id<OXMServerConnectionProtocol> serverConnection;
@property (nonatomic, weak, nullable) OXMAdLoadManagerVAST *adLoadManager;

- (instancetype)initWithServerConnection:(id<OXMServerConnectionProtocol>)serverConnection
                         adConfiguration:(OXMAdConfiguration *)adConfiguration;
// - (void)load;
- (void)buildVastAdsArray:(NSData *)rawVASTData;

NS_ASSUME_NONNULL_END

@end
