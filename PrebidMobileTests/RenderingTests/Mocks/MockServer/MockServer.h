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
@class MockServerRule;
@class NSURLRequest;

@interface MockServer : NSObject

@property (class, readonly, nonnull) MockServer *shared;

@property BOOL useNotFoundRule;

// The key in the header of NSURLRequest added by PrebidServerConnection.
// This property must be initilized before all tests by PrebidServerConnection.internalIDKey.
// MockServer checks the value for this key in a request - ConnectionID, to select a proper rule.
@property NSString* _Nonnull connectionIDHeaderKey;

@property MockServerRule* _Nonnull notFoundRule;
-(void) reset;
-(void) resetRules:(nonnull NSArray<MockServerRule *> *)rules;
-(BOOL) canHandle:(nonnull NSURLRequest*) request;
-(void) mockServerInteraction:(nonnull NSURLProtocol *)nsURLProtocol;
@end
