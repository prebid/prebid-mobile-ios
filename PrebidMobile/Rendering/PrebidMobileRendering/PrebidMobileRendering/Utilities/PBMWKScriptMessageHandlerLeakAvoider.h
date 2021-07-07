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


// This class is needed to fix memory leak in WKUserContentController.
// Without it the instances of PBMWebView are never destroyed.
// The description of the issue and soulution could be found here:
// https://stackoverflow.com/questions/26383031/wkwebview-causes-my-view-controller-to-leak

NS_ASSUME_NONNULL_BEGIN
@interface PBMWKScriptMessageHandlerLeakAvoider : NSObject<WKScriptMessageHandler>

@property (nonatomic, weak) id<WKScriptMessageHandler> delegate;

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)delegate;

@end
NS_ASSUME_NONNULL_END
