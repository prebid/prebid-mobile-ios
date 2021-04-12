//
//  MockServer.h
//  OpenXInternalTestAppObjC
//
//  Copyright © 2017 OpenX. All rights reserved.
//

@import Foundation;
@class MockServerRule;
@class NSURLRequest;

@interface MockServer : NSObject
+(nonnull instancetype) singleton;
@property BOOL useNotFoundRule;

// The key in the header of NSURLRequest added by OXMServerConnection.
// This property must be initilized before all tests by OXMServerConnection.internalIDKey.
// MockServer checks the value for this key in a request - ConnectionID, to select a proper rule.
@property NSString* _Nonnull connectionIDHeaderKey;

@property MockServerRule* _Nonnull notFoundRule;
-(void) reset;
-(void) resetRules:(nonnull NSArray<MockServerRule *> *)rules;
-(BOOL) canHandle:(nonnull NSURLRequest*) request;
-(void) mockServerInteraction:(nonnull NSURLProtocol *)nsURLProtocol;
@end
