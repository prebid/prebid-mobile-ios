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
@property (nonatomic) NSURLSessionDataTask *sessionData;
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
    
    [[PBVSharedConstants sharedInstance] setRequestString:newRequest.URL.absoluteString];
    [NSURLProtocol setProperty:@YES forKey:@"LineItemProtocolHandledKey" inRequest:newRequest];
    
   self.sessionData = [[NSURLSession sharedSession] dataTaskWithRequest:newRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       
       [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
       [self.client URLProtocol:self didLoadData:data];
       [self.client URLProtocolDidFinishLoading:self];
       
       NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
       if (html.length) {
           [[PBVSharedConstants sharedInstance] setResponseString:html];
        }
    }];
    
    [self.sessionData resume];
}

- (void)stopLoading {
    [self.sessionData cancel];
    self.sessionData = nil;
}

@end
