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

@class Bid;
@protocol DisplayViewLoadingDelegate;
@protocol DisplayViewInteractionDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface PBMDisplayView : UIView

@property (atomic, weak, nullable) NSObject<DisplayViewLoadingDelegate> *loadingDelegate;
@property (atomic, weak, nullable) NSObject<DisplayViewInteractionDelegate> *interactionDelegate;
@property (nonatomic, readonly) BOOL isCreativeOpened;

- (instancetype)initWithFrame:(CGRect)frame bid:(Bid *)bid configId:(NSString *)configId;

- (void)displayAd;

@end

NS_ASSUME_NONNULL_END
