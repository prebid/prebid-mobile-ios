//
//  AFPageAdView.h
//  AdformAdvertising
//
//  Created by Vladas Drejeris on 25/03/15.
//  Copyright (c) 2015 Adform. All rights reserved.
//

#import "AFAdInline.h"

@protocol AFAdInterstitialDelegate;

/**
 The AFAdInterstitial class provides a view container that displays in page advertisements.
 */
@interface AFAdInterstitial : AFAdInline

/**
 This property indicates if ad view is loaded.
 
 You should check this property before displaying the ad to see if it was already loaded.
 */
@property (nonatomic, assign, readonly, getter=isLoaded) BOOL loaded;

/**
 Indicates if ad view was visible to the user at least once.
 AFAdInterstitial can be reloaded only after being displayed to the user.
 Therefore, youcan check this property to see if ad was displayed to the user and it can be reloaded.
 */
@property (nonatomic, assign, readonly, getter=wasDisplayed) BOOL displayed;

@property (nonatomic, weak) id<AFAdInterstitialDelegate> delegate;

/**
 Initializes a new AFAdView.
 
 You should use this initialization method to create AFPageAdView objects.
 
 @param frame Page ad view frame.
 @param mid An integer representing Adform master tag id.
 
 @return A newly initialized ad view.
 */
- (instancetype)initWithFrame:(CGRect )frame masterTagId:(NSInteger)mid presentingViewController:(UIViewController *)viewController;

@end

/**
 The delegate of an AFAdInterstitial object must adopt the AFAdInterstitialDelegate protocol.
 
 This protocol has optional methods which allow the delegate to be notified of the ad view lifecycle and state change events.
 */
@protocol AFAdInterstitialDelegate <AFAdInlineDelegate>

@optional

/**
 Gets called when the AFAdInterstitial receives close command.
 
 You must implement this delegate method if you want to support interstitial ad close functionality.
 If this method is not implemented the AFAdInterstitial will not close when close arrea or button is clicked.
 
 In this method you should implement any animations used when closing the ad.
 When the animations are finished you must call the completionHandler and pass a bool value
 indicating if everything went ok, and ad has been closed. It is very important to call this block
 to allow the ad view to update its internal state correctly.
 
 @param adInterstitial An ad view object calling the method.
 @param completionHandler A completion handler that must be called when close animations are finished.
    Pass true to this block if everything went ok, and ad should be closed, otherwise pass false 
    to indicate that ad has not closed.
 */
- (void)adInterstitial:(AFAdInterstitial *)adInterstitial didReceiveCloseCommandWithCompletionHandler:(void(^)(BOOL shouldClose))completionHandler;

@end