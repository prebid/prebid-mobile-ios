//
//  AFAdInline.h
//  AdformAdvertising
//
//  Copyright (c) 2014 Adform. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SafariServices/SafariServices.h>
#import "AFConstants.h"

@protocol AFAdInlineDelegate;

@class AFVideoSettings, AFKeyValue, AFBrowserViewController;

/**     
 The AFAdInline class provides a view container that displays inline advertisements.
 */
@interface AFAdInline : UIView

/**
 Indicates ad view state.
 
 For available values check AFAdState enum.
 
 @see AFAdState
 */
@property (nonatomic, assign, readonly) AFAdState state;

/**
 Property indicating if ad view is viewable by the user.
 */
@property (nonatomic, assign, readonly, getter = isViewable) BOOL viewable;

/**
 A property identifying if an ad has been loaded.
 
 This property is set to YES after the first successful ad request.
 */
@property (nonatomic, assign, readonly, getter=isLoaded) BOOL loaded;

/**
 An integer representing Adform master tag id.
 */
@property (nonatomic, assign, readonly) NSInteger mid;

/**
 You can directly set HTML or VAST adTag to be loaded on the ad view.
 
 HTML adTags must be of type NSString.
 VAST adTags may be NSString or NSData XML documents
 or an URL object with a link to VAST XML document.
 */
@property (nonatomic, strong) id adTag;


/**
 Ad view size shows the size of the currently loaded ad.
 
 You can set this property to use custom size ads.
 Ad size must be set before loading the ad.
 If you want to support multiple ad sizes at the same placement use additional dimmensions feature.
 
 If you have enabled aditional dimensions this property may change
 when ad is laoded or relaoded to match the size retreived from the server.
 
 This property can differ from frame.size when ad view wasn't shown yet.
 When an ad view is displayed its frame.size becomes equal to adSize.
 
 Default values: iPhone - 320x50, iPad - 728x90.
 */
@property (nonatomic, assign) CGSize adSize;

/**
 Identifies if ad view should load creatives with various dimensions.
 
 If enabled, ad placement will load ads with multiple sizes defined in ad server.
 The ad view will automatically resize itself to match the ad creative size after loading or reloading the ad.
 To match these size changes implement AFAdInlineDelegate 'adInlineWillChangeSize:toSize:' method.
 
 To define which sizes are supported by this placement use 'supportedDimensions' property.
 
 @important Additional dimmensions are not supported for video banners, therefore if you are loading video ads 
    you must set the adSize property before loading them.
 
 Default value - false.
 
 @see AFAdInlineDelegate
 */
@property (nonatomic, assign, getter=areAditionalDimmensionsEnabled) BOOL additionalDimmensionsEnabled;

/**
 An array of NSValue encoded CGSize structures, specifying ad creative sizes that are supported by this placement.
 
 For convenience you can use 'AFAdDimension' or 'AFAdDimensionFromCGSize' functions to create NSValue objects.
 
 Example:
    \code
 adView.supportedDimmensions = @[AFAdDimension(320, 50), AFAdDimension(320, 150)];
    \endcode
 
 You can use this property to define what sizes can be loaded in this placement.
 Supported dimensions are ignored if 'additionalDimmensionsEnabled' property is false.
 If you change this value when an ad is already loaded, the ad size will change only when the ad view is reloaded.
 */
@property (nonatomic, strong) NSArray *supportedDimmensions;


/**
 The object implementing AFAdInlineDelegate protocol, which is notified about the ad view state changes.
 */
@property (nonatomic, weak) id delegate;


/**
 This property determines how an ad transition should be animated inside the ad view.
 You can also set this property to AFAdTransitionStyleNone to disable ad view animations.
 
 Default value - AFAdTransitionStyleSlide.
 
 @see AFAdTransitionStyle
 */
@property (nonatomic, assign) AFAdTransitionStyle adTransitionStyle;

/**
 This property determines how expanded ads should be animated.
 You can also set this property to AFModalPresentationStyleNone to disable modal presentation animations.
 
 Default value - AFModalPresentationStyleSlide.
 
 @see AFModalPresentationStyle
 */
@property (nonatomic, assign) AFModalPresentationStyle modalPresentationStyle;

/**
 This property determines if application content should be dimmed when displaying a modal view.
 
 Default value - YES.
 */
@property (nonatomic, assign, getter=isDimOverlayEnabled) BOOL dimOverlayEnabled;

/**
 If you are using the ad view to display video advertisment, you can use this property to setup 
 video player behavior.
 */
@property (nonatomic, strong, readonly) AFVideoSettings *videoSettings;

