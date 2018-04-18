#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark -sample
extern NSString *__nonnull const kAdServer;
extern NSString *__nonnull const kAdType;
extern NSString *__nonnull const kPlacementId;
extern NSString *__nonnull const kSize;

extern NSString *__nonnull const kDefaultPlacementId;
extern NSString *__nonnull const kDefaultSize;

extern NSString *__nonnull const kBanner;
extern NSString *__nonnull const kInterstitial;
extern NSString *__nonnull const kNative;
extern NSString *__nonnull const kVideo;

#pragma mark - MoPub constants
extern NSString *__nonnull const kMoPubAdServer;
extern NSString *__nonnull const kMoPubBannerAdUnitId;
extern NSString *__nonnull const kMoPubInterstitialAdUnitId;

#pragma mark - DFP constants
extern NSString *__nonnull const kDFPAdServer;
extern NSString *__nonnull const kDFPBannerAdUnitId;
extern NSString *__nonnull const kDFPInterstitialAdUnitId;

#pragma mark - Prebid Mobile constants
extern NSString *__nonnull const kAccountId;
extern NSString *__nonnull const kAdUnit1ConfigId;
extern NSString *__nonnull const kAdUnit2ConfigId;
extern NSString *__nonnull const kPBServerHost;

extern NSString *__nonnull const kAdUnit1Id;
extern NSString *__nonnull const kAdUnit2Id;

#pragma mark - Prebid Mobile Validator constants

extern NSString *__nonnull const kAdServerLabelText;
extern NSString *__nonnull const kAdFormatLabelText;
extern NSString *__nonnull const kAdSizeLabelText;
extern NSString *__nonnull const kAdUnitIdText;
extern NSString *__nonnull const kBidPriceText;
extern NSString *__nonnull const kPBAccountIDText;
extern NSString *__nonnull const kPBConfigIDText;

extern NSString *__nonnull const kAdServerNameKey;
extern NSString *__nonnull const kAdFormatNameKey;
extern NSString *__nonnull const kAdSizeKey;
extern NSString *__nonnull const kAdUnitIdKey;
extern NSString *__nonnull const kBidPriceKey;

extern NSString *__nonnull const kPBAccountKey;
extern NSString *__nonnull const kPBConfigKey;

extern NSString *__nonnull const kMoPubString;
extern NSString *__nonnull const kDFPString;

extern NSString *__nonnull const kBannerString;
extern NSString *__nonnull const kInterstitialString;

extern NSString *__nonnull const kBannerSizeString;
extern NSString *__nonnull const kMediumRectangleSizeString;
extern NSString *__nonnull const kInterstitialSizeString;

static CGFloat const kBannerSizeWidth = 320.0f;
static CGFloat const kBannerSizeHeight = 50.0f;
static CGFloat const kMediumRectangleSizeWidth = 300.0f;
static CGFloat const kMediumRectangleSizeHeight = 250.0f;
static CGFloat const kInterstitialSizeWidth = 320.0f;
static CGFloat const kInterstitialSizeHeight = 480.0f;

static CGFloat const kAdLocationY = 30.0f;
static CGFloat const kAdLabelLocationX = 10.0f;
static CGFloat const kAdLabelLocationY = 5.0f;
static CGFloat const kAdTitleLabelHeight = 20.0f;
static CGFloat const kAdFailedLabelHeight = 50.0f;
static CGFloat const kAdMargin = 10.0f;


@interface PBVSharedConstants: NSObject

@property (nonatomic, strong) NSString * _Nullable requestString;
@property (nonatomic, strong) NSString * _Nullable responseString;

+ (instancetype _Nonnull)sharedInstance;

@end

