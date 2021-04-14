//
//  OXMWebView.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>

#import "OXMConstants.h"
#import "OXMWebViewDelegate.h"
#import "OXMExposureChangeDelegate.h"
#import "OXMEventManager.h"
#import "OXMOpenMeasurementWrapper.h"
#import "OXMMRAIDConstants.h"

@class OXATargeting;
@class OXMAbstractCreative;
@class OXMTouchDownRecognizer;
@class OXMLegalButtonDecorator;
@class OXMViewExposure;

NS_ASSUME_NONNULL_BEGIN

typedef void(^OXMJSEvaluatingBlock)(NSString * _Nullable command, id _Nullable jsRes, NSError * _Nullable error);

typedef NS_ENUM(NSInteger, OXMWebViewState) {
    OXMWebViewStateUnloaded,
    OXMWebViewStateLoading,
    OXMWebViewStateLoaded
};

// The OXMWebView is a UIView that contains a WKWebView as a subview.
// The interface of the OXMWebView is specific to showing ads within the SDK.
// It allows for us to easily tell the webview to show an ad (and handling taking the data
// and getting it in the right format etc to be shown) while also encapsulating away other functionality that a WKWebView may have.
@interface OXMWebView : UIView <WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler, UIGestureRecognizerDelegate>

@property (nonatomic, readonly) WKWebView *internalWebView;

//This block exists for testability. It is executed as part of the completion handler on evaluateJavascript.
@property (nonatomic, copy, nullable) OXMJSEvaluatingBlock jsEvaluatingCompletion;

@property (nonatomic, weak, nullable) NSBundle *bundle;
@property (nonatomic, weak, nullable) id<OXMWebViewDelegate> delegate;
@property (nonatomic, weak, nullable) id<OXMExposureChangeDelegate> exposureDelegate;
@property (nonatomic, strong) OXMTouchDownRecognizer *tapdownGestureRecognizer;
@property (nonatomic, strong, nullable) OXMLegalButtonDecorator *legalButtonDecorator;

@property (nonatomic, copy) OXMMRAIDState mraidState;
@property (nonatomic, assign, readonly) OXMWebViewState state;
@property (nonatomic, assign, getter=isViewable) BOOL viewable;
@property (nonatomic, assign) BOOL isMRAID;
@property (nonatomic, assign, getter=isRotationEnabled) BOOL rotationEnabled;

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithFrame:(CGRect)frame
                creativeModel:(nullable OXMCreativeModel *)creativeModel
                    targeting:(OXATargeting *)targeting NS_DESIGNATED_INITIALIZER;

#pragma mark - Public Methods

- (void)loadHTML:(NSString *)html baseURL:(nullable NSURL *)baseURL injectMraidJs:(BOOL)injectMraidJs;

- (void)expand:(NSURL *)url;

- (void)updateLegalButtonForCreative:(OXMAbstractCreative *)creative;

#pragma mark - MRAID

- (void)MRAID_nativeCallComplete
    NS_SWIFT_NAME(MRAID_nativeCallComplete());

// get the expand properties from mraid.js
- (void)MRAID_getExpandProperties:(void(^)(OXMMRAIDExpandProperties *_Nullable))completionHandler
    NS_SWIFT_NAME(MRAID_getExpandProperties(completionHandler:));

// get the resize properties from mraid.js
- (void)MRAID_getResizeProperties:(void(^)(OXMMRAIDResizeProperties *_Nullable))completionHandler
    NS_SWIFT_NAME(MRAID_getResizeProperties(completionHandler:));

- (void)MRAID_error:(NSString *)message action:(OXMMRAIDAction)action
    NS_SWIFT_NAME(MRAID_error(_:action:));

- (void)MRAID_onExposureChange:(OXMViewExposure *)viewExposure
    NS_SWIFT_NAME(MRAID_onExposureChange(_:));

- (void)MRAID_updatePlacementType:(OXMMRAIDPlacementType)type
    NS_SWIFT_NAME(MRAID_updatePlacementType(_:));

- (void)prepareForMRAIDWithRootViewController:(UIViewController*)viewController;

// update the current position of the container
- (void)updateMRAIDLayoutInfoWithForceNotification:(BOOL)forceNotification
    NS_SWIFT_NAME(updateMRAIDLayoutInfo(_:));

// update the current state
- (void)changeToMRAIDState:(OXMMRAIDState)state
    NS_SWIFT_NAME(changeToMRAIDState(_:));

#pragma mark - MRAID Injection

- (BOOL)injectMRAIDForExpandContent:(BOOL)isForExpandContent error:(NSError * __nullable * __null_unspecified)error
    NS_SWIFT_NAME(injectMRAIDForExpandContent(_:));

#pragma mark - UITapGestureRecognizer support

- (void)recordTapEvent:(nullable UITapGestureRecognizer *)tap;
- (BOOL)wasRecentlyTapped;

#pragma mark - Orientation changing support

- (void)onStatusBarOrientationChanged;

#pragma mark - Open Measurement

- (void)addFriendlyObstructionsToMeasurementSession:(nullable OXMOpenMeasurementSession *)session;

#pragma mark - Utilities

// returns a human-readable description of the view's state
+ (nullable NSString *)webViewStateDescription:(OXMWebViewState)state;

// checks if the frame is onscreen at all
+ (BOOL)isVisibleView:(nullable UIView *)view;

+ (nullable OXMJsonDictionary *)anyToJSONDict:(nullable id)str;

@end

NS_ASSUME_NONNULL_END
