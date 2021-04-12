//
//  OXMServerConnection.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>
#import "OXMServerConnectionProtocol.h"

@class OXMUserAgentService;

NS_ASSUME_NONNULL_BEGIN
@interface OXMServerConnection : NSObject <OXMServerConnectionProtocol, NSURLSessionDelegate>

@property (class, nonatomic, strong, readonly) NSString *userAgentHeaderKey;
@property (class, nonatomic, strong, readonly) NSString *contentTypeKey;
@property (class, nonatomic, strong, readonly) NSString *contentTypeVal;
@property (class, nonatomic, strong, readonly) NSString *internalIDKey;
@property (class, nonatomic, strong, readonly) NSString *isOXMRequestKey;

@property (nonatomic, strong) NSMutableArray<NSURLProtocol *> *protocolClasses;
@property (nonatomic, strong, readonly) NSUUID *internalID;

+ (instancetype)singleton;
- (instancetype)init:(OXMUserAgentService *)userAgentService NS_SWIFT_NAME(init(userAgentService:));

@end
NS_ASSUME_NONNULL_END
