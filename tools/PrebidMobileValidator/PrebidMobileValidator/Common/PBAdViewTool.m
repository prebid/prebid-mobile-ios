
#import <Foundation/Foundation.h>
#import "PBAdViewTool.h"
#import "MPWebView.h"
@interface PBAdViewTool()
@end

@implementation PBAdViewTool

+ (void) checkMPAdViewContainsPBMAd:(MPAdView *)view withCompletionHandler:(void(^)(BOOL result))completionHandler{
    for(UIView *i in view.subviews){
        if([i isKindOfClass:[MPWebView class]]){
            MPWebView *wv = (MPWebView *) i;
            [wv evaluateJavaScript:@"document.body.innerHTML" completionHandler:^(id result, NSError *error) {
                NSString *content= (NSString *)result;
                if ([content containsString:@"prebid/pbm.js"]) {
                    completionHandler(YES);
                } else {
                    completionHandler(NO);
                }
            }];
        }
    }
}

+ (BOOL) checkDFPAdViewContainsPBMAd:(GADBannerView *)view{
    for (UIView *level1 in view.subviews){
        NSArray *level2s = level1.subviews;
        for(UIView *level2 in level2s){
            for (UIView *level3 in level2.subviews){
                if([level3 isKindOfClass:[UIWebView class]])
                {
                    UIWebView *wv = (UIWebView *)level3;
                    NSString *content = [wv stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
                    if ([content containsString:@"prebid/pbm.js"]) {
                        return true;
                    }
                }
            }
        }
    }
    return false;
}

@end
