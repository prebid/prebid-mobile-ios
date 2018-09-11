/*
 *    Copyright 2018 Prebid.org, Inc.
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

#import <Foundation/Foundation.h>
#import "PBViewTool.h"
#import "MPWebView.h"
#import "MPClosableView.h"
@interface PBViewTool()
@end

@implementation PBViewTool

+ (void) checkMPAdViewContainsPBMAd:(MPAdView *)view withCompletionHandler:(void(^)(BOOL result))completionHandler{
    Boolean checked = NO;
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
            checked = YES;
        }
    }
    if (!checked) {
        NSLog(@"Mraid creative and other situations are not supported yet.");
        completionHandler(NO);
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
