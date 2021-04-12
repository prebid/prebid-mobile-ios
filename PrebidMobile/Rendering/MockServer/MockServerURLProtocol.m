#import "MockServerURLProtocol.h"
#import "MockServer.h"
#import "MockServerRule.h"
@import Foundation;


@implementation MockServerURLProtocol

//Check every outbound URL.
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    BOOL ret = [[MockServer singleton] canHandle:request];
    if (ret) {
        NSLog(@"MockServerURLProtocol handling request: [%@]", request.URL.absoluteString);
    } else {
        NSLog(@"MockServerURLProtocol NOT handling request: [%@]", request.URL.absoluteString);
    }
    return ret;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    [[MockServer singleton] mockServerInteraction:self];
}

- (void)stopLoading {
}





@end
