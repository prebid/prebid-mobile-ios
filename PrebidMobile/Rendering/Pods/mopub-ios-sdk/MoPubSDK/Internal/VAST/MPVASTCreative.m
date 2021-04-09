//
//  MPVASTCreative.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVASTCreative.h"
#import "MPVASTLinearAd.h"
#import "MPVASTCompanionAd.h"

@implementation MPVASTCreative

#pragma mark - MPVASTModel

- (instancetype _Nullable)initWithDictionary:(NSDictionary<NSString *, id> * _Nullable)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self) {
        // Custom parsing of advertising identifier since it's key changes from VAST 3.0 to VAST 4.0.
        // We will give preference to VAST 4.0 since it is the newer spec.
        id advertisingIdentifier = dictionary[@"adId"];     // VAST 4.0 key
        if (advertisingIdentifier == nil) {
            advertisingIdentifier = dictionary[@"adID"];    // VAST 3.0 key
        }

        // Validate the advertising identifier is a string before attempting to
        // set the property value.
        if (advertisingIdentifier != nil && [advertisingIdentifier isKindOfClass:[NSString class]]) {
            _adID = (NSString *)advertisingIdentifier;
        }
    }
    return self;
}

+ (NSDictionary<NSString *, id> *)modelMap {
    return @{@"identifier":     @"id",
             @"sequence":       @"sequence",
             @"linearAd":       @[@"Linear", MPParseClass([MPVASTLinearAd class])],
             @"companionAds":   @[@"CompanionAds.Companion", MPParseArrayOf(MPParseClass([MPVASTCompanionAd class]))]};
}

@end
