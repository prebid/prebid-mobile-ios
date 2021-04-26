//
//  PBMServerConnectionProtocol.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#ifndef PBMServerConnectionProtocol_h
#define PBMServerConnectionProtocol_h

#import <Foundation/Foundation.h>

@class PBMServerResponse;
@class PBMUserAgentService;

NS_ASSUME_NONNULL_BEGIN

typedef void (^ PBMServerResponseCallback)(PBMServerResponse *_Nonnull);

@protocol PBMServerConnectionProtocol <NSObject>

@property (nonatomic, strong, readonly, nullable) PBMUserAgentService *userAgentService;

- (void)fireAndForget:(NSString *) resourceURL;
- (void)head:(NSString *)resourceURL timeout:(NSTimeInterval)timeout callback:(PBMServerResponseCallback)callback;
- (void)get:(NSString *)resourceURL timeout:(NSTimeInterval)timeout callback:(PBMServerResponseCallback)callback;
- (void)post:(NSString *)resourceURL data:(NSData *)data timeout:(NSTimeInterval)timeout callback:(PBMServerResponseCallback)callback;
- (void)post:(NSString *)resourceURL contentType:(NSString *)contentType data:(NSData *)data timeout:(NSTimeInterval)timeout callback:(PBMServerResponseCallback)callback;

- (void)download:(NSString *)resourceURL callback:(PBMServerResponseCallback)callback;


@end

NS_ASSUME_NONNULL_END

#endif /* PBMServerConnectionProtocol_h */
