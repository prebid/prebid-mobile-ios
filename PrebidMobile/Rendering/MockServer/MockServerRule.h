//
//  MockServerRule.h
//  OpenXInternalTestAppObjC
//
//  Copyright © 2017 OpenX. All rights rreserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN
@interface MockServerRule : NSObject

@property NSString* urlNeedle;
@property (nullable) NSUUID* connectionID;

/// Determines whether MockServer will respond (or just time out)
@property BOOL willRespond;

/// HTTP status code of the response
@property int statusCode;

/// Response data
@property (nullable) NSData* data;

/// "HTTP-Version" field. Defaults to "HTTP/2.0"
@property NSString* httpVersion;

/// "HTTP-Version" field. Defaults to "HTTP/2.0"
@property NSMutableDictionary* responseHeaderFields;

/// This block will be invoked when MockServer receives the request.
@property void (^mockServerReceivedRequestHandler)(NSURLRequest* _Nonnull request);

//Designated Init
- (instancetype) initWithURLNeedle:(NSString*)needle connectionID:(NSUUID *)connectionID data:(NSData*)data responseHeaderFields:(NSDictionary*)responseHeaderFields;

//Convenience inits
- (instancetype) initWithURLNeedle:(NSString*)needle mimeType:(NSString*)mimeType connectionID:(NSUUID *)connectionID data:(NSData*)data;
- (instancetype) initWithURLNeedle:(NSString*)needle mimeType:(NSString*)mimeType connectionID:(NSUUID *)connectionID fileName:(NSString*)fileName;
- (instancetype) initWithURLNeedle:(NSString*)needle mimeType:(NSString*)mimeType connectionID:(NSUUID *)connectionID strResponse:(NSString*)strResponse;
- (instancetype) initWithFireAndForgetURLNeedle:(NSString*)needle connectionID:(NSUUID *)connectionID;

/// Called by MockServer
- (void) load:(NSURLProtocol*)nsURLProtocol;
@end
NS_ASSUME_NONNULL_END
