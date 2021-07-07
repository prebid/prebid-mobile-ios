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

#import "PBMNativeClickTrackerBinderBlock.h"
#import "PBMNativeAdMarkupLink.h"

@class UIView;

NS_ASSUME_NONNULL_BEGIN

@class PBMNativeClickTrackingEntry;
typedef void (^PBMNativeClickHandlerBlock)(PBMNativeClickTrackingEntry *clickTrackingEntry);


// MARK: - PBMNativeClickTrackingEntry
@interface PBMNativeClickTrackingEntry : NSObject

@property (atomic, weak, nullable, readonly) UIView *trackedView;

@property (atomic, copy, nullable) NSString *url;
@property (atomic, copy, nullable) NSString *fallback;
@property (atomic, strong, nullable) NSArray<NSString *> *clicktrackers;

- (instancetype)initWithView:(UIView *)view
                 clickBinder:(PBMNativeClickTrackerBinderBlock)clickBinderBlock
                clickHandler:(PBMNativeClickHandlerBlock)clickHandlerBlock NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
