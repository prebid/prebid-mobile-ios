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

#import "PBMJsonDecodable.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeAdMarkupEventTracker : NSObject <PBMJsonDecodable>

/// Type of event to track.
/// See Event Types table.
@property (nonatomic, assign) NSInteger event;

/// Type of tracking requested.
/// See Event Tracking Methods table.
@property (nonatomic, assign) NSInteger method;

/// The URL of the image or js.
/// Required for image or js, optional for custom.
@property (nonatomic, copy, nullable) NSString *url;

/// To be agreed individually with the exchange, an array of key:value objects for custom tracking,
/// for example the account number of the DSP with a tracking company. IE {“accountnumber”:”123”}.
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *customdata;

/// This object is a placeholder that may contain custom JSON agreed to by the parties to support flexibility beyond the standard defined in this specification
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *ext;

- (instancetype)initWithEvent:(NSInteger)event
                       method:(NSInteger) method
                          url:(NSString *)url;

@end

NS_ASSUME_NONNULL_END

