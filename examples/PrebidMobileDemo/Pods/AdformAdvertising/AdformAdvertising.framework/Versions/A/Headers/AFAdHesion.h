//
//  AFAdHesion.h
//  AdformAdvertising
//
//  Created by Vladas Drejeris on 27/04/15.
//  Copyright (c) 2015 Adform. All rights reserved.
//

#import <AdformAdvertising/AdformAdvertising.h>

/**
 The AFAdHesion class provides a view container that displays sticky inline advertisements.
 
 You can use this class to place ad banners at the top or bottom of the screen.
 They are automatically positioned to be fully visible to the user
 and won't be obscured by navigation or tool bars (in case of extended view controller layout).
 */
@interface AFAdHesion : AFAdInline

/**
 Shows ad view position type.
 
 Default value - AFAdPositionBottom.
 
 @see AFAdPosition
 */
@property (nonatomic, assign, readonly) AFAdPosition position;

/**
 A Boolean value indicating whether the adHesion ad hides in response to a swipe gesture.
 Default value - false.
 */
@property (nonatomic, assign) BOOL hidesOnSwipe;

/**
 The gesture recognizer is used to hide the ad view. (read-only)
 
 This property contains the gesture recognizer used to hide and show the ad view. 
 The gesture recognizer is inactive unless the 'hideOnSwipe' property is YES. 
 You can make changes to the gesture recognizer as needed but must not change its delegate 
 and you must not remove the default target object and action that come configured with it. 
 Do not try to replace this gesture recognizer by overriding the property.
 If you tie this gesture recognizer to one of your own, 
 make sure both recognize their gestures simultaneously to ensure that each has a chance to handle the event.
 */
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *swipeGestureRecognizer;

/**
 Indicates if close button should be displayed.
 */
@property (nonatomic, assign) BOOL showCloseButton;

/**
 Initializes an AFAdHesion with the given master tag id and an ad position.
 
 @param mid An integer representing Adform master tag id.
 @param position Ad position.
 @param viewController The view controller which is presenting the ad view.
 
 @return A newly initialized ad view.
 */
- (instancetype)initWithMasterTagId:(NSInteger )mid position:(AFAdPosition )position presentingViewController:(UIViewController *)viewController;

/**
 Initializes an AFAdHesion with the given master tag id, an ad position and ad size.
 
 @param mid An integer representing Adform master tag id.
 @param position Ad position.
 @param viewController The view controller which is presenting the ad view.
 @param size Custom ad size.
 
 @return A newly initialized ad view.
 
 @warning Ad size cannot be less than 250x50.
 */
- (instancetype)initWithMasterTagId:(NSInteger )mid position:(AFAdPosition )position presentingViewController:(UIViewController *)viewController adSize:(CGSize )size;

/**
 Informs the ad view that navigation controller containing it has hidden the navigation bar on swipe.
 
 You must use this method if you are using 'hidesBarsOnSwipe' navigation controller feature to inform the ad view
 that navigation bar has been hidden or displayed.
 You must add this method as an action to navigation controller's 'barHideOnSwipeGestureRecognizer'.
 
 Example:
 \code
    [navigationController.barHideOnSwipeGestureRecognizer addTarget:adHesion action:@selector(didSwipeHidesBars:)];
 \endcode
 */
- (void)didSwipeHidesBars:(UIPanGestureRecognizer *)gestureRecognizer;

/**
 Informs the ad view that navigation controller containing it has hidden the navigation bar on tap.
 
 You must use this method if you are using 'hidesBarsOnTap' navigation controller feature to inform the ad view
 that navigation bar has been hidden or displayed.
 You must add this method as an action to navigation controller's 'barHideOnTapGestureRecognizer'.
 
 Example:
 \code
    [navigationController.barHideOnTapGestureRecognizer addTarget:adHesion action:@selector(didTapHideBars:)];
 \endcode
 */
- (void)didTapHideBars:(UITapGestureRecognizer *)gestureRecognizer;

/**
 Updates ad view position to match layout guides.
 
 You may need to use this method after top or bottom layout guide changes, e.g. navigation or tool bar is hidden.
 In most cases Adform sdk handles those transitions automatically, 
 but in some cases for example when you hide or show a navigation bar manually, you need to call this method to
 force a position update.
 
 @param animated A boolean value indicating if position update should be animated.
 */
- (void)setNeedsPositionUpdate:(BOOL)animated;

@end
