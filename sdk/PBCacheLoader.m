/*   Copyright 2017 APPNEXUS INC
 
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

#import "PBCacheLoader.h"

static NSString *const kPrebidCacheEndpoint = @"https://prebid.adnxs.com/pbc/v1/get?uuid=";

@interface PBCacheLoader ()

@property (nonatomic, strong) NSString *cacheId;

@end

@implementation PBCacheLoader

- (instancetype)initWithCacheId:(NSString *)cacheId {
    self = [super init];
    if (self) {
        self.cacheId = cacheId;
    }
    return self;
}

- (void)requestAdmWithCompletionBlock:(nullable void (^)(NSDictionary *))completionBlock{
    NSString *cacheURL = [kPrebidCacheEndpoint stringByAppendingString:self.cacheId];
    
    NSMutableURLRequest *cacheRequest = [[NSMutableURLRequest alloc] init];
    [cacheRequest setHTTPMethod:@"GET"];
    [cacheRequest setURL:[NSURL URLWithString:cacheURL]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:cacheRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            NSError *parseError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            completionBlock(responseDictionary);
            NSLog(@"The response from Prebid Cache is - %@",responseDictionary);
        } else {
            NSLog(@"Error retrieving data from the cache");
        }
    }];
    [dataTask resume];
}

@end
