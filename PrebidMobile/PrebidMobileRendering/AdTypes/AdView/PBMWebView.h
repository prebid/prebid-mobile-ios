/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>

#import "PBMConstants.h"
#import "PBMWebViewDelegate.h"
#import "PBMExposureChangeDelegate.h"
#import "PBMOpenMeasurementWrapper.h"
#import "PBMMRAIDConstants.h"
#import "PBMCreativeModel.h"

@class Targeting;
@class PBMAbstractCreative;
@class PBMTouchDownRecognizer;
@class PBMViewExposure;

NS_ASSUME_NONNULL_BEGIN

typedef void(^PBMJSEvaluatingBlock)(NSString * _Nullable command, id _Nullable jsRes, NSError * _Nullable error);

typedef NS_ENUM(NSInteger, PBMWebViewState) {
    PBMWebViewStateUnloaded,
    PBMWebViewStateLoading,
    PBMWebViewStateLoaded
};

// The PBMWebView is a UIView that contains a WKWebView as a subview.
// The interface of the PBMWebView is specific to showing ads within the SDK.
// It allows for us to easily tell the webview to show an ad (and handling taking the data
// and getting it in the right format etc to be shown) while also encapsulating away other functionality that a WKWebView may have.
@interface PBMWebView : UIView <WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler, UIGestureRecognizerDelegate>

@property (nonatomic, readonly) WKWebView *internalWebView;

//This block exists for testability. It is executed as part of the completion handler on evaluateJavascript.
@property (nonatomic, copy, nullable) PBMJSEvaluatingBlock jsEvaluatingCompletion;

@property (nonatomic, weak, nullable) NSBundle *bundle;
@property (nonatomic, weak, nullable) id<PBMWebViewDelegate> delegate;
@property (nonatomic, weak, nullable) id<PBMExposureChangeDelegate> exposureDelegate;
@property (nonatomic, strong) PBMTouchDownRecognizer *tapdownGestureRecognizer;

@property (nonatomic, copy) PBMMRAIDState mraidState;
@property (nonatomic, assign, readonly) PBMWebViewState state;
@property (nonatomic, assign, getter=isViewable) BOOL viewable;
@property (nonatomic, assign) BOOL isMRAID;
@property (nonatomic, assign, getter=isRotationEnabled) BOOL rotationEnabled;

@property (nonatomic, strong, nullable) NSString *rewardedAdURL;

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithFrame:(CGRect)frame
                creativeModel:(nullable PBMCreativeModel *)creativeModel
                    targeting:(Targeting *)targeting NS_DESIGNATED_INITIALIZER;

#pragma mark - Public Methods

- (void)loadHTML:(NSString *)html baseURL:(nullable NSURL *)baseURL injectMraidJs:(BOOL)injectMraidJs;

- (void)expand:(NSURL *)url;

#pragma mark - MRAID

- (void)MRAID_nativeCallComplete
    NS_SWIFT_NAME(MRAID_nativeCallComplete());

// get the expand properties from mraid.js
- (void)MRAID_getExpandProperties:(void(^)(PBMMRAIDExpandProperties *_Nullable))completionHandler
    NS_SWIFT_NAME(MRAID_getExpandProperties(completionHandler:));

// get the resize properties from mraid.js
- (void)MRAID_getResizeProperties:(void(^)(PBMMRAIDResizeProperties *_Nullable))completionHandler
    NS_SWIFT_NAME(MRAID_getResizeProperties(completionHandler:));

- (void)MRAID_error:(NSString *)message action:(PBMMRAIDAction)action
    NS_SWIFT_NAME(MRAID_error(_:action:));

- (void)MRAID_onExposureChange:(PBMViewExposure *)viewExposure
    NS_SWIFT_NAME(MRAID_onExposureChange(_:));

- (void)MRAID_updatePlacementType:(PBMMRAIDPlacementType)type
    NS_SWIFT_NAME(MRAID_updatePlacementType(_:));

- (void)prepareForMRAIDWithRootViewController:(UIViewController*)viewController;

// update the current position of the container
- (void)updateMRAIDLayoutInfoWithForceNotification:(BOOL)forceNotification
    NS_SWIFT_NAME(updateMRAIDLayoutInfo(_:));

// update the current state
- (void)changeToMRAIDState:(PBMMRAIDState)state
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

- (void)addFriendlyObstructionsToMeasurementSession:(nullable PBMOpenMeasurementSession *)session;

#pragma mark - Utilities

// returns a human-readable description of the view's state
+ (nullable NSString *)webViewStateDescription:(PBMWebViewState)state;

// checks if the frame is onscreen at all
+ (BOOL)isVisibleView:(nullable UIView *)view;

+ (nullable PBMJsonDictionary *)anyToJSONDict:(nullable id)str;

@end

NS_ASSUME_NONNULL_END
