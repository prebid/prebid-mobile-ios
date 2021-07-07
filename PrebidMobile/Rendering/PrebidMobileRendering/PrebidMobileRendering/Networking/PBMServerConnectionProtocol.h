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
