/*   Copyright 2018-2019 Prebid.org, Inc.
 
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

#import "PBHTTPStubURLProtocol.h"
#import "PBURLConnectionStub.h"




@interface PBHTTPStubbingManager : NSObject

/**
 If set to YES, then unstubbed requests will be ignored by this class and handled by the system.
 If set to NO (default), then unstubbed requests will result in didFailToLoad errors.

 Default is NO.
 */
@property (nonatomic) BOOL ignoreUnstubbedRequests;

/**
 If set to YES, then all requests which trigger canInitWithRequest: will be broadcast
 as kPBHTTPStubURLProtocolRequestDidLoadNotification notifications. The request will be in the user info,
 as the value of the kPBHTTPStubURLProtocolRequest key.

 Default is NO.
 */
@property (nonatomic) BOOL broadcastRequests;



+ (PBHTTPStubbingManager *)sharedStubbingManager;

- (void)enable;
- (void)disable;

- (void)addStub:(PBURLConnectionStub *)stub;
- (void)addStubs:(NSArray *)stubs;
- (void)removeAllStubs;

- (PBURLConnectionStub *)stubForURLString:(NSString *)URLString;

//
+ (NSDictionary *) jsonBodyOfURLRequestAsDictionary: (NSURLRequest *)urlRequest;

@end
