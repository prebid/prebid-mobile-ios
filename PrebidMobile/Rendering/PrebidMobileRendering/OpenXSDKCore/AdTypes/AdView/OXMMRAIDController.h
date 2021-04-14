//
//  OXMMRAIDController.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OXMAdConfiguration.h"
#import "OXMConstants.h"
#import "OXMCreativeFactory.h"

#import "OXMCreativeViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class OXMAbstractCreative;
@class OXMEventManager;
@class OXMModalManager;
@class OXMWebView;
@class OXMMRAIDCommand;
@class OXMOpenMeasurementSession;

@interface OXMMRAIDController : NSObject

@property (nonatomic, assign, nonnull) OXMMRAIDState mraidState;

+(BOOL)isMRAIDLink:(NSString *)urlString;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCreative:(OXMAbstractCreative*)creative
     viewControllerForPresenting:(UIViewController*)viewControllerForPresentingModals
                         webView:(OXMWebView*)webView
            creativeViewDelegate:(id<OXMCreativeViewDelegate>)creativeViewDelegate
                   downloadBlock:(OXMCreativeFactoryDownloadDataCompletionClosure)downloadBlock;

- (void)webView:(OXMWebView *)webView handleMRAIDURL:(NSURL *)url;
- (void)updateForClose:(BOOL)isInterstitial;

@end

NS_ASSUME_NONNULL_END
