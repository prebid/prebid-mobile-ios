//
//  PBMServerConnection.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>
#import "PBMServerConnectionProtocol.h"

@class PBMUserAgentService;

NS_ASSUME_NONNULL_BEGIN
@interface PBMServerConnection : NSObject <PBMServerConnectionProtocol, NSURLSessionDelegate>

@property (class, nonatomic, strong, readonly) NSString *userAgentHeaderKey;
@property (class, nonatomic, strong, readonly) NSString *contentTypeKey;
@property (class, nonatomic, strong, readonly) NSString *contentTypeVal;
@property (class, nonatomic, strong, readonly) NSString *internalIDKey;
@property (class, nonatomic, strong, readonly) NSString *isPBMRequestKey;

@property (nonatomic, strong) NSMutableArray<NSURLProtocol *> *protocolClasses;
@property (nonatomic, strong, readonly) NSUUID *internalID;

+ (instancetype)singleton;
- (instancetype)init:(PBMUserAgentService *)userAgentService NS_SWIFT_NAME(init(userAgentService:));

@end
NS_ASSUME_NONNULL_END
