//
//  OXMMRAIDController+oxmTestExtension.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//
#import "OXMMRAIDController.h"

@class OXMWebView;

NS_ASSUME_NONNULL_BEGIN

@interface OXMMRAIDController ()

@property (nonatomic, strong, nullable) OXMWebView *openXWebView;
@property (nonatomic, strong, nullable) UIViewController* viewControllerForPresentingModals;

+ (CGRect)CGRectForResizeProperties:(OXMMRAIDResizeProperties *)properties fromView:(UIView *)fromView;

- (instancetype)initWithCreative:(OXMAbstractCreative*)creative
     viewControllerForPresenting:(UIViewController*)viewControllerForPresentingModals
                         webView:(OXMWebView*)webView
            creativeViewDelegate:(id<OXMCreativeViewDelegate>)creativeViewDelegate
                   downloadBlock:(OXMCreativeFactoryDownloadDataCompletionClosure)downloadBlock
        deviceAccessManagerClass:(Class)deviceAccessManagerClass
                sdkConfiguration:(OXASDKConfiguration *)sdkConfiguration;

- (OXMMRAIDCommand*)commandFromURL:(nullable NSURL*)url;
@end

NS_ASSUME_NONNULL_END
