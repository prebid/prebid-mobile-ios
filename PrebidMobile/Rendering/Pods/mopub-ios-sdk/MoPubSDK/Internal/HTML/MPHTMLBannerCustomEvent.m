//
//  MPHTMLBannerCustomEvent.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPHTMLBannerCustomEvent.h"
#import "MPInlineAdAdapter+MPAdAdapter.h"
#import "MPInlineAdAdapter+Internal.h"
#import "MPInlineAdAdapter+Private.h"

#import "MPAdConfiguration.h"
#import "MPAdContainerView.h"
#import "MPAnalyticsTracker.h"
#import "MPError.h"
#import "MPLogging.h"

@interface MPHTMLBannerCustomEvent ()
@property (nonatomic, strong) MPAdWebViewAgent *bannerAgent;

// Rather than giving back the raw `MPWebView` back to `MPAdView` through the delegate,
// the webview is wrapped in a `MPAdContainerView` view so that the Viewability tracker
// initialization remains consistent between HTML and MRAID creative types.
@property (nonatomic, strong) MPAdContainerView *adContainer;
@end

@implementation MPHTMLBannerCustomEvent

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return YES;
}

- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    MPAdConfiguration * configuration = self.configuration;

    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(configuration.adapterClass) dspCreativeId:configuration.dspCreativeId dspName:nil], self.adUnitId);

    CGRect adWebViewFrame = CGRectMake(0, 0, size.width, size.height);
    self.bannerAgent = [[MPAdWebViewAgent alloc] initWithWebViewFrame:adWebViewFrame delegate:self];
    [self.bannerAgent loadConfiguration:configuration];
}

- (void)dealloc
{
    self.adContainer = nil;
    self.bannerAgent.delegate = nil;
}

#pragma mark - MPAdWebViewAgentDelegate

- (UIViewController *)viewControllerForPresentingModalView
{
    return [self.delegate inlineAdAdapterViewControllerForPresentingModalView:self];
}

- (void)adSessionStarted:(MPWebView *)webView {
    // Create the ad container that will house the web view.
    self.adContainer = [[MPAdContainerView alloc] initWithFrame:webView.frame webContentView:webView];
    [self.adContainer setCloseButtonType:MPAdViewCloseButtonTypeNone];

    [self inlineAd:self webSessionWillStartInView:self.adContainer];
}

- (NSString *)customizeHTML:(NSString *)html inWebView:(MPWebView *)webView {
    return [self inlineAd:self willLoadHTML:html inWebView:webView];
}

- (void)adSessionReady:(MPWebView *)ad {
    [self inlineAdWebAdSessionReady:self];
}

- (void)adDidLoad:(MPWebView *)ad
{
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.adUnitId);
    [self.delegate inlineAdAdapter:self didLoadAdWithAdView:self.adContainer];
}

- (void)adDidFailToLoad:(MPWebView *)ad
{
    NSString * message = [NSString stringWithFormat:@"Failed to load creative:\n%@", self.configuration.adResponseHTMLString];
    NSError * error = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:message];

    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.adUnitId);
    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)adDidClose:(MPWebView *)ad
{
    //don't care
}

- (void)adActionWillBegin:(MPWebView *)ad
{
    [self.delegate inlineAdAdapterWillBeginUserAction:self];
}

- (void)adActionDidFinish:(MPWebView *)ad
{
    [self.delegate inlineAdAdapterDidEndUserAction:self];
}

- (void)adActionWillLeaveApplication:(MPWebView *)ad
{
    [self.delegate inlineAdAdapterWillLeaveApplication:self];
}

- (void)adWebViewAgentDidReceiveTap:(MPAdWebViewAgent *)aAdWebViewAgent {
    [self.delegate inlineAdAdapterDidTrackClick:self];
}

- (void)trackImpressionsIncludedInMarkup
{
    [self.bannerAgent didAppear];
}

@end
