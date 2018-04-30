#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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
extern NSString *__nonnull const kNativeString;
extern NSString *__nonnull const kVideoString;

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

