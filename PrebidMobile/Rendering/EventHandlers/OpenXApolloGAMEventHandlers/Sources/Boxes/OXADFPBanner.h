//
//  OXADFPBanner.h
//  OpenXApolloGAMEventHandlers
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "OXADFPRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXADFPBanner : NSObject

@property (nonatomic, class, readonly) BOOL classesFound;
@property (nonatomic, strong, readonly) UIView *view;

// Boxed properties
@property (nonatomic, copy, nullable) NSString *adUnitID;
@property (nonatomic, copy, nullable) NSArray<NSValue *> *validAdSizes;
@property (nonatomic, weak, nullable) UIViewController *rootViewController;
@property (nonatomic, weak, nullable) id<GADBannerViewDelegate> delegate;
@property (nonatomic, weak, nullable) id<GADAppEventDelegate> appEventDelegate;
@property (nonatomic, weak, nullable) id<GADAdSizeDelegate> adSizeDelegate;
@property (nonatomic, assign) BOOL enableManualImpressions;
@property (nonatomic, assign) GADAdSize adSize;

- (instancetype)init;

- (void)loadRequest:(nullable OXADFPRequest *)request;
- (void)recordImpression;

@end

NS_ASSUME_NONNULL_END
