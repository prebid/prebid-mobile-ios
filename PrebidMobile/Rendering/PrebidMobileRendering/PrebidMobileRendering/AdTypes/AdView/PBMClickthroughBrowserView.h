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

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "PBMClickthroughBrowserViewDelegate.h"


NS_SWIFT_NAME(ClickthroughBrowserView)
@interface PBMClickthroughBrowserView : UIView

@property (weak, nonatomic, nullable) IBOutlet UIView *controls;
@property (strong, nonatomic, readonly, nullable) WKWebView *webView;
@property (weak, nonatomic, nullable) IBOutlet UIButton *backButton;
@property (weak, nonatomic, nullable) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic, nullable) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic, nullable) IBOutlet UIButton *externalBrowserButton;
@property (weak, nonatomic, nullable) IBOutlet UIButton *closeButton;
@property (nonatomic, weak, nullable) id<PBMClickthroughBrowserViewDelegate> clickThroughBrowserViewDelegate;

- (IBAction)backButtonPressed;
- (IBAction)forwardButtonPressed;
- (IBAction)refreshButtonPressed;
- (IBAction)externalBrowserButtonPressed;
- (IBAction)closeButtonPressed;
- (void)openURL:(nonnull NSURL *)url completion:(void (^_Nullable)(BOOL shouldBeDisplayed))completion NS_SWIFT_NAME(openURL(_:completion:));

@end
