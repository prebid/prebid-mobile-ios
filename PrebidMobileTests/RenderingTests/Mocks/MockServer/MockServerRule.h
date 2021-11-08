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
