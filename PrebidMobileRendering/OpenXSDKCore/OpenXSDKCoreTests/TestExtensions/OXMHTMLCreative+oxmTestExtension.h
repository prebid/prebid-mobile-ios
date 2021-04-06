//
//  OXMHTMLCreative+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMHTMLCreative.h"
#import "OXMUIApplicationProtocol.h"

@protocol OXMMeasurementProtocol;

NS_ASSUME_NONNULL_BEGIN
@interface OXMHTMLCreative () <OXMWebViewDelegate>

@property (nonatomic, strong) OXMWebView *openXWebView;
@property (nonatomic, strong, nullable) OXMMRAIDController *MRAIDController;

- (instancetype)initWithCreativeModel:(OXMCreativeModel *)creativeModel
                          transaction:(OXMTransaction *)transaction
                              webView:(nullable OXMWebView *)webView
                     sdkConfiguration:(OXASDKConfiguration *)sdkConfiguration;

- (nonnull id<OXMUIApplicationProtocol>)getApplication;

- (BOOL)hasVastTag:(NSString *)html;
@end
NS_ASSUME_NONNULL_END
