/*   Copyright 2018-2024 Prebid.org, Inc.
 
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

#import "SampleInterstitialController.h"
#import "UIApplication+TopViewController.h"

@interface SampleInterstitialController ()

@property (nonatomic, strong) UILabel *customRendererLabel;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIViewController *interstitialViewController;

@end

@implementation SampleInterstitialController

- (instancetype)init {
    self = [super init];
    if (self) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 300, 250)];
        _webView.translatesAutoresizingMaskIntoConstraints = NO;
        _webView.backgroundColor = [UIColor blueColor];
        
        _customRendererLabel = [[UILabel alloc] init];
        _customRendererLabel.text = @"Custom Renderer";
        _customRendererLabel.textAlignment = NSTextAlignmentCenter;
        _customRendererLabel.font = [UIFont boldSystemFontOfSize:18];
        _customRendererLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        _interstitialViewController = [[UIViewController alloc] init];
        _interstitialViewController.view.backgroundColor = [UIColor whiteColor];
        [_interstitialViewController.view addSubview:self.customRendererLabel];
        [_interstitialViewController.view addSubview:self.webView];
        
        [NSLayoutConstraint activateConstraints:@[
            [self.customRendererLabel.topAnchor constraintEqualToAnchor:self.interstitialViewController.view.safeAreaLayoutGuide.topAnchor constant:20],
            [self.customRendererLabel.centerXAnchor constraintEqualToAnchor:self.interstitialViewController.view.centerXAnchor],
            [self.webView.centerXAnchor constraintEqualToAnchor:self.interstitialViewController.view.centerXAnchor],
            [self.webView.centerYAnchor constraintEqualToAnchor:self.interstitialViewController.view.centerYAnchor],
            [self.webView.widthAnchor constraintEqualToConstant:300],
            [self.webView.heightAnchor constraintEqualToConstant:250]
        ]];
    }
    return self;
}

- (void)loadAd {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.bid.adm) {
            [self.webView loadHTMLString:self.bid.adm baseURL:nil];
            [self.loadingDelegate interstitialControllerDidLoadAd:self];
        } else {
            NSString * errorMessage = @"Renderer did fail - there is no ADM in the response.";
            NSError *error = [NSError errorWithDomain:@"SampleInterstitialControllerErrorDomain"
                                                 code:102
                                             userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
            [self.loadingDelegate interstitialController:self didFailWithError:error];
        }
    });
}

- (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *presentingController = [UIApplication.sharedApplication topViewController];
        if (presentingController) {
            [presentingController presentViewController:self.interstitialViewController animated:YES completion:nil];
        } else {
            NSString * errorMessage = @"Couldn't find a controller to present from.";
            NSError *error = [NSError errorWithDomain:@"SampleInterstitialControllerErrorDomain"
                                                 code:103
                                             userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
            [self.loadingDelegate interstitialController:self didFailWithError:error];
        }
    });
}

@end
