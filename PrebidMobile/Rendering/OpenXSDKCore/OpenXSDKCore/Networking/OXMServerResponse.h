//
//  OXMServerResponse.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OXMServerResponse : NSObject

@property (nullable) NSDictionary <NSString *, id> *jsonDict;
@property (nullable) NSData *rawData;
@property (nullable) NSDictionary <NSString *, NSString *> *requestHeaders;
@property (nullable) NSDictionary <NSString *, NSString *> *responseHeaders;
@property (nullable) NSString *requestURL;
@property (nullable) NSError *error;
@property NSInteger statusCode;

@end

typedef void(^OXMAdRequestCallback)(OXMServerResponse * _Nullable serverResponse, NSError * _Nullable);
