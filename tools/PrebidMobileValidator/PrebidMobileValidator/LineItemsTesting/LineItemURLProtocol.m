//
//  LineItemURLProtocol.m
//  PrebidMobileValidator
//
//  Created by Punnaghai Puviarasu on 4/17/18.
//  Copyright © 2018 AppNexus. All rights reserved.
//

#import "LineItemURLProtocol.h"
#import "PBVSharedConstants.h"

@interface LineItemURLProtocol () <NSURLConnectionDelegate>

@property (nonatomic, strong) NSURLConnection *connection;

@end

@implementation LineItemURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if ([NSURLProtocol propertyForKey:@"LineItemProtocolHandledKey" inRequest:request]) {
        return NO;
    }
    if ([request.URL.absoluteString containsString:@"ads.mopub.com/m/ad"] ||
        [request.URL.absoluteString containsString:@"rubiconproject.com/cache"]) {
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
    [[PBVSharedConstants sharedInstance] setRequestString:[newRequest description]];
    [NSURLProtocol setProperty:@YES forKey:@"LineItemProtocolHandledKey" inRequest:newRequest];
    
    __weak LineItemURLProtocol *weakSelf = self;
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:newRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        LineItemURLProtocol *__strong strongSelf = weakSelf;
        NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (html.length) {
                    [[PBVSharedConstants sharedInstance] setResponseString:html];
                    strongSelf.responseString = html;
                }
        }
    ] resume];
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
