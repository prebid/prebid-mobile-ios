//
//  PBMMRAIDController.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PBMAdConfiguration.h"
#import "PBMConstants.h"
#import "PBMCreativeFactory.h"

#import "PBMCreativeViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class PBMAbstractCreative;
@class PBMEventManager;
@class PBMModalManager;
@class PBMWebView;
@class PBMMRAIDCommand;
@class PBMOpenMeasurementSession;

@interface PBMMRAIDController : NSObject

@property (nonatomic, assign, nonnull) PBMMRAIDState mraidState;

+(BOOL)isMRAIDLink:(NSString *)urlString;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCreative:(PBMAbstractCreative*)creative
     viewControllerForPresenting:(UIViewController*)viewControllerForPresentingModals
                         webView:(PBMWebView*)webView
            creativeViewDelegate:(id<PBMCreativeViewDelegate>)creativeViewDelegate
                   downloadBlock:(PBMCreativeFactoryDownloadDataCompletionClosure)downloadBlock;

- (void)webView:(PBMWebView *)webView handleMRAIDURL:(NSURL *)url;
- (void)updateForClose:(BOOL)isInterstitial;

@end

NS_ASSUME_NONNULL_END
