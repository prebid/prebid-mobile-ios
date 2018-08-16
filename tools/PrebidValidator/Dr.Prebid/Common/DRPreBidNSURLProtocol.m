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

#import "DRPreBidNSURLProtocol.h"
@interface DRPreBidNSURLProtocol()<NSURLConnectionDelegate>
@property (nonatomic, strong) NSURLConnection *connection;
@end
@implementation DRPreBidNSURLProtocol

static NSMutableArray *_delegates = nil;

+ (void)setDelegates:(NSArray *)delegates
{
    _delegates = [[NSMutableArray alloc] init];
    for (NSObject *delegate in delegates) {
        [_delegates addObject:delegate];
    }
}

+ (NSMutableArray *)delegates
{
    return _delegates;
}

+ (void)addDelegate:(id <DRPreBidNSURLProtocolDelegate>)delegate
{
    if (_delegates == nil) {
        _delegates = [[NSMutableArray alloc] init];
    }
    [_delegates addObject:delegate];
}
+ (void)removeDelegate: (id <DRPreBidNSURLProtocolDelegate>)delegate
{
    if (_delegates != nil) {
        [_delegates removeObject:delegate];
    }
}

+(BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if ([NSURLProtocol propertyForKey:@"PrebidURLProtocolHandledKey" inRequest:request]) {
        return NO;
    }
    if ([request.URL.absoluteString containsString:@"https://pubads.g.doubleclick.net/gampad/ads?"]) {
        return  YES;
    }
    return NO;
}



- (void)startLoading
{
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

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (_delegates != nil) {
        for (NSObject * delegate in _delegates) {
            if ([delegate.class conformsToProtocol:@protocol(DRPreBidNSURLProtocolDelegate)]) {
                NSObject<DRPreBidNSURLProtocolDelegate> *d = (NSObject<DRPreBidNSURLProtocolDelegate> *) delegate;
                [d didReceiveResponse:dataString forRequest:self.request.URL.absoluteString];
            }
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

@end

