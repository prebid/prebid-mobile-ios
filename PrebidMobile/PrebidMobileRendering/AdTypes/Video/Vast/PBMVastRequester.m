/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "PBMVastRequester.h"

#import "PBMConstants.h"
#import "PBMURLComponents.h"
#import "PBMError.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

static NSString *vastContentType = @"application/x-www-form-urlencoded";

@implementation PBMVastRequester

+ (void)loadVastURL:(NSString *)url connection:(id<PrebidServerConnectionProtocol>)connection completion:(AdRequestCallback)completion {
    
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
            callback:^(PrebidServerResponse * _Nonnull serverResponse) {
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
