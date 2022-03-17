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

#import "PBMHTMLCreative.h"
#import "PBMUIApplicationProtocol.h"

@protocol PBMMeasurementProtocol;

NS_ASSUME_NONNULL_BEGIN
@interface PBMHTMLCreative () <PBMWebViewDelegate>

@property (nonatomic, strong) PBMWebView *prebidWebView;
@property (nonatomic, strong, nullable) PBMMRAIDController *MRAIDController;

- (instancetype)initWithCreativeModel:(PBMCreativeModel *)creativeModel
                          transaction:(PBMTransaction *)transaction
                              webView:(nullable PBMWebView *)webView
                     sdkConfiguration:(Prebid *)sdkConfiguration;

- (nonnull id<PBMUIApplicationProtocol>)getApplication;

- (BOOL)hasVastTag:(NSString *)html;
@end
NS_ASSUME_NONNULL_END
