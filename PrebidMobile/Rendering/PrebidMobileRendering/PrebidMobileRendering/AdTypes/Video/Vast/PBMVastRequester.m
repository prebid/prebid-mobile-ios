//
//  PBMVastRequester.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMVastRequester.h"

#import "PBMConstants.h"
#import "PBMServerConnectionProtocol.h"
#import "PBMServerResponse.h"
#import "PBMURLComponents.h"
#import "PBMError.h"

static NSString *vastContentType = @"application/x-www-form-urlencoded";

@implementation PBMVastRequester

+ (void)loadVastURL:(NSString *)url connection:(id<PBMServerConnectionProtocol>)connection completion:(PBMAdRequestCallback)completion {
    
    PBMURLComponents *urlComponents = [[PBMURLComponents alloc] initWithUrl:url paramsDict:@{}];
    if (!urlComponents) {
        NSError *error = [PBMError errorWithDescription:@"Failed to create PBMURLComponents" statusCode:PBMErrorCodeUndefined];
        completion(nil, error);
        return;
    }
    
    NSData *data = [[urlComponents argumentsString] dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        NSError *error = [PBMError errorWithDescription:@"Unable to create Data from PBMURLComponents.argumentsString" statusCode:PBMErrorCodeUndefined];
        completion(nil, error);
        return;
    }

    [connection post:urlComponents.urlString
         contentType:vastContentType
                data:data timeout:PBMTimeInterval.CONNECTION_TIMEOUT_DEFAULT
            callback:^(PBMServerResponse * _Nonnull serverResponse) {
        if (serverResponse.error) {
            completion(nil, serverResponse.error);
            return;
        }
        
        if (serverResponse.statusCode != 200) {
            NSString *message = [NSString stringWithFormat:@"Server responded with status code %li", (long)serverResponse.statusCode];
            completion(nil, [PBMError errorWithDescription:message statusCode:serverResponse.statusCode]);
            return;
        }
        
        NSData *vastData = serverResponse.rawData;
        if (!vastData) {
            completion(nil, [PBMError errorWithDescription:@"No Data From Server" statusCode:PBMErrorCodeFileNotFound]);
            return;
        }
        
        completion(serverResponse, nil);
    }];
}

@end
