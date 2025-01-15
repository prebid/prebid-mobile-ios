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

#import "SampleAdView.h"

@interface SampleAdView ()

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UILabel *customRendererLabel;

@end

@implementation SampleAdView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.webView = [[WKWebView alloc] init];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.webView];
    
    self.customRendererLabel = [[UILabel alloc] init];
    self.customRendererLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.customRendererLabel.text = @"Custom Renderer";
    self.customRendererLabel.textColor = [UIColor whiteColor];
    self.customRendererLabel.font = [UIFont boldSystemFontOfSize:10];
    self.customRendererLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.customRendererLabel.textAlignment = NSTextAlignmentCenter;
    self.customRendererLabel.layer.cornerRadius = 5;
    self.customRendererLabel.layer.masksToBounds = YES;
    self.customRendererLabel.numberOfLines = 0;
    [self addSubview:self.customRendererLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.webView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.webView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.webView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.webView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        
        [self.customRendererLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:5],
        [self.customRendererLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10],
        [self.customRendererLabel.heightAnchor constraintEqualToConstant:40],
        [self.customRendererLabel.widthAnchor constraintEqualToConstant:50]
    ]];
}

- (void)loadAd {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.bid.adm) {
            [self.webView loadHTMLString:self.bid.adm baseURL:nil];
            [self.loadingDelegate displayViewDidLoadAd:self];
        } else {
            NSString * errorMessage = @"Renderer did fail - there is no ADM in the response.";
            NSError *error = [NSError errorWithDomain:@"SampleAdViewErrorDomain"
                                                 code:101
                                             userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
            
            [self.loadingDelegate displayView:self didFailWithError:error];
        }
    });
}

@end
