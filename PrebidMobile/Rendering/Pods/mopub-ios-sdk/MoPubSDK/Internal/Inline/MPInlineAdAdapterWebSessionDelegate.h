//
//  MPInlineAdAdapterWebSessionDelegate.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>

@class MPAdContainerView;
@class MPInlineAdAdapter;
@class MPWebView;

NS_ASSUME_NONNULL_BEGIN

/**
 Provides internal callbacks for web view session events that are used for tracking and viewability purposes.
 */
@protocol MPInlineAdAdapterWebSessionDelegate <NSObject>

/**
 Notifies when the inline web session will start. This will be called before any HTML is loaded into the web view.
 @param inlineAdAdapter The inline adapter associated with this callback.
 @param containerView The view containing the web view instance that is starting.
*/
- (void)inlineAd:(MPInlineAdAdapter *)inlineAdAdapter webSessionWillStartInView:(MPAdContainerView *)containerView;

/**
 Notifies when the inline web view will load an HTML string into the web view. This provides an injection point for HTML customization.
 @param inlineAdAdapter The inline adapter associated with this callback.
 @param html The HTML to be loaded into the web view.
 @param webView The web view instance that will be the target of the HTML load.
 @returns The HTML to be loaded into the web view. If no processing is required, just return the passed in @c html
 */
- (NSString *)inlineAd:(MPInlineAdAdapter *)inlineAdAdapter willLoadHTML:(NSString *)html inWebView:(MPWebView *)webView;

/**
 Notifies when the inline web session is ready. This will be called once the loaded HTML has completed its navigation, and the
 web view is ready to accept further JavaScript commands.
 @param inlineAdAdapter The inline adapter associated with this callback.
*/
- (void)inlineAdWebAdSessionReady:(MPInlineAdAdapter *)inlineAdAdapter;

@end

NS_ASSUME_NONNULL_END
