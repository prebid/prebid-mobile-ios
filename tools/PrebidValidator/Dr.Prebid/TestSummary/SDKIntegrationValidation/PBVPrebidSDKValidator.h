/*
 *    Copyright 2018 Prebid.org, Inc.
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

#import <UIKit/UIKit.h>
@protocol PBVPrebidSDKValidatorDelegate

- (void) adUnitRegistered;
- (void) requestToPrebidServerSent: (Boolean)sent;
- (void) prebidServerResponseReceived: (Boolean) received;
- (void) bidReceivedAndCached:(Boolean)received;
- (void) adServerRequestSent:(NSString *)adServerRequest andPostData:(NSString *)postData;
- (void) adServerResponseContainsPBMCreative:(Boolean)contains;
@end

@interface PBVPrebidSDKValidator: NSObject

@property id <PBVPrebidSDKValidatorDelegate> delegate;
- (instancetype)initWithDelegate: (id<PBVPrebidSDKValidatorDelegate>) delegate;
- (void)startTest;
- (NSObject *)getAdObject;
- (NSString *)getAdServerRequest;
- (NSString *)getAdServerResponse;
- (NSString *)getAdServerRequestPostData;
@end
