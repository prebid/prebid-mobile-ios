//
//  SDKValidationURLProtocol.h
//  Dr.Prebid
//
//  Created by Wei Zhang on 9/10/18.
//  Copyright © 2018 Prebid. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SDKValidationURLProtocolDelegate
- (void)willInterceptPrebidServerRequest;
- (void)didReceivePrebidServerResponse:(NSString *)response;
- (void)willInterceptAdServerRequest:(NSString *)request;
- (void)didReceiveAdServerResponse:(NSString *)response forRequest:(NSString *) request;
@end

@interface SDKValidationURLProtocol: NSURLProtocol
+ (void) setDelegate:(id<SDKValidationURLProtocolDelegate>)delegate;
+ (id <SDKValidationURLProtocolDelegate>) delegate;
@end
