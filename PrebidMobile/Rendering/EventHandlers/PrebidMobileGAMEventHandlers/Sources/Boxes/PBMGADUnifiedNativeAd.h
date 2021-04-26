//
//  PBMGADUnifiedNativeAd.h
//  OpenXApolloGAMEventHandlers
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import Foundation;

@class GADUnifiedNativeAd;

NS_ASSUME_NONNULL_BEGIN

@interface PBMGADUnifiedNativeAd : NSObject

@property (nonatomic, class, readonly) BOOL classesFound;
@property (nonatomic, strong, readonly) NSObject *boxedAd;

/// Headline
@property(nonatomic, readonly, copy, nullable) NSString *headline;
/// Text that encourages user to take some action with the ad. For example "Install".
@property(nonatomic, readonly, copy, nullable) NSString *callToAction;
// /// Icon image.
// @property(nonatomic, readonly, strong, nullable) GADNativeAdImage *icon;
/// Description.
@property(nonatomic, readonly, copy, nullable) NSString *body;
// /// Array of GADNativeAdImage objects.
// @property(nonatomic, readonly, strong, nullable) NSArray<GADNativeAdImage *> *images;
/// App store rating (0 to 5).
@property(nonatomic, readonly, copy, nullable) NSDecimalNumber *starRating;
/// The app store name. For example, "App Store".
@property(nonatomic, readonly, copy, nullable) NSString *store;
/// String representation of the app's price.
@property(nonatomic, readonly, copy, nullable) NSString *price;
/// Identifies the advertiser. For example, the advertiser’s name or visible URL.
@property(nonatomic, readonly, copy, nullable) NSString *advertiser;
// /// Media content. Set the associated media view's mediaContent property to this object to display
// /// this content.
// @property(nonatomic, readonly, nonnull) GADMediaContent *mediaContent;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithUnifiedNativeAd:(GADUnifiedNativeAd *)unifiedNativeAd NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