/**
 Required reference to the view controller which is presenting the ad view.
 
 You should set this property when you are creating an ad view instance.
 
 @warning Ads will not be loaded if this property is not set.
 */
@property (nonatomic, weak) UIViewController *presentingViewController;

/**
 Turns on/off debug mode.
 
 Default value - NO (debug mode turned off).
 */
@property (nonatomic, assign) BOOL debugMode;

/**
 Custom impression url.
 This impression is fired when an ad is loaded.
 */
@property (nonatomic, strong) NSURL *customImpression;

/**
 This property determines if ad should be expand automatically after the first successfull load.
 You can use this flag to first load the ad and them show it (expand it) manually by calling 'showAd' method.
 Default value - YES.
 */
@property (nonatomic, assign) BOOL showAdAutomatically;

/**
 You can add an array of keywords to identify the placement,
 this way the Adform will be able to target ads to your users even more accurately, e.g. @[@"music", @"rock", @"pop"].
 
 @warning This value should be set before loading the ad view, 
 if it is set after calling the "loadAd" method this data won't be sent to our server.
 If you want to change this data after loading the ad view, you should create a new ad view with updated data.
 */
@property (nonatomic, strong) NSArray<NSString *> *keywords;

/**
 You can add custom key-value pair data to identify the placement, 
 this way the Adform will be able to target ads to your users even more accurately, e.g. AFKeyValue(@"content": @"music").
 
 @warning This value should be set before loading the ad view,
 if it is set after calling the "loadAd" method this data won't be sent to our server.
 If you want to change this data after loading the ad view, you should create a new ad view with updated data.
 */
@property (nonatomic, strong) NSArray<AFKeyValue *> *keyValues;

/**
 You can add custom key-value pair data to target user search words,
 this way the Adform will be able to target ads to your users even more accurately, e.g. AFKeyValue(@"product": @"book").
 
 @warning This value should be set before loading the ad view,
 if it is set after calling the "loadAd" method this data won't be sent to our server.
 If you want to change this data after loading the ad view, you should create a new ad view with updated data.
 */
@property (nonatomic, strong) NSArray<AFKeyValue *> *searchWords;

/**
 Allows to pass bid price from header bidding auction.
 */
@property (nonatomic, assign) float price;

/**
 Provides an easy way of passing some data back to the ad that needs to be rendered in a webview.
 */
@property (nonatomic, strong) NSDictionary *customData;

/**
 Initializes an AFAdInline with the given master tag id.
 
 @param mid An integer representing Adform master tag id.
 @param viewController The view controller which is presenting the ad view.
 
 @return A newly initialized ad view.
 */
- (instancetype)initWithMasterTagId:(NSInteger )mid presentingViewController:(UIViewController *)viewController;

/**
 Initializes an AFAdInline with the given master tag id, an ad view position and ad size.
 
 @param mid An integer representing Adform master tag id.
 @param viewController The view controller which is presenting the ad view.
 @param size Custom ad size, cannot be less than 250x50.
 
 @return A newly initialized ad view.
 */
- (instancetype)initWithMasterTagId:(NSInteger )mid presentingViewController:(UIViewController *)viewController adSize:(CGSize )size;

/**
 Initializes an AFAdInline with the given ad tag.
 
 @param adTag An object containing adTag that will be loaded.
    For HTML ads adTag must be a NSString object containing the HTML for the banner.
    For VAST ads adTag may be NSString or NSData object containing VAST xml document
    of NSURL object containing an URL for VAST xml document on remote server.
 @param viewController The view controller which is presenting the ad view.
 
 @return A newly initialized ad view.
 */
- (instancetype)initWithAdTag:(id )adTag presentingViewController:(UIViewController *)viewController;

/**
 A convenience method to add key values to ad view.
 This method adds a new value with provided key and value to `keyValues` property.

 If `keyValues` property is nil when this method is called, a new array is created
 and set to it, otherwise this key value is appended to existing array.

 @param value A value to add.
 @param key A key to add.
 */
- (void)addValue:(NSString *)value forKey:(NSString *)key;

/**
 A convenient method to add custom parameter to `customData`property.

 If `customData` property is nil when this method is called, a new dictionary is created
 and set to it, otherwise this key value is appended to existing dictionary.

 @param parameter A parameter to add.
 @param key A key to add.
 */
- (void)addCustomParameter:(NSString *)parameter forKey:(NSString *)key;

/**
 Initiates advertisement loading.
 
 Ads are displayed automatically when loading finishes.
 You can use AFAdInlineDelegate protocol to track ad loading state.
 */
- (void)loadAd;

/**
 Shows (expands) the ad.
 
 If you are setting 'showAdAutomatically' property to NO, then you must use this method to display the ad manually after the succesful load.
 You can call this method only when ad has finished loading. You can check this by waiting for a delegate callback 'adInlineDidLoadAd:',
 or by checking the 'isLoaded' property.
 */
