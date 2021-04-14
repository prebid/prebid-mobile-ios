//
//  OXMWebViewDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class OXMWebView;

@protocol OXMWebViewDelegate <NSObject>

- (nullable UIViewController *)viewControllerForPresentingModals;
- (void)webViewReadyToDisplay:(nonnull OXMWebView *)webView;
- (void)webView:(nonnull OXMWebView *)webView failedToLoadWithError:(nonnull NSError *)error;
- (void)webView:(nonnull OXMWebView *)webView receivedClickthroughLink:(nonnull NSURL *)url;
- (void)webView:(nonnull OXMWebView *)webView receivedMRAIDLink:(nonnull NSURL *)url;

@end

