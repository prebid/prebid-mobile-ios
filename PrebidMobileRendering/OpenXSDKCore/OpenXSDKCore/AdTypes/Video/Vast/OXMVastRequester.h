//
//  OXMVastRequester.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OXMServerResponse;

@protocol OXMServerConnectionProtocol;

// TODO: need a single typedef for the all app
typedef void(^OXMAdRequestCallback)(OXMServerResponse * _Nullable serverResponse, NSError * _Nullable);

@interface OXMVastRequester : NSObject

+ (void)loadVastURL:(nonnull NSString *)url
         connection:(nonnull id<OXMServerConnectionProtocol>)connection
         completion:(nonnull OXMAdRequestCallback)completion;

@end