- (void)showAd;

/**
 Returns default ad size depending on iOS platform you are using (iPad or iPhone).
 */
+ (CGSize )defaultAdSize;

@end

/**
 The delegate of an AFAdInline object must adopt the AFAdInlineDelegate protocol.
 
 This protocol has optional methods which allow the delegate to be notified of the ad view lifecycle and state change events.
 */
@protocol AFAdInlineDelegate <NSObject>

@optional

/**
 Gets called when an AFAdInline successfully loads or reloads an ad.
 
 @param adInline An ad view object calling the method.
 */
- (void)adInlineDidLoadAd:(AFAdInline *)adInline;

/**
 Gets called when an AFAdInline fails to loads or reload an ad.
 
 @param adInline An ad view object calling the method.
 @param error An error indicating what went wrong.
 */
- (void)adInlineDidFailToLoadAd:(AFAdInline *)adInline withError:(NSError *)error;

/**
 Gets called when an AFAdInline was clicked by the user to open a landing page.
 
 @param adInline An ad view object calling the method.
 */
- (void)adInlineDidClick:(AFAdInline *)adInline;

/**
 Gets called when an AFAdInline is about to be shown.
 
 This method is called before the ad view animation starts.
 Use adSize property to determine ad view size, because ad view frame and bounds are not set at this moment.
 
 @param adInline An ad view object calling the method.
 */
- (void)adInlineWillShow:(AFAdInline *)adInline;

/**
 Gets called when an ad view is about to be hidden.
 
 This method is called before the ad view animation.
 It is recommended to use adSize, not frame or bounds, property to determine ad view size.
 
 @important When ad view is hidden its frame.size.height is set to 0, but adSize.height stays the same.
 
 @param adInline An ad view object calling the method.
 */
- (void)adInlineWillHide:(AFAdInline *)adInline;

/**
 Informs the delegate that the ad view is about to change its size.
 
 This method gets called when ad view is show, hidden or changes size when a new banner is loaded.
 
 @param adInline An ad view object calling the method.
 @param newSize The size to which the ad view is going to resize.
 */
- (void)adInlineWillChangeSize:(AFAdInline *)adInline toSize:(CGSize)newSize;

/**
 Gets called when an ad view is about to present a modal view with advertisement.
 
 This method is called when the modal view controller is about to be presented after the user has pressed the ad.
 You should stop application activity in topmost view controller at this point.
 
 @param adInline An ad view object calling the method.
 */
- (void)adInlineWillPresentModalView:(AFAdInline *)adInline;

/**
 Gets called when an ad view is about to dismiss previously shown modal view with advertisement.
 
 You should use this method to resume any application activity you stopped in 'adInlineWillPresentModalView:' method.
 
 @param adInline An ad view object calling the method.
 */
- (void)adInlineWillDismissModalView:(AFAdInline *)adInline;

/**
 Gets called when an ad is about to be opened in external browser.
 
 @warning The application is going to be moved to background after this method gets called.
 
 @param adInline An ad view object calling the method.
 */
- (void)adInlineWillOpenExternalBrowser:(AFAdInline *)adInline;

/**
 Gets called when an ad view has started playing a video advertisement.
 
 @param adInline An ad view object calling the method.
 @param muted Identifies if video ad is muted.
 */
- (void)adInlineSartedVideoPlayback:(AFAdInline *)adInline muted:(BOOL )muted;

/**
 Gets called when an ad view has finished playing a video advertisement.
 
 @param adInline An ad view object calling the method.
 */
- (void)adInlineFinishedVideoPlayback:(AFAdInline *)adInline;

/**
 Gets called when a user has muted or unmuted the video advertisement.
 
 @param adInline An ad view object calling the method.
 @param muted Boolean value indicating if user has muted or unmuted the video ad.
 */
- (void)adInline:(AFAdInline *)adInline videoAdMuted:(BOOL )muted;

/**
 Gets called when ad view is presenting an internal browser to allow customization.

 @param adInline An ad view object calling the method.
 @param browserViewController A browser view controller that will be presented.
 */
- (void)adInline:(AFAdInline *)adInline willOpenInternalBrowser:(AFBrowserViewController *)browserViewController;

/**
 Gets called when ad view is presenting a safari view controller to allow customization.

 @param adInline An ad view object calling the method.
 @param safariViewController A safari view controller that is being presented.
 */
- (void)adInline:(AFAdInline *)adInline willOpenSafariViewController:(SFSafariViewController *)safariViewController API_AVAILABLE(ios(9.0));

@end
