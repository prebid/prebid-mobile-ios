//
//  OXMServerConnectionProtocol.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#ifndef OXMServerConnectionProtocol_h
#define OXMServerConnectionProtocol_h

#import <Foundation/Foundation.h>

@class OXMServerResponse;
@class OXMUserAgentService;

NS_ASSUME_NONNULL_BEGIN

typedef void (^ OXMServerResponseCallback)(OXMServerResponse *_Nonnull);

@protocol OXMServerConnectionProtocol <NSObject>

@property (nonatomic, strong, readonly, nullable) OXMUserAgentService *userAgentService;

- (void)fireAndForget:(NSString *) resourceURL;
- (void)head:(NSString *)resourceURL timeout:(NSTimeInterval)timeout callback:(OXMServerResponseCallback)callback;
- (void)get:(NSString *)resourceURL timeout:(NSTimeInterval)timeout callback:(OXMServerResponseCallback)callback;
- (void)post:(NSString *)resourceURL data:(NSData *)data timeout:(NSTimeInterval)timeout callback:(OXMServerResponseCallback)callback;
- (void)post:(NSString *)resourceURL contentType:(NSString *)contentType data:(NSData *)data timeout:(NSTimeInterval)timeout callback:(OXMServerResponseCallback)callback;

- (void)download:(NSString *)resourceURL callback:(OXMServerResponseCallback)callback;


@end

NS_ASSUME_NONNULL_END

#endif /* OXMServerConnectionProtocol_h */
