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

// This protocol allows the VideoView to communicate events out to whatever is using one
NS_ASSUME_NONNULL_BEGIN
@protocol PBMVideoViewDelegate <NSObject>

- (void)videoViewFailedWithError:(NSError *)error;

- (void)videoViewReadyToDisplay;
- (void)videoViewCompletedDisplay;
- (void)videoViewWasTapped;

- (void)learnMoreWasClicked;

@end
NS_ASSUME_NONNULL_END
