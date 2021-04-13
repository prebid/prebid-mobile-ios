//
//  OXMVastRequester.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMVastRequester.h"

#import "OXMConstants.h"
#import "OXMServerConnectionProtocol.h"
#import "OXMServerResponse.h"
#import "OXMURLComponents.h"
#import "OXMError.h"

static NSString *vastContentType = @"application/x-www-form-urlencoded";

@implementation OXMVastRequester

+ (void)loadVastURL:(NSString *)url connection:(id<OXMServerConnectionProtocol>)connection completion:(OXMAdRequestCallback)completion {
    
    OXMURLComponents *urlComponents = [[OXMURLComponents alloc] initWithUrl:url paramsDict:@{}];
    if (!urlComponents) {
        NSError *error = [OXMError errorWithDescription:@"Failed to create OXMURLComponents" statusCode:OXAErrorCodeUndefined];
        completion(nil, error);
        return;
    }
    
    NSData *data = [[urlComponents argumentsString] dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        NSError *error = [OXMError errorWithDescription:@"Unable to create Data from OXMURLComponents.argumentsString" statusCode:OXAErrorCodeUndefined];
        completion(nil, error);
        return;
    }

    [connection post:urlComponents.urlString
         contentType:vastContentType
                data:data timeout:OXMTimeInterval.CONNECTION_TIMEOUT_DEFAULT
            callback:^(OXMServerResponse * _Nonnull serverResponse) {
        if (serverResponse.error) {
            completion(nil, serverResponse.error);
            return;
        }
        
        if (serverResponse.statusCode != 200) {
            NSString *message = [NSString stringWithFormat:@"Server responded with status code %li", (long)serverResponse.statusCode];
            completion(nil, [OXMError errorWithDescription:message statusCode:serverResponse.statusCode]);
            return;
        }
        
        NSData *vastData = serverResponse.rawData;
        if (!vastData) {
            completion(nil, [OXMError errorWithDescription:@"No Data From Server" statusCode:OXAErrorCodeFileNotFound]);
            return;
        }
        
        completion(serverResponse, nil);
    }];
}

@end
