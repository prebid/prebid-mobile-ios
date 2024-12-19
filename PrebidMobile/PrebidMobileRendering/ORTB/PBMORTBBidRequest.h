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
#import "PBMMacros.h"

@class PBMORTBApp;
@class PBMORTBBidRequestExtPrebid;
@class PBMORTBDevice;
@class PBMORTBImp;
@class PBMORTBRegs;
@class PBMORTBSource;
@class PBMORTBUser;

// This file holds the structure for an ORTB 2.5 Bid Request Object
// https://www.iab.com/wp-content/uploads/2016/03/OpenRTB-API-Specification-Version-2-5-FINAL.pdf

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 3.2.1: BidRequest

// The top-level bid request object contains a globally unique bid request or auction ID. This id att;ribute is
//     required as is at least one impression object (Section 3.2.4). Other attributes in this top-level object
// establish rules and restrictions that apply to all impressions being offered.
// There are also several subordinate objects that provide detailed data to potential buyers. Among these
// are the Site and App objects, which describe the type of published media in which the impression(s)
// appear. These objects are highly recommended, but only one applies to a given bid request depending
// on whether the media is browser-based web content or a non-browser application, respectively.
@interface PBMORTBBidRequest : PBMORTBAbstract

// Unique ID of the bid request, provided by the exchange.
@property(nonatomic, copy, nullable) NSString *requestID;

// Array of Imp objects (Section 3.2.4) representing the impressions offered. At least 1 Imp object is required.
@property(nonatomic, copy) NSArray<PBMORTBImp *> *imp;

// Note: Site object not supported.
// Details via a Site object (Section 3.2.13) about the publisher’s website. Only applicable and recommended for websites.

// Details via an App object (Section 3.2.14) about the publisher’s
// app (i.e., non-browser applications). Only applicable and
// recommended for apps
@property(nonatomic, strong) PBMORTBApp *app;

// Details via a Device object (Section 3.2.18) about the user’s
// device to which the impression will be delivered.
@property(nonatomic, strong) PBMORTBDevice *device;

// Details via a User object (Section 3.2.20) about the human
// user of the device; the advertising audience.
@property(nonatomic, strong) PBMORTBUser *user;

// Integer. Indicator of test mode in which auctions are not billable,
// where 0 = live mode, 1 = test mode.
@property(nonatomic, strong, nullable) NSNumber *test;

// Auction type, where 1 = First Price, 2 = Second Price Plus.
// Exchange-specific auction types can be defined using values
// greater than 500.
// Note: at is not supported

// Maximum time in milliseconds the exchange allows for bids to
// be received including Internet latency to avoid timeout. This
// value supersedes any a priori guidance from the exchange
@property(nonatomic, strong, nullable) NSNumber *tmax;

// White list of buyer seats (e.g., advertisers, agencies) allowed
// to bid on this impression. IDs of seats and knowledge of the
// buyer’s customers to which they refer must be coordinated
// between bidders and the exchange a priori. At most, only one
// of wseat and bseat should be used in the same request.
// Omission of both implies no seat restrictions
// Note: wseat is not supported

// Block list of buyer seats (e.g., advertisers, agencies) restricted
// from bidding on this impression. IDs of seats and knowledge
// of the buyer’s customers to which they refer must be
// coordinated between bidders and the exchange a priori. At
// most, only one of wseat and bseat should be used in the
// same request. Omission of both implies no seat restrictions.
// Note: bseat is not supported

// Flag to indicate if Exchange can verify that the impressions
// offered represent all of the impressions available in context
//(e.g., all on the web page, all video spots such as pre/mid/post
// roll) to support road-blocking. 0 = no or unknown, 1 = yes, the
// impressions offered represent all that are available.
// Note: allimps is not supported

// Array of allowed currencies for bids on this bid request using
// ISO-4217 alpha codes. Recommended only if the exchange
// accepts multiple currencies.
// Note: cur is not supported

// White list of languages for creatives using ISO-639-1-alpha-2.
// Omission implies no specific restrictions, but buyers would be
// advised to consider language attribute in the Device and/or
// Content objects if available.
// Note: wlang is not supported

// Blocked advertiser categories using the IAB content
// categories. Refer to List 5.1.
// Note: bcat is not supported

// Block list of advertisers by their domains (e.g., “ford.com”).
// Note: badv is not supported

// Block list of applications by their platform-specific exchangeindependent
// application identifiers. On Android, these should
// be bundle or package names (e.g., com.foo.mygame). On iOS,
// these are numeric IDs
// Note: bapp is not supported

// A Source object (Section 3.2.2) that provides data about the
// inventory source and which entity makes the final decision
@property(nonatomic, readonly) PBMORTBSource *source;

// A Regs object (Section 3.2.3) that specifies any industry, legal,
// or governmental regulations in force for this request.
@property(nonatomic, strong) PBMORTBRegs *regs;

// Placeholder for exchange-specific extensions to OpenRTB.
// Note: ext object not supported.

@property(nonatomic, strong) PBMORTBBidRequestExtPrebid *extPrebid;

@property(nonatomic, strong, nullable) NSDictionary<NSString *, id> *arbitraryJsonConfig __deprecated__("This property is deprecated and will be removed in future versions");
@property(nonatomic, strong, nullable) NSDictionary<NSString *, id> *ortbObject __deprecated__("This property is deprecated and will be removed in future versions");

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
