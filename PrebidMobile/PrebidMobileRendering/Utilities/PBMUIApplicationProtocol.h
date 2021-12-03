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


//Since only one UIApplication can exist at a time it can only be "mocked" by applying a protocol
//to it that it already conforms to.

#import <UIKit/UIKit.h>

@protocol PBMUIApplicationProtocol

@property (nonatomic, assign) BOOL isStatusBarHidden;
@property (nonatomic, assign) UIInterfaceOrientation statusBarOrientation;
@property (nonatomic, assign, readonly) CGRect statusBarFrame;

- (BOOL)openURL:(nonnull NSURL*)url NS_DEPRECATED_IOS(2_0, 10_0, "Please use openURL:options:completionHandler: instead") NS_EXTENSION_UNAVAILABLE_IOS("");
- (void)openURL:(nonnull NSURL*)url options:(nullable NSDictionary<NSString *, id> *)options completionHandler:(void (^ __nullable)(BOOL success))completion NS_AVAILABLE_IOS(10_0) NS_EXTENSION_UNAVAILABLE_IOS("");

@end

//Apply the protocol to UIApplication
@interface UIApplication (PBMUIApplicationProtocol) <PBMUIApplicationProtocol>
@end

@implementation UIApplication (PBMUIApplicationProtocol)
@dynamic isStatusBarHidden;
@end
