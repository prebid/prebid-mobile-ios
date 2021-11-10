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

#import "MockServerRule.h"

@implementation MockServerRule

//Designated inits
- (instancetype) initWithURLNeedle:(NSString*)urlNeedle connectionID:(NSUUID *)connectionID data:(NSData*)data responseHeaderFields:(NSMutableDictionary*)responseHeaderFields {
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.willRespond = YES;
    self.statusCode = 200;
    self.urlNeedle = urlNeedle;
    self.data = data;
    self.responseHeaderFields = [NSMutableDictionary dictionary];
    self.connectionID = connectionID;
    if (responseHeaderFields != nil) {
        [self.responseHeaderFields addEntriesFromDictionary:responseHeaderFields];
    }
    
    self.httpVersion = @"HTTP/2.0";
    
    if (self.data != nil) {
        NSString* contentLengthKey = @"Content-Length";
        NSString* contentLengthVal = [NSString stringWithFormat:@"%lu", (unsigned long)[self.data length]];
        [self.responseHeaderFields setObject:contentLengthVal forKey:contentLengthKey];
    }
    
    return self;
}

//Convenience inits
- (instancetype)initWithURLNeedle:(NSString *)needle mimeType:(NSString *)mimeType connectionID:(NSUUID *)connectionID data:(NSData *)data {
    NSMutableDictionary* responseHeaderFields = [@{@"Content-Type":mimeType} mutableCopy];
    return [self initWithURLNeedle:needle connectionID:connectionID data:data responseHeaderFields:responseHeaderFields];
}

- (instancetype)initWithURLNeedle:(NSString *)needle mimeType:(NSString *)mimeType connectionID:(NSUUID *)connectionID fileName:(NSString *)fileName {
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSString* bundlePath = [bundle bundlePath];
    NSURL* url = [NSURL fileURLWithPath:bundlePath];
    url = [url URLByAppendingPathComponent:fileName];
    NSData* fileData = [NSData dataWithContentsOfURL:url];
    if (fileData == nil || fileData.length == 0) {
        NSLog(@"ERROR! File [%@] is empty!", fileName);
    }
    return [self initWithURLNeedle:needle mimeType:mimeType connectionID:(NSUUID *)connectionID data:fileData];
}

- (instancetype)initWithURLNeedle:(NSString *)needle mimeType:(NSString *)mimeType connectionID:(NSUUID *)connectionID strResponse:(NSString *)strResponse {
    NSData* data = [strResponse dataUsingEncoding:NSUTF8StringEncoding];
    if (data == nil || data.length == 0) {
        NSLog(@"ERROR! Response data is empty!");
    }
    return [self initWithURLNeedle:needle mimeType:mimeType connectionID:connectionID data:data];
}

- (instancetype)initWithFireAndForgetURLNeedle:(NSString *)needle connectionID:(NSUUID *)connectionID {
    NSData* data = [[NSData alloc] init];
    NSDictionary* responseHeaderFields = [NSDictionary dictionary];
    return [self initWithURLNeedle:needle connectionID:connectionID data:data responseHeaderFields:responseHeaderFields];
}

-(void)load:(NSURLProtocol*)nsURLProtocol {
    
    if (!self.willRespond) {
        return;
    }
    
    NSHTTPURLResponse* response = [[NSHTTPURLResponse alloc] initWithURL:nsURLProtocol.request.URL statusCode:self.statusCode HTTPVersion:self.httpVersion headerFields:self.responseHeaderFields];
    
    [nsURLProtocol.client URLProtocol:nsURLProtocol didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    
    //If the request is just for headers, leave early.
    if ([nsURLProtocol.request.HTTPMethod isEqualToString:@"HEAD"]) {
        [nsURLProtocol.client URLProtocolDidFinishLoading:nsURLProtocol];
        return;
    }
    
    //Send response data
    NSData* responseData = self.data;
    if (self.data && self.data.length > 0) {
        [nsURLProtocol.client URLProtocol:nsURLProtocol didLoadData:responseData];
    }
    
    [nsURLProtocol.client URLProtocolDidFinishLoading:nsURLProtocol];
}

@end
