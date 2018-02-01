/*   Copyright 2017 Prebid.org, Inc.
 
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

#import "PrebidCache.h"
#import "PrebidURLProtocol.h"

@interface PrebidURLProtocol () <NSURLConnectionDelegate>

@property (nonatomic, strong) NSURLConnection *connection;

@end

@implementation PrebidURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if ([NSURLProtocol propertyForKey:@"PrebidURLProtocolHandledKey" inRequest:request]) {
        return NO;
    }
    if ([request.URL.absoluteString containsString:@"prebid.adnxs.com/pbc/v1/cache"]) {
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading {
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:@"PrebidURLProtocolHandledKey" inRequest:newRequest];

    NSRange range = [newRequest.URL.absoluteString rangeOfString:@"uuid="];
    if (range.location == NSNotFound) {
        NSLog(@"No uuid in URL");
    }
    NSString *uuid = [newRequest.URL.absoluteString substringFromIndex:(range.location + 5)];

    NSDictionary *dict = (NSDictionary *)[[PrebidCache globalCache] objectForKey:uuid];
    if (dict != nil) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSUTF8StringEncoding
                                                         error:nil];
        NSURLResponse* response = [[NSHTTPURLResponse alloc] initWithURL:[self.request URL] statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:@{@"Access-Control-Allow-Origin": @"https://pubads.g.doubleclick.net", @"Access-Control-Allow-Credentials" : @"true"}];

        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [self.client URLProtocol:self didLoadData:data];
        [self.client URLProtocolDidFinishLoading:self];

        [[PrebidCache globalCache] removeCacheForKey:uuid];
    }
}

- (void)stopLoading {
    [self.connection cancel];
    self.connection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

@end
