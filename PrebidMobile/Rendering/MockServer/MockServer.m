//
//  MockServer.m
//  OpenXInternalTestAppObjC
//
//  Copyright © 2017 OpenX. All rights rreserved.
//

@import Foundation;

@import PrebidMobileRendering;

#import "PBMServerConnection.h"
#import "MockServer.h"
#import "MockServerRule.h"

@interface MockServer()
@property NSMutableArray* rules;
@end

@implementation MockServer

-(nonnull instancetype) init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    [self reset];
    
    return self;
}

+(nonnull instancetype) singleton {
    static MockServer *ret = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ret = [[MockServer alloc] init];
    });
    return ret;
}

-(void) mockServerInteraction:(nonnull NSURLProtocol *)nsURLProtocol {
    NSURLRequest* request = nsURLProtocol.request;
    MockServerRule* rule = [self lookupRuleForRequest:request logging:YES];
    if (rule.mockServerReceivedRequestHandler != nil) {
        rule.mockServerReceivedRequestHandler(request);
    }
    
    [rule load:nsURLProtocol];
}

-(void) reset {
    self.rules = [NSMutableArray array];
    self.useNotFoundRule = YES;
    self.notFoundRule = [[MockServerRule alloc] initWithURLNeedle:@"" mimeType:@"text/html" connectionID:[NSUUID new] strResponse:@"404 - File Not Found"];
    self.notFoundRule.statusCode = 404;
}

-(void) resetRules:(NSArray<MockServerRule *> *)rules {
    [self.rules removeAllObjects];
    [self.rules addObjectsFromArray:rules];
}

-(BOOL) canHandle:(nonnull NSURLRequest*) request {

    //If we are allowed to respond with the notFound rule then we can handle any request.
    if (self.useNotFoundRule) {
        return YES;
    }
    
    //Otherwise, if the *only* rule we found is the notFoundRule, we can't handle it.
    MockServerRule* rule = [self lookupRuleForRequest:request logging:NO];
    if (rule == self.notFoundRule) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Private Methods
-(nullable MockServerRule*) lookupRuleForRequest:(nonnull NSURLRequest*) request logging:(BOOL) logging {
    
    if (request.URL == nil) {
        return nil;
    }
    
    NSString *connectionID = request.allHTTPHeaderFields[self.connectionIDHeaderKey];
    if (request.allHTTPHeaderFields[PBMServerConnection.isPBMRequestKey] && !connectionID) {
        NSLog(@"All requests in mocked tests must be provided with internal connection ID in the header.");
        return nil;
    }
    
    for (MockServerRule* rule in self.rules) {
        NSString *ruleID = [rule.connectionID UUIDString];
        if (!ruleID) {
            NSLog(@"All mocked rules must be provided with connection ID");
            continue;
        }
        
        if ([request.URL.absoluteString containsString:rule.urlNeedle] && [connectionID isEqualToString:ruleID]) {
            if (logging) {
                NSLog(@"MockServer handling request: [%@]", request.URL.absoluteString);
            }
            return rule;
        }
    }

    if (logging) {
        NSLog(@"MockServer 404ing on request: [%@]", request.URL.absoluteString);
    }
    return self.notFoundRule;
}
@end
