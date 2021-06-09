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

#import "PBMORTBAbstract.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 3.2.15: Publisher

//This object describes the publisher of the media in which the ad will be displayed. The publisher is
//typically the seller in an OpenRTB transaction.
@interface PBMORTBPublisher : PBMORTBAbstract

//Exchange-specific publisher ID.
@property (nonatomic, copy, nullable) NSString *publisherID;

//Publisher name (may be aliased at the publisher’s request)
@property (nonatomic, copy, nullable) NSString *name;

//Array of IAB content categories that describe the publisher
@property (nonatomic, copy) NSArray<NSString *> *cat;

//Highest level domain of the publisher (e.g., “publisher.com”)
@property (nonatomic, copy, nullable) NSString *domain;

//Placeholder for exchange-specific extensions to OpenRTB.
//Note: ext is not supported.

- (instancetype )init;

@end

NS_ASSUME_NONNULL_END
