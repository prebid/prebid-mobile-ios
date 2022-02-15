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

#import "PBMServerConnection.h"
#import "PBMServerResponse.h"
#import "PBMFunctions+Private.h"
#import "PBMUserAgentService.h"
#import "PBMConstants.h"
#import "PBMMacros.h"
#import "PBMError.h"
#import "PBMError.h"

NSString *const HTTPMethodGET = @"GET";
NSString *const HTTPMethodHEAD = @"HEAD";
NSString *const HTTPMethodPOST = @"POST";
NSString *const PrebidMobileErrorDomain = @"org.prebid.mobile";


@interface PBMServerConnection ()

// The unique identifier of connection. Predominantly uses in tests.
@property (nonatomic, strong) NSUUID* internalID;

@end


@implementation PBMServerConnection

@synthesize userAgentService = _userAgentService;

static NSString *PBMUserAgentHeaderKey = @"User-Agent";
static NSString *PBMContentTypeKey = @"Content-Type";
static NSString *PBMContentTypeVal = @"application/json";
static NSString *PBMInternalIDKey = @"PBMConnectionID";
static NSString *PBMIsPBMRequestKey = @"PBMIsPBMRequest";

#pragma mark - Class properties
+ (nonnull instancetype)shared {
    static PBMServerConnection *shared = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[PBMServerConnection alloc] init];
    });

    return shared;
}

+ (NSString *)userAgentHeaderKey {
    return PBMUserAgentHeaderKey;
}

+ (NSString *)contentTypeKey {
    return PBMContentTypeKey;
}

+ (NSString *)contentTypeVal {
    return PBMContentTypeVal;
}

+ (nonnull NSString *)internalIDKey {
    // The key for request's header where Connection places the ConnectionID
    // Must be used only in tests.
    return PBMInternalIDKey;
}

+ (nonnull NSString *)isPBMRequestKey {
    // The key for request's header of PBM ServerConnection requests
    // Must be used only in tests.
    return PBMIsPBMRequestKey;
}

#pragma mark - Init
- (instancetype)init {
    return (self = [self init:[PBMUserAgentService shared]]);
}

- (instancetype)init:(PBMUserAgentService *)userAgentService {
    if (!(self = [super init])) {
        return nil;
    }
    _protocolClasses = [NSMutableArray new];
    _userAgentService = userAgentService;
    _internalID = [NSUUID new];
    
    return self;
}

#pragma mark - Public Methods

- (void)fireAndForget:(NSString *)resourceURL {
    NSMutableURLRequest *request = [self createRequest:resourceURL];
    if (!request) {
        return;
    }
    
    request.HTTPMethod = HTTPMethodGET;

    NSURLSession *session = [self createSession:[PBMTimeInterval FIRE_AND_FORGET_TIMEOUT]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request];
    [task resume];
}

// HEAD is the same as GET but the server doesn't return a body.
- (void)head:(NSString *)resourceURL timeout:(NSTimeInterval)timeout callback:(PBMServerResponseCallback)callback {
    [self get:resourceURL timeout:timeout headersOnly:YES callback:callback];
}

- (void)get:(NSString *)resourceURL timeout:(NSTimeInterval)timeout callback:(PBMServerResponseCallback)callback {
    [self get:resourceURL timeout:timeout headersOnly:NO callback:callback];
}

- (void)post:(NSString *)resourceURL data:(NSData *)data timeout:(NSTimeInterval)timeout callback:(PBMServerResponseCallback)callback {
    [self post:resourceURL contentType:PBMServerConnection.contentTypeVal data:data timeout:timeout callback:callback];
}

- (void)post:(NSString *)resourceURL contentType:(NSString *)contentType data:(NSData *)data timeout:(NSTimeInterval)timeout callback:(PBMServerResponseCallback)callback {
    NSMutableURLRequest *request = [self createRequest:resourceURL];
    if (!request) {
        return;
    }

    request.HTTPMethod = HTTPMethodPOST;
    request.HTTPBody = data;
    request.timeoutInterval = timeout;
    [request setValue:contentType forHTTPHeaderField:PBMServerConnection.contentTypeKey];

    NSURLSession *session = [self createSession:timeout];
    NSURLSessionTask *task = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        [self processResponse:request urlResponse:response responseData:data error:error fullServerCallback:callback];
    }];
    [task resume];
}

- (void)download:(NSString *)resourceURL callback:(PBMServerResponseCallback)callback {
    NSMutableURLRequest *request = [self createRequest:resourceURL];
    if (!request) {
        return;
    }
    
    [request setValue:PBMServerConnection.contentTypeVal forHTTPHeaderField:PBMServerConnection.contentTypeKey];
    
    NSURLSession *session = [self createSession:[PBMTimeInterval FIRE_AND_FORGET_TIMEOUT]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self processResponse:request urlResponse:response responseData:data error:error fullServerCallback:callback];
    }];
    [task resume];
}

