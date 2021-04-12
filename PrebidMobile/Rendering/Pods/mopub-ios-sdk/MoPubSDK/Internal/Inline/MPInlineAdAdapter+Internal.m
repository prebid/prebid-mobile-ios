//
//  MPInlineAdAdapter+Internal.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPInlineAdAdapter+Internal.h"
#import "MPInlineAdAdapter+Private.h"

#import "MPViewabilityManager.h"

@implementation MPInlineAdAdapter (Internal)

- (void)trackImpressionsIncludedInMarkup
{
    // no-op.
}

#pragma mark - MPInlineAdAdapterWebSessionDelegate

- (void)inlineAd:(MPInlineAdAdapter *)inlineAdAdapter webSessionWillStartInView:(MPAdContainerView *)containerView {
    // Initialize the viewability tracker now that the webview is ready.
    // If Viewability has been disabled or not initialized, `self.tracker` will be `nil`.
    self.viewabilityTracker = [self viewabilityTrackerForWebContentInView:containerView];
}

- (NSString *)inlineAd:(MPInlineAdAdapter *)inlineAdAdapter willLoadHTML:(NSString *)html inWebView:(MPWebView *)webView {
    // Inject viewability into the HTML string.
    return [MPViewabilityManager.sharedManager injectViewabilityIntoAdMarkup:html];
}

- (void)inlineAdWebAdSessionReady:(MPInlineAdAdapter *)inlineAdAdapter {
    // Web view is ready and HTML has been loaded, start the tracking session.
    [self.viewabilityTracker startTracking];
}

@end
