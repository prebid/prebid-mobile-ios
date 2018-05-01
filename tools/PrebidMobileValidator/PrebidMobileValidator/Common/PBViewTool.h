#import "MPAdView.h"
@import GoogleMobileAds;

@interface PBViewTool:NSObject

+ (void) checkMPAdViewContainsPBMAd:(MPAdView *)view
              withCompletionHandler:(void(^)(BOOL result))completionHandler;

+ (BOOL) checkDFPAdViewContainsPBMAd:(GADBannerView *)view;

@end

