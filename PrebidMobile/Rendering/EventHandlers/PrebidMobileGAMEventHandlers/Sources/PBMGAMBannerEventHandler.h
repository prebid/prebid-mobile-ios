//
//  PBMGAMBannerEventHandler.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PrebidMobileRendering/PBMBannerEventHandler.h>

NS_ASSUME_NONNULL_BEGIN

@interface PBMGAMBannerEventHandler : NSObject <PBMBannerEventHandler>

@property (nonatomic, copy, readonly) NSString *adUnitID;

/*!
 Initializes and returns a event handler with the specified DFP ad unit and ad sizes
 
 @param adUnitID DFP ad unit id
 @param adSizes Array of NSValue encoded GADAdSize structs. Never create your own GADAdSize directly. Use one of the predefined
 standard ad sizes (such as kGADAdSizeBanner), or create one using the GADAdSizeFromCGSize
 method.
 Example:
 <pre>
 NSArray *validSizes = @[
 NSValueFromGADAdSize(kGADAdSizeBanner),
 NSValueFromGADAdSize(kGADAdSizeLargeBanner)
 ];
 bannerView.validAdSizes = validSizes;
 </pre>
 */
- (instancetype)initWithAdUnitID:(NSString *)adUnitID
                 validGADAdSizes:(NSArray<NSValue *> *)adSizes;

@end

NS_ASSUME_NONNULL_END
