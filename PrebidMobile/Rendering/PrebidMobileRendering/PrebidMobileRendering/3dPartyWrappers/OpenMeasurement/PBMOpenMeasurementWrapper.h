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

#import <Foundation/Foundation.h>
#import "PBMOpenMeasurementSession.h"
#import "PBMVideoVerificationParameters.h"
#import "PBMVoidBlock.h"

@class WKWebView;

@interface PBMOpenMeasurementWrapper : NSObject 

NS_ASSUME_NONNULL_BEGIN
@property (class, readonly, nonnull) PBMOpenMeasurementWrapper *shared;

#pragma mark - PBMMeasurementProtocol

- (void)initializeJSLibWithBundle:(NSBundle *)bundle
                       completion:(nullable PBMVoidBlock)completion;

- (nullable NSString *)injectJSLib:(NSString *)html error:(NSError * __nullable * __null_unspecified)error;

- (nullable PBMOpenMeasurementSession *)initializeWebViewSession:(WKWebView *)webView
                                                      contentUrl:(nullable NSString *)contentUrl;

- (nullable PBMOpenMeasurementSession *)initializeNativeVideoSession:(UIView *)videoView
                                              verificationParameters:(nullable PBMVideoVerificationParameters *)verificationParameters;

- (nullable PBMOpenMeasurementSession *)initializeNativeDisplaySession:(UIView *)view
                                                             omidJSUrl:(NSString *)omidJS
                                                             vendorKey:(nullable NSString *)vendorKey
                                                            parameters:(nullable NSString *)verificationParameters;

@end
NS_ASSUME_NONNULL_END
