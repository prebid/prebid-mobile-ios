//
//  SDKValidationURLProtocol.m
//  Dr.Prebid
//
//  Created by Wei Zhang on 9/10/18.
//  Copyright © 2018 Prebid. All rights reserved.
//

#import "SDKValidationURLProtocol.h"
@interface SDKValidationURLProtocol() <NSURLConnectionDelegate>
@property (nonatomic, strong) NSURLConnection *connection;
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
    if ([request.URL.absoluteString containsString:@"prebid.adnxs.com/pbs/v1/openrtb2/auction"]) {
        if (classDelegate != nil) {
            [classDelegate willInterceptPrebidServerRequest];
        }
        return YES;
    }
    if (![request.URL.absoluteString containsString:@"hb_dr_prebid"] && ([request.URL.absoluteString containsString:@"ads.mopub.com/m/ad?"] || [request.URL.absoluteString containsString:@"pubads.g.doubleclick.net/gampad/ads?"]))
    {
        if (classDelegate != nil) {
            [classDelegate willInterceptAdServerRequest:request.URL.absoluteString];
        }
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

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
    NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (classDelegate != nil) {
        if ([self.request.URL.absoluteString containsString:@"prebid.adnxs.com/pbs/v1/openrtb2/auction"]) {
            [classDelegate didReceivePrebidServerResponse:content];
        } else {
            [classDelegate didReceiveAdServerResponse:content forRequest:self.request.URL.absoluteString];
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
