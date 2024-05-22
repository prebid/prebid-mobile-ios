//
//  RequestBuilder.h
//  Dr.Prebid
//
//  Created by Punnaghai Puviarasu on 2/19/19.
//  Copyright © 2019 Prebid. All rights reserved.
//

#import <Foundation/Foundation.h>
@import PrebidMobile;

@interface DemandRequestBuilder : NSObject

@property (nonatomic, readwrite) NSString * _Nonnull configId;

@property (nonatomic, readwrite) NSArray * _Nonnull adSizes;

@property (nonatomic, assign, readwrite) NSURL * _Nonnull hostURL;

- (NSURLRequest *_Nullable)buildRequest:(nullable NSArray<AdUnit *> *)adUnits withAccountId:(NSString *_Nullable) accountID withSecureParams:(BOOL) isSecure;
@end





