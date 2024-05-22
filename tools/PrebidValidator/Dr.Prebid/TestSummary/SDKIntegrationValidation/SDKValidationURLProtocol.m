/*
 *    Copyright 2018 Prebid.org, Inc.
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

#import "SDKValidationURLProtocol.h"
@interface SDKValidationURLProtocol() <NSURLConnectionDelegate>
@property (nonatomic, strong) NSURLConnection *connection;
@property NSMutableData *data;
@end

@implementation SDKValidationURLProtocol
static id<SDKValidationURLProtocolDelegate> classDelegate = nil;

+ (void)setDelegate:(id<SDKValidationURLProtocolDelegate>)delegate
{
    classDelegate = delegate;
}

+ (id<SDKValidationURLProtocolDelegate>)delegate
{
    return classDelegate;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if ([NSURLProtocol propertyForKey:@"PrebidURLProtocolHandledKey" inRequest:request]) {
        return NO;
    }
    if ([NSURLProtocol propertyForKey:@"DemandValidationRequest" inRequest:request]) {
        return NO;
    }
    if ([SDKValidationURLProtocol supportedPBSHost:request.URL.absoluteString]) {
        if (classDelegate != nil) {
            [classDelegate willInterceptPrebidServerRequest];
        }
        return YES;
    }
    if (![request.URL.absoluteString containsString:@"hb_dr_prebid"] && [request.URL.absoluteString containsString:@"pubads.g.doubleclick.net/gampad/ads?"])
    {
        if (classDelegate != nil) {
            [classDelegate willInterceptAdServerRequest:request.URL.absoluteString withPostData:nil];
        }
        return YES;
    }
    if ([request.URL.absoluteString containsString:@"ads.mopub.com/m/ad"]){
        if (request.HTTPBodyStream != nil) {
            NSInputStream *stream = request.HTTPBodyStream;
            uint8_t byteBuffer[4096];
            [stream open];
            if (stream.hasBytesAvailable)
            {
                NSInteger bytesRead = [stream read:byteBuffer maxLength:sizeof(byteBuffer)]; //max len must match buffer size
                NSString *stringFromData = [[NSString alloc] initWithBytes:byteBuffer length:bytesRead encoding:NSUTF8StringEncoding];
                if(![stringFromData containsString:@"hb_dr_prebid"] ){
                    if (classDelegate != nil) {
                        [classDelegate willInterceptAdServerRequest: request.URL.absoluteString withPostData: stringFromData];
                    }
                    return YES;
                }
            }
        }
    }
    return NO;
}

+ (BOOL) supportedPBSHost:(NSString *) hostURL {
    if (hostURL != nil) {
        if ([hostURL containsString:@"prebid.adnxs.com/pbs/v1/openrtb2/auction"] || [hostURL containsString:@"prebid-server.rubiconproject.com/openrtb2/auction"]) {
            return YES;
        }
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading
{
    self.data = [[NSMutableData alloc] init];
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:@"PrebidURLProtocolHandledKey" inRequest:newRequest];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
#pragma clang diagnostic pop
}

- (void)stopLoading
{
    [self.connection cancel];
    self.connection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
    [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
    NSString *content = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
    if (classDelegate != nil) {
        if ([SDKValidationURLProtocol supportedPBSHost:self.request.URL.absoluteString]) {
            [classDelegate didReceivePrebidServerResponse:content];
        } else {
            [classDelegate didReceiveAdServerResponse:content forRequest:self.request.URL.absoluteString];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}


@end
