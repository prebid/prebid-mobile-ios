//
//  OXMHTMLCreative+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMHTMLCreative.h"
#import "PBMUIApplicationProtocol.h"

@protocol PBMMeasurementProtocol;

NS_ASSUME_NONNULL_BEGIN
@interface PBMHTMLCreative () <PBMWebViewDelegate>

@property (nonatomic, strong) PBMWebView *prebidWebView;
@property (nonatomic, strong, nullable) PBMMRAIDController *MRAIDController;

- (instancetype)initWithCreativeModel:(PBMCreativeModel *)creativeModel
                          transaction:(PBMTransaction *)transaction
                              webView:(nullable PBMWebView *)webView
                     sdkConfiguration:(PrebidRenderingConfig *)sdkConfiguration;

- (nonnull id<PBMUIApplicationProtocol>)getApplication;

- (BOOL)hasVastTag:(NSString *)html;
@end
NS_ASSUME_NONNULL_END
