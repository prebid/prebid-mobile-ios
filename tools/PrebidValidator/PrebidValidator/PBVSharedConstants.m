//
//  PBVSharedConstants.m
//  PrebidMobileValidator
//
//  Created by Wei Zhang on 4/13/18.
//  Copyright © 2018 AppNexus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBVSharedConstants.h"

NSString *__nonnull const kAdServerLabelText = @"Ad Server";
NSString *__nonnull const kAdFormatLabelText = @"Ad Format";
NSString *__nonnull const kAdSizeLabelText = @"Ad Size";
NSString *__nonnull const kAdUnitIdText = @"Ad Unit ID";
NSString *__nonnull const kBidPriceText = @"Bid Price(s)";
NSString *__nonnull const kPBAccountIDText = @"Account ID";
NSString *__nonnull const kPBConfigIDText = @"Config ID";

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
NSString *const kNativeString = @"Native";
NSString *const kVideoString = @"Video";

NSString *__nonnull const kBannerSizeString = @"320x50";
NSString *__nonnull const kMediumRectangleSizeString = @"300x250";
NSString *__nonnull const kInterstitialSizeString = @"320x480";


@implementation PBVSharedConstants

+ (instancetype)sharedInstance {
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    
    return instance;
}

@end
