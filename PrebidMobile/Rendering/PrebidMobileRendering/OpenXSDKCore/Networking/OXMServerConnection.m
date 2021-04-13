//
//  OXMServerConnection.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMServerConnection.h"
#import "OXMServerResponse.h"
#import "OXMFunctions+Private.h"
#import "OXMUserAgentService.h"
#import "OXMConstants.h"
#import "OXMMacros.h"
#import "OXMError.h"

NSString *const HTTPMethodGET = @"GET";
NSString *const HTTPMethodHEAD = @"HEAD";
NSString *const HTTPMethodPOST = @"POST";
NSString *const OpenXErrorDomain = @"com.openx";


@interface OXMServerConnection ()

// The unique identifier of connection. Predominantly uses in tests.
@property (nonatomic, strong) NSUUID* internalID;

@end


@implementation OXMServerConnection

@synthesize userAgentService = _userAgentService;

static NSString *OXMUserAgentHeaderKey = @"User-Agent";
static NSString *OXMContentTypeKey = @"Content-Type";
static NSString *OXMContentTypeVal = @"application/json";
static NSString *OXMInternalIDKey = @"OXMConnectionID";
static NSString *OXMIsOXMRequestKey = @"OXMIsOXMRequest";

#pragma mark - Class properties
+ (instancetype)singleton {
    static OXMServerConnection *singleton = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [OXMServerConnection new];
    });

    return singleton;
}

+ (NSString *)userAgentHeaderKey {
    return OXMUserAgentHeaderKey;
}

+ (NSString *)contentTypeKey {
    return OXMContentTypeKey;
}

+ (NSString *)contentTypeVal {
    return OXMContentTypeVal;
}

+ (nonnull NSString *)internalIDKey {
    // The key for request's header where Connection places the ConnectionID
    // Must be used only in tests.
    return OXMInternalIDKey;
}

+ (nonnull NSString *)isOXMRequestKey {
    // The key for request's header of OXM ServerConnection requests
    // Must be used only in tests.
    return OXMIsOXMRequestKey;
}

#pragma mark - Init
- (instancetype)init {
    return (self = [self init:[OXMUserAgentService singleton]]);
}

- (instancetype)init:(OXMUserAgentService *)userAgentService {
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

    NSURLSession *session = [self createSession:[OXMTimeInterval FIRE_AND_FORGET_TIMEOUT]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request];
    [task resume];
}

// HEAD is the same as GET but the server doesn't return a body.
- (void)head:(NSString *)resourceURL timeout:(NSTimeInterval)timeout callback:(OXMServerResponseCallback)callback {
    [self get:resourceURL timeout:timeout headersOnly:YES callback:callback];
}

- (void)get:(NSString *)resourceURL timeout:(NSTimeInterval)timeout callback:(OXMServerResponseCallback)callback {
    [self get:resourceURL timeout:timeout headersOnly:NO callback:callback];
}

- (void)post:(NSString *)resourceURL data:(NSData *)data timeout:(NSTimeInterval)timeout callback:(OXMServerResponseCallback)callback {
    [self post:resourceURL contentType:OXMServerConnection.contentTypeVal data:data timeout:timeout callback:callback];
}

- (void)post:(NSString *)resourceURL contentType:(NSString *)contentType data:(NSData *)data timeout:(NSTimeInterval)timeout callback:(OXMServerResponseCallback)callback {
    NSMutableURLRequest *request = [self createRequest:resourceURL];
    if (!request) {
        return;
    }

    request.HTTPMethod = HTTPMethodPOST;
    request.HTTPBody = data;
    request.timeoutInterval = timeout;
    [request setValue:contentType forHTTPHeaderField:OXMServerConnection.contentTypeKey];

    NSURLSession *session = [self createSession:timeout];
    NSURLSessionTask *task = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        [self processResponse:request urlResponse:response responseData:data error:error fullServerCallback:callback];
    }];
    [task resume];
}

- (void)download:(NSString *)resourceURL callback:(OXMServerResponseCallback)callback {
    NSMutableURLRequest *request = [self createRequest:resourceURL];
    if (!request) {
        return;
    }
    
    [request setValue:OXMServerConnection.contentTypeVal forHTTPHeaderField:OXMServerConnection.contentTypeKey];
    
    NSURLSession *session = [self createSession:[OXMTimeInterval FIRE_AND_FORGET_TIMEOUT]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self processResponse:request urlResponse:response responseData:data error:error fullServerCallback:callback];
    }];
    [task resume];
}

#pragma mark - Private Methods
- (void)get:(NSString *)resourceURL timeout:(NSTimeInterval)timeout headersOnly:(BOOL)heardersOnly callback:(OXMServerResponseCallback)callback {
    NSMutableURLRequest *request = [self createRequest:resourceURL];
    if (!request) {
        return;
    }

    request.HTTPMethod = (heardersOnly) ? HTTPMethodHEAD : HTTPMethodGET;
    request.timeoutInterval = timeout;
    [request setValue:OXMServerConnection.contentTypeVal forHTTPHeaderField:OXMServerConnection.contentTypeKey];

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
     fullServerCallback:(OXMServerResponseCallback)fullServerCallback
{
    OXMServerResponse *serverResponse = [OXMServerResponse new];
    OXMAssert(request);

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
        serverResponse.error = [OXMError errorWithMessage:@"Response not an HTTPURLResponse" type:OXAErrorTypeServerError];
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
            serverResponse.error = [OXMError errorWithMessage:@"No data from server" type:OXAErrorTypeServerError];
            fullServerCallback(serverResponse);
            return;
        }
        serverResponse.rawData = responseData;

        // Attempt to parse if response is JSON
        NSString *contentType = httpURLResponse.allHeaderFields[OXMServerConnection.contentTypeKey];
        if (contentType && [contentType isEqualToString:@"application/json"]) {
            NSError *parseError;
            NSDictionary *json = [OXMFunctions dictionaryFromData:serverResponse.rawData error:&parseError];
            if (!json) {
                NSString *errorMessage = [NSString stringWithFormat:@"JSON Parsing Error: %@", parseError.localizedDescription];
                serverResponse.error = [OXMError errorWithMessage:errorMessage type:OXAErrorTypeInternalError];
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
    config.protocolClasses = self.protocolClasses;
    
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
        OXMLogError(@"URL creation failed for string [%@]", strUrl);
        return nil;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:[self.userAgentService getFullUserAgent] forHTTPHeaderField:OXMUserAgentHeaderKey];
    
    [request setValue:@"True" forHTTPHeaderField:OXMIsOXMRequestKey];
    // Add this header only in test mode for MOCKED protocols
    if (self.protocolClasses.count && self.internalID) {
        [request addValue:[self.internalID UUIDString] forHTTPHeaderField:OXMInternalIDKey];
    }

    return request;
}

#ifdef DEBUG
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    [OXMFunctions checkCertificateChallenge:challenge completionHandler:completionHandler];
}
#endif

@end
