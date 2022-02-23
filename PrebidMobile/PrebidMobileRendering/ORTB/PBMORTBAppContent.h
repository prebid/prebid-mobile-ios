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

@class PBMORTBContentProducer;
@class PBMORTBContentData;

NS_ASSUME_NONNULL_BEGIN

/// Describes an [OpenRTB](https://www.iab.com/wp-content/uploads/2016/03/OpenRTB-API-Specification-Version-2-5-FINAL.pdf) app: content object

@interface PBMORTBAppContent : PBMORTBAbstract
/// ID uniquely identifying the content.
@property (nonatomic, copy, nullable) NSString *id;
/// Episode number.
@property (nonatomic, copy, nullable) NSNumber *episode;
/// Content title.
@property (nonatomic, copy, nullable) NSString *title;
/// Content series.
@property (nonatomic, copy, nullable) NSString *series;
/// Content season.
@property (nonatomic, copy, nullable) NSString *season;
/// Artist credited with the content.
@property (nonatomic, copy, nullable) NSString *artist;
/// Genre that best describes the content.
@property (nonatomic, copy, nullable) NSString *genre;
/// Album to which the content belongs; typically for audio.
@property (nonatomic, copy, nullable) NSString *album;
/// International Standard Recording Code conforming to ISO- 3901.
@property (nonatomic, copy, nullable) NSString *isrc;
/// This object defines the producer of the content in which the ad will be shown.
@property (nonatomic, copy, nullable) PBMORTBContentProducer *producer;
/// URL of the content, for buy-side contextualization or review.
@property (nonatomic, copy, nullable) NSString *url;
/// Array of IAB content categories that describe the content producer.
@property (nonatomic, copy, nullable) NSArray<NSString *> *cat;
/// Production quality.
@property (nonatomic, copy, nullable) NSNumber *prodq;
/// Type of content (game, video, text, etc.).
@property (nonatomic, copy, nullable) NSNumber *context;
/// Content rating.
@property (nonatomic, copy, nullable) NSString *contentrating;
/// User rating of the content.
@property (nonatomic, copy, nullable) NSString *userrating;
/// Media rating per IQG guidelines.
@property (nonatomic, copy, nullable) NSNumber *qagmediarating;
/// Comma separated list of keywords describing the content.
@property (nonatomic, copy, nullable) NSString *keywords;
/// 0 = not live, 1 = content is live.
@property (nonatomic, copy, nullable) NSNumber *livestream;
/// 0 = indirect, 1 = direct.
@property (nonatomic, copy, nullable) NSNumber *sourcerelationship;
/// Length of content in seconds; appropriate for video or audio.
@property (nonatomic, copy, nullable) NSNumber *len;
/// Content language using ISO-639-1-alpha-2.
@property (nonatomic, copy, nullable) NSString *language;
/// Indicator of whether or not the content is embeddable (e.g., an embeddable video player), where 0 = no, 1 = yes.
@property (nonatomic, copy, nullable) NSNumber *embeddable;
/// The data and segment objects together allow additional data about the related object (e.g., user, content) to be specified.
@property (nonatomic, strong, nullable) NSArray<PBMORTBContentData *> *data;
/// Placeholder for exchange-specific extensions to OpenRTB.
@property (nonatomic, strong, nullable) NSMutableDictionary<NSString *, NSObject *> *ext;

- (instancetype )init;

@end

NS_ASSUME_NONNULL_END
