//
//  Constants.m
//  PriceCheckTestApp
//
//  Created by Nicole Hedley on 30/08/2016.
//  Copyright © 2016 Nicole Hedley. All rights reserved.
//

#import "LineItemsConstants.h"

NSString *__nonnull const kAdServerNameKey = @"adServerName";
NSString *__nonnull const kAdFormatNameKey = @"adFormatName";
NSString *__nonnull const kAdSizeKey = @"adSize";
NSString *__nonnull const kAdUnitIdKey = @"adUnitId";
NSString *__nonnull const kBidPriceKey = @"bidPrice";

NSString *__nonnull const kPBAccountKey = @"accountId";
NSString *__nonnull const kPBConfigKey = @"configId";

NSString *__nonnull const kMoPubString = @"MoPub";
NSString *__nonnull const kDFPString = @"DFP";

NSString *__nonnull const kBannerString = @"Banner";
NSString *__nonnull const kInterstitialString = @"Interstitial";

NSString *__nonnull const kBannerSizeString = @"320x50";
NSString *__nonnull const kMediumRectangleSizeString = @"300x250";
NSString *__nonnull const kInterstitialSizeString = @"320x480";

@implementation LineItemsConstants

+ (instancetype)sharedInstance {
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    
    return instance;
}

@end
