//
//  PBMWebViewDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PBMWebView;

@protocol PBMWebViewDelegate <NSObject>

- (nullable UIViewController *)viewControllerForPresentingModals;
- (void)webViewReadyToDisplay:(nonnull PBMWebView *)webView;
- (void)webView:(nonnull PBMWebView *)webView failedToLoadWithError:(nonnull NSError *)error;
- (void)webView:(nonnull PBMWebView *)webView receivedClickthroughLink:(nonnull NSURL *)url;
- (void)webView:(nonnull PBMWebView *)webView receivedMRAIDLink:(nonnull NSURL *)url;

@end

