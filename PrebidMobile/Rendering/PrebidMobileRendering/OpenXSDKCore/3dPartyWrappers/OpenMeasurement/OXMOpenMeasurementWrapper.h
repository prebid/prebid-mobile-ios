//
//  OXMOpenMeasurementWrapper.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXMOpenMeasurementSession.h"
#import "OXMVideoVerificationParameters.h"
#import "OXMVoidBlock.h"

@class WKWebView;

@interface OXMOpenMeasurementWrapper : NSObject 

NS_ASSUME_NONNULL_BEGIN
@property (class, readonly, nonnull) OXMOpenMeasurementWrapper *singleton;

#pragma mark - OXMMeasurementProtocol

- (void)initializeJSLibWithBundle:(NSBundle *)bundle
                       completion:(nullable OXMVoidBlock)completion;

- (nullable NSString *)injectJSLib:(NSString *)html error:(NSError * __nullable * __null_unspecified)error;

- (nullable OXMOpenMeasurementSession *)initializeWebViewSession:(WKWebView *)webView
                                                      contentUrl:(nullable NSString *)contentUrl;

- (nullable OXMOpenMeasurementSession *)initializeNativeVideoSession:(UIView *)videoView
                                              verificationParameters:(nullable OXMVideoVerificationParameters *)verificationParameters;

- (nullable OXMOpenMeasurementSession *)initializeNativeDisplaySession:(UIView *)view
                                                             omidJSUrl:(NSString *)omidJS
                                                             vendorKey:(nullable NSString *)vendorKey
                                                            parameters:(nullable NSString *)verificationParameters;

@end
NS_ASSUME_NONNULL_END
