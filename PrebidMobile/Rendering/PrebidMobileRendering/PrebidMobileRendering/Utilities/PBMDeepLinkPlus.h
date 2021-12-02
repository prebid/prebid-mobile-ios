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

NS_ASSUME_NONNULL_BEGIN

@interface PBMDeepLinkPlus : NSObject

@property (nonatomic, strong, nonnull, readonly) NSURL *primaryURL;
@property (nonatomic, strong, nullable, readonly) NSURL *fallbackURL;
@property (nonatomic, strong, nullable, readonly) NSArray<NSURL *> *primaryTrackingURLs;
@property (nonatomic, strong, nullable, readonly) NSArray<NSURL *> *fallbackTrackingURLs;

- (instancetype)init NS_UNAVAILABLE;
+ (nullable instancetype)deepLinkPlusWithURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
