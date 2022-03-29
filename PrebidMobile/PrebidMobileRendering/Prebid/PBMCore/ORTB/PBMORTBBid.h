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

#import "PBMORTBAbstractResponse.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 4.2.2: SeatBid

/// A SeatBid object contains one or more `Bid` objects, each of which relates to a specific impression in the bid
/// request via the `impid` attribute and constitutes an offer to buy that impression for a given `price`.
@interface PBMORTBBid<__covariant ExtType> : PBMORTBAbstractResponse<ExtType>

/// [Required]
/// Bidder generated bid ID to assist with logging/tracking.
@property (nonatomic, copy) NSString *bidID;

/// [Required]
/// ID of the Imp object in the related bid request.
@property (nonatomic, copy) NSString *impid;

/// [Required]
/// [Float]
/// Bid price expressed as CPM although the actual transaction is for a unit impression only. Note that while the type
/// indicates float, integer math is highly recommended when handling currencies (e.g., BigDecimal in Java).
@property (nonatomic, strong) NSNumber *price;

/// Win notice URL called by the exchange if the bid wins (not necessarily indicative of a delivered, viewed, or
/// billable ad); optional means of serving ad markup. Substitution macros (Section 4.4) may be included in both the URL
/// and optionally returned markup.
@property (nonatomic, copy, nullable) NSString *nurl;

/// Billing notice URL called by the exchange when a winning bid becomes billable based on exchange-specific business
/// policy (e.g., typically delivered, viewed, etc.). Substitution macros (Section 4.4) may be included.
@property (nonatomic, copy, nullable) NSString *burl;

/// Loss notice URL called by the exchange when a bid is known to have been lost. Substitution macros (Section 4.4)
/// may be included. Exchange-specific policy may preclude support for loss notices or the disclosure of winning
/// clearing prices resulting in ${AUCTION_PRICE} macros being removed (i.e., replaced with a zero-length string).
@property (nonatomic, copy, nullable) NSString *lurl;

/// Optional means of conveying ad markup in case the bid wins; supersedes the win notice if markup is included in both.
/// Substitution macros (Section 4.4) may be included.
@property (nonatomic, copy, nullable) NSString *adm;

/// ID of a preloaded ad to be served if the bid wins.
@property (nonatomic, copy, nullable) NSString *adid;

/// Advertiser domain for block list checking (e.g., “ford.com”). This can be an array of for the case of rotating
/// creatives. Exchanges can mandate that only one domain is allowed.
@property (nonatomic, copy, nullable) NSArray<NSString *> *adomain;

/// A platform-specific application identifier intended to be unique to the app and independent of the exchange.
/// On Android, this should be a bundle or package name (e.g., com.foo.mygame).
/// On iOS, it is a numeric ID.
@property (nonatomic, copy, nullable) NSString *bundle;

/// URL without cache-busting to an image that is representative of the content of the campaign for ad quality/safety
/// checking.
@property (nonatomic, copy, nullable) NSString *iurl;

/// Campaign ID to assist with ad quality checking; the collection of creatives for which iurl should be representative.
@property (nonatomic, copy, nullable) NSString *cid;

/// Creative ID to assist with ad quality checking.
@property (nonatomic, copy, nullable) NSString *crid;

/// Tactic ID to enable buyers to label bids for reporting to the exchange the tactic through which their bid was submitted.
/// The specific usage and meaning of the tactic ID should be communicated between buyer and exchanges _a priori_.
@property (nonatomic, copy, nullable) NSString *tactic;

/// IAB content categories of the creative. Refer to List 5.1.
@property (nonatomic, copy, nullable) NSArray<NSString *> *cat;

/// [Integer array]
/// Set of attributes describing the creative. Refer to List 5.3.
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *attr;

/// [Integer]
/// API required by the markup if applicable. Refer to List 5.6.
@property (nonatomic, copy, nullable) NSNumber *api;

/// [Integer]
/// Video response protocol of the markup if applicable. Refer to List 5.8.
@property (nonatomic, copy, nullable) NSNumber *protocol;

/// [Integer]
/// Creative media rating per IQG guidelines. Refer to List 5.19.
@property (nonatomic, copy, nullable) NSNumber *qagmediarating;

/// Language of the creative using ISO-639-1-alpha-2. The non- standard code “xx” may also be used if the creative has no
/// linguistic content (e.g., a banner with just a company logo).
@property (nonatomic, copy, nullable) NSString *language;

/// Reference to the `deal.id` from the bid request if this bid pertains to a private marketplace direct deal.
@property (nonatomic, copy, nullable) NSString *dealid;

/// [Integer]
/// Width of the creative in device independent pixels (DIPS).
@property (nonatomic, strong, nullable) NSNumber *w;

/// [Integer]
/// Height of the creative in device independent pixels (DIPS).
@property (nonatomic, strong, nullable) NSNumber *h;

/// [Integer]
/// Relative width of the creative when expressing size as a ratio. Required for Flex Ads.
@property (nonatomic, strong, nullable) NSNumber *wratio;

/// [Integer]
/// Relative height of the creative when expressing size as a ratio. Required for Flex Ads.
@property (nonatomic, strong, nullable) NSNumber *hratio;

/// [Integer]
/// Advisory as to the number of seconds the bidder is willing to wait between the auction and the actual impression.
@property (nonatomic, strong, nullable) NSNumber *exp;

// Placeholder for bidder-specific extensions to OpenRTB.
// ext is stored in superclass

@end

NS_ASSUME_NONNULL_END
