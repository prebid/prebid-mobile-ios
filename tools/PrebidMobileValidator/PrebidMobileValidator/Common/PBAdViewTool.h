#import "MPAdView.h"
@import GoogleMobileAds;

@interface PBAdViewTool:NSObject

+ (void) checkMPAdViewContainsPBMAd:(MPAdView *)view
              withCompletionHandler:(void(^)(BOOL result))completionHandler;

+ (BOOL) checkDFPAdViewContainsPBMAd:(GADBannerView *)view;

@end

