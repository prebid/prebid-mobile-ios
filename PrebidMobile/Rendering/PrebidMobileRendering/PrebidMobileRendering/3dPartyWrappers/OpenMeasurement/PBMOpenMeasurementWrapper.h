//
//  PBMOpenMeasurementWrapper.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMOpenMeasurementSession.h"
#import "PBMVideoVerificationParameters.h"
#import "PBMVoidBlock.h"

@class WKWebView;

@interface PBMOpenMeasurementWrapper : NSObject 

NS_ASSUME_NONNULL_BEGIN
@property (class, readonly, nonnull) PBMOpenMeasurementWrapper *singleton;

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
