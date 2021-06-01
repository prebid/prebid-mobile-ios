//
//  OXMMRAIDController+oxmTestExtension.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//
#import "PBMMRAIDController.h"

@class PBMWebView;

NS_ASSUME_NONNULL_BEGIN

@interface PBMMRAIDController ()

@property (nonatomic, strong, nullable) PBMWebView *prebidWebView;
@property (nonatomic, strong, nullable) UIViewController* viewControllerForPresentingModals;

+ (CGRect)CGRectForResizeProperties:(PBMMRAIDResizeProperties *)properties fromView:(UIView *)fromView;

- (instancetype)initWithCreative:(PBMAbstractCreative*)creative
     viewControllerForPresenting:(UIViewController*)viewControllerForPresentingModals
                         webView:(PBMWebView*)webView
            creativeViewDelegate:(id<PBMCreativeViewDelegate>)creativeViewDelegate
                   downloadBlock:(PBMCreativeFactoryDownloadDataCompletionClosure)downloadBlock
        deviceAccessManagerClass:(Class)deviceAccessManagerClass
                sdkConfiguration:(PrebidRenderingConfig *)sdkConfiguration;

- (PBMMRAIDCommand*)commandFromURL:(nullable NSURL*)url;
@end

NS_ASSUME_NONNULL_END
