//
//  PBMNativeMarkupRequestObject.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMNativeAsset.h"
#import "PBMNativeEventTracker.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeMarkupRequestObject : NSObject <NSCopying>

/// Version of the Native Markup version in use.
@property (nonatomic, copy, nullable, readonly) NSString *version;

/// [Recommended]
/// [Integer]
/// The context in which the ad appears.
/// See PBMNativeContextType
@property (nonatomic, strong, nullable) NSNumber *context;

/// [Integer]
/// A more detailed context in which the ad appears.
/// See PBMNativeContextSubtype
@property (nonatomic, strong, nullable) NSNumber *contextsubtype;

/// [Recommended]
/// [Integer]
/// The design/format/layout of the ad unit being offered.
/// See PBMNativePlacementType
@property (nonatomic, strong, nullable) NSNumber *plcmttype;

// NOT SUPPORTED:
// /// [Integer]
// /// The number of identical placements in this Layout. Refer Section 8.1 Multiplacement Bid Requests for further detail.
// @property (nonatomic, strong, nullable) NSNumber *plcmtcnt;

/// [Integer]
/// 0 for the first ad, 1 for the second ad, and so on.
/// Note this would generally NOT be used in combination with plcmtcnt -
/// either you are auctioning multiple identical placements (in which case plcmtcnt>1, seq=0)
/// or you are holding separate auctions for distinct items in the feed (in which case plcmtcnt=1, seq=>=1)
@property (nonatomic, strong, nullable) NSNumber *seq;

/// [Required]
/// An array of Asset Objects. Any objects bid response must comply with the array of elements expressed in the bid request.
@property (nonatomic, copy) NSArray<PBMNativeAsset *> *assets;

// NOT SUPPORTED:
// /// [Integer]
// /// Whether the supply source / impression supports returning an assetsurl instead of an asset object. 0 or the absence of the field indicates no such support.
// @property (nonatomic, strong, nullable) NSNumber *aurlsupport;

// NOT SUPPORTED:
// /// [Integer]
// /// Whether the supply source / impression supports returning a dco url instead of an asset object. 0 or the absence of the field indicates no such support.
// /// Beta feature.
// @property (nonatomic, strong, nullable) NSNumber *durlsupport;

/// Specifies what type of event objects tracking is supported - see Event Trackers Request Object
@property (nonatomic, copy, nullable) NSArray<PBMNativeEventTracker *> *eventtrackers;

/// [Recommended]
/// [Integer]
/// Set to 1 when the native ad supports buyer-specific privacy notice. Set to 0 (or field absent) when the native ad doesn’t support custom privacy links or if support is unknown.
@property (nonatomic, strong, nullable) NSNumber *privacy;

/// This object is a placeholder that may contain custom JSON agreed to by the parties to support flexibility beyond the standard defined in this specification
@property (nonatomic, copy, nullable, readonly) NSDictionary<NSString *, id> *ext;
- (BOOL)setExt:(nullable NSDictionary<NSString *, id> *)ext
         error:(NSError * _Nullable __autoreleasing * _Nullable)error;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAssets:(NSArray<PBMNativeAsset *> *)assets NS_DESIGNATED_INITIALIZER;


@end

NS_ASSUME_NONNULL_END
