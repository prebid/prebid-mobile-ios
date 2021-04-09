//
//  OXABid.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OXABid : NSObject

/// Bid price expressed as CPM although the actual transaction is for a unit impression only. Note that while the type
/// indicates float, integer math is highly recommended when handling currencies (e.g., BigDecimal in Java).
@property (nonatomic, readonly) float price;

/// Win notice URL called by the exchange if the bid wins (not necessarily indicative of a delivered, viewed, or
/// billable ad); optional means of serving ad markup. Substitution macros (Section 4.4) may be included in both the URL
/// and optionally returned markup.
@property (nonatomic, readonly, nullable) NSString *nurl;

/// Optional means of conveying ad markup in case the bid wins; supersedes the win notice if markup is included in both.
/// Substitution macros (Section 4.4) may be included.
@property (nonatomic, readonly, nullable) NSString *adm;

/// Ad size
@property (nonatomic, readonly) CGSize size;

/// Targeting information that needs to be passed to the ad server SDK.
@property (nonatomic, readonly, nullable) NSDictionary<NSString *, NSString *> *targetingInfo;

/// A dictionary with information about SKAdNetwork for loadProcut
@property (nonatomic, readonly, nullable) NSDictionary<NSString *, id> *skadnInfo;

/// Returns YES if this bid is intented for display.
@property (nonatomic, readonly) BOOL isWinning;

@end

NS_ASSUME_NONNULL_END