#pragma mark - Private Methods
- (void)get:(NSString *)resourceURL timeout:(NSTimeInterval)timeout headersOnly:(BOOL)heardersOnly callback:(PBMServerResponseCallback)callback {
    NSMutableURLRequest *request = [self createRequest:resourceURL];
    if (!request) {
        return;
    }

    request.HTTPMethod = (heardersOnly) ? HTTPMethodHEAD : HTTPMethodGET;
    request.timeoutInterval = timeout;
    [request setValue:PBMServerConnection.contentTypeVal forHTTPHeaderField:PBMServerConnection.contentTypeKey];

    NSURLSession *session = [self createSession:timeout];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        [self processResponse:request urlResponse:response responseData:data error:error fullServerCallback:callback];
    }];
    [task resume];
}

- (void)processResponse:(NSURLRequest *)request
            urlResponse:(nullable NSURLResponse *)urlResponse
           responseData:(nullable NSData *)responseData
                  error:(nullable NSError *)error
     fullServerCallback:(PBMServerResponseCallback)fullServerCallback
{
    PBMServerResponse *serverResponse = [PBMServerResponse new];
    PBMAssert(request);

    serverResponse.requestURL = (request && request.URL) ? request.URL.path : nil;
    serverResponse.requestHeaders = request ? request.allHTTPHeaderFields : nil;

    // If there is an error, we don't care about the body
    if (error) {
        serverResponse.error = error;
        fullServerCallback(serverResponse);
        return;
    }

    // Get HTTPURLResponse-specific fields
    NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)urlResponse;
    if (httpURLResponse == nil || ![httpURLResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        serverResponse.error = [PBMError errorWithMessage:@"Response not an HTTPURLResponse" type:PBMErrorTypeServerError];
        fullServerCallback(serverResponse);
        return;
    }

    // TODO: This is pretty flat and can probably be safely reduced to calling `copy`.
    NSMutableDictionary<NSString *, NSString*> *responseHeaders = [NSMutableDictionary new];
    for (NSString *key in httpURLResponse.allHeaderFields) {
        responseHeaders[key] = httpURLResponse.allHeaderFields[key];
    }
    serverResponse.responseHeaders = responseHeaders;

    serverResponse.statusCode = httpURLResponse.statusCode;

    // Body should be ignored if HEAD method was used
    if (request && ![request.HTTPMethod isEqualToString:HTTPMethodHEAD]) {
        if (!responseData) {
            serverResponse.error = [PBMError errorWithMessage:@"No data from server" type:PBMErrorTypeServerError];
            fullServerCallback(serverResponse);
            return;
        }
        serverResponse.rawData = responseData;

        // Attempt to parse if response is JSON
        NSString *contentType = httpURLResponse.allHeaderFields[PBMServerConnection.contentTypeKey];
        if (contentType && [contentType isEqualToString:@"application/json"]) {
            NSError *parseError;
            NSDictionary *json = [PBMFunctions dictionaryFromData:serverResponse.rawData error:&parseError];
            if (!json) {
                NSString *errorMessage = [NSString stringWithFormat:@"JSON Parsing Error: %@", parseError.localizedDescription];
                serverResponse.error = [PBMError errorWithMessage:errorMessage type:PBMErrorTypeInternalError];
            } else {
                serverResponse.jsonDict = json;
            }
        }
    }

    fullServerCallback(serverResponse);
}

- (NSURLSession *)createSession:(NSTimeInterval)timeout {
    // TODO: Aren't you supposed to reuse the same session? Let's make this an ivar and see what happens.
    NSURLSessionConfiguration *config = NSURLSessionConfiguration.ephemeralSessionConfiguration;
    config.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyNever;
    config.HTTPCookieStorage = nil;
    config.timeoutIntervalForRequest = timeout;
    config.protocolClasses = [self.protocolClasses copy];
    
#ifdef DEBUG
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 5;
    return [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:queue];
#else
    return [NSURLSession sessionWithConfiguration:config];
#endif
}

- (nullable NSMutableURLRequest *)createRequest:(NSString *)strUrl {
    NSURL *url = [NSURL URLWithString:strUrl];
    if (!url) {
        PBMLogError(@"URL creation failed for string [%@]", strUrl);
        return nil;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:[self.userAgentService getFullUserAgent] forHTTPHeaderField:PBMUserAgentHeaderKey];
    
    [request setValue:@"True" forHTTPHeaderField:PBMIsPBMRequestKey];
    // Add this header only in test mode for MOCKED protocols
    if (self.protocolClasses.count && self.internalID) {
        [request addValue:[self.internalID UUIDString] forHTTPHeaderField:PBMInternalIDKey];
    }

    return request;
}

#ifdef DEBUG
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    [PBMFunctions checkCertificateChallenge:challenge completionHandler:completionHandler];
}
#endif

@end
