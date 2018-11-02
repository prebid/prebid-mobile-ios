//
//  MPURLRequest.m
//  MoPubSDK
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import "MPURLRequest.h"
#import "MPAPIEndpoints.h"
#import "MPLogging.h"
#import "MPURL.h"

// All requests have a 10 second timeout.
const NSTimeInterval kRequestTimeoutInterval = 10.0;

NS_ASSUME_NONNULL_BEGIN
@interface MPURLRequest()

@end

@implementation MPURLRequest

- (instancetype)initWithURL:(NSURL *)URL {
    // In the event that the URL passed in is really a MPURL type,
    // extract the POST body.
    NSMutableDictionary<NSString *, NSObject *> * postData = [NSMutableDictionary dictionary];
    if ([URL isKindOfClass:[MPURL class]]) {
        MPURL * mpUrl = (MPURL *)URL;
        if ([NSJSONSerialization isValidJSONObject:mpUrl.postData]) {
            postData = mpUrl.postData;
        }
        else {
            MPLogFatal(@"POST Data is not serializable into JSON:\n%@", mpUrl.postData);
        }
    }

    // Requests sent to MoPub should always be in POST format. All other requests
    // should be sent as a normal GET.
    BOOL isMoPubRequest = [URL.host isEqualToString:MOPUB_BASE_HOSTNAME];
    NSURL * requestUrl = URL;
    if (isMoPubRequest) {
        // Move the query parameters to the POST data dictionary.
        // NSURLQUeryItem automatically URL decodes the query parameter name and value when
        // using the `name` and `value` properties.
        NSURLComponents * components = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
        [components.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            postData[obj.name] = obj.value;
        }];

        // The incoming URL may contain query parameters; we will need to strip them out.
        components.queryItems = nil;
        requestUrl = components.URL;
    }

    if (self = [super initWithURL:requestUrl]) {
        // Generate the request
        [self setHTTPShouldHandleCookies:NO];
        [self setValue:MPURLRequest.userAgent forHTTPHeaderField:@"User-Agent"];
        [self setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [self setTimeoutInterval:kRequestTimeoutInterval];

        // Request contains POST data or is a MoPub request; the should be a POST
        // with a UTF-8 JSON payload as the HTTP body.
        if (isMoPubRequest || postData.count > 0) {
            [self setHTTPMethod:@"POST"];
            [self setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

            // Generate the JSON body from the POST parameters
            NSError * error = nil;
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:postData options:NSJSONWritingPrettyPrinted error:&error];

            // Set the request body with the query parameter key/value pairs if there was no
            // error in generating a JSON from the dictionary.
            if (error == nil) {
                [self setValue:[NSString stringWithFormat:@"%lu", (unsigned long)jsonData.length] forHTTPHeaderField:@"Content-Length"];
                [self setHTTPBody:jsonData];
            }
            else {
                MPLogError(@"Could not generate JSON body from %@", postData);
            }
        }
    }

    return self;
}

+ (MPURLRequest *)requestWithURL:(NSURL *)URL {
    return [[MPURLRequest alloc] initWithURL:URL];
}

- (NSString *)description {
    if (self.HTTPBody != nil) {
        NSString * httpBody = [[NSString alloc] initWithData:self.HTTPBody encoding:NSUTF8StringEncoding];
        return [NSString stringWithFormat:@"%@\n%@", self.URL, httpBody];
    }
    else {
        return self.URL.absoluteString;
    }
}

/**
 Retrieves the current user agent as determined by @c UIWebView.
 @returns The user agent.
 */
+ (NSString *)userAgent {
    static NSString * ua = nil;

    if (ua == nil) {
        ua = [[[UIWebView alloc] init] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    }

    return ua;
}

@end
NS_ASSUME_NONNULL_END
