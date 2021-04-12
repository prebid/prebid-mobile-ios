//
//  OXMClickthroughBrowserView.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "OXMClickthroughBrowserViewDelegate.h"


NS_SWIFT_NAME(ClickthroughBrowserView)
@interface OXMClickthroughBrowserView : UIView

@property (weak, nonatomic, nullable) IBOutlet UIView *controls;
@property (strong, nonatomic, readonly, nullable) WKWebView *webView;
@property (weak, nonatomic, nullable) IBOutlet UIButton *backButton;
@property (weak, nonatomic, nullable) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic, nullable) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic, nullable) IBOutlet UIButton *externalBrowserButton;
@property (weak, nonatomic, nullable) IBOutlet UIButton *closeButton;
@property (nonatomic, weak, nullable) id<OXMClickthroughBrowserViewDelegate> clickThroughBrowserViewDelegate;

- (IBAction)backButtonPressed;
- (IBAction)forwardButtonPressed;
- (IBAction)refreshButtonPressed;
- (IBAction)externalBrowserButtonPressed;
- (IBAction)closeButtonPressed;
- (void)openURL:(nonnull NSURL *)url completion:(void (^_Nullable)(BOOL shouldBeDisplayed))completion NS_SWIFT_NAME(openURL(_:completion:));

@end
