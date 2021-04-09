//
//  MockServerRuleRedirect.m
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MockServerRuleRedirect.h"

@implementation MockServerRuleRedirect


- (instancetype) initWithURLNeedle:(NSString*)urlNeedle connectionID:(NSUUID *)connectionID data:(NSData*)data responseHeaderFields:(NSMutableDictionary*)responseHeaderFields {
    self = [super initWithURLNeedle:urlNeedle connectionID:connectionID data:data responseHeaderFields:responseHeaderFields];
    self.statusCode = 302;
    return self;
}


- (void) load:(nonnull NSURLProtocol*)nsURLProtocol {
    
    if (!self.redirectRequest) {
        [super load:nsURLProtocol];
    }
    
    NSMutableDictionary* responseHeaderFields = [self.responseHeaderFields mutableCopy];
    [responseHeaderFields setObject:self.redirectRequest.URL.absoluteString forKey:@"Location"];
    
    NSHTTPURLResponse* response = [[NSHTTPURLResponse alloc] initWithURL:nsURLProtocol.request.URL statusCode:self.statusCode HTTPVersion:self.httpVersion headerFields:self.responseHeaderFields];
    
    //Instead of sending data, redirect to the redirectRequest
    [nsURLProtocol.client URLProtocol:nsURLProtocol wasRedirectedToRequest:self.redirectRequest redirectResponse:response];
   
    [nsURLProtocol.client URLProtocolDidFinishLoading:nsURLProtocol];
}


@end



