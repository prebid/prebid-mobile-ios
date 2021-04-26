//
//  PBMVastRequester.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PBMServerResponse;

@protocol PBMServerConnectionProtocol;

// TODO: need a single typedef for the all app
typedef void(^PBMAdRequestCallback)(PBMServerResponse * _Nullable serverResponse, NSError * _Nullable);

@interface PBMVastRequester : NSObject

+ (void)loadVastURL:(nonnull NSString *)url
         connection:(nonnull id<PBMServerConnectionProtocol>)connection
         completion:(nonnull PBMAdRequestCallback)completion;

@end
