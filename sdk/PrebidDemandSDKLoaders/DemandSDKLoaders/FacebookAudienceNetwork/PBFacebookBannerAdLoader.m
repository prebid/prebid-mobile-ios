/*   Copyright 2017 APPNEXUS INC
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "PBFacebookBannerAdLoader.h"

#import "PBConstants.h"

struct FBAdSize {
    CGSize size;
};

@implementation PBFacebookBannerAdLoader

- (void)loadAd:(NSDictionary *)info {
	// TODO nicole remove bid payload override
	//NSString *bidPayload = @"{\"type\":\"ID\",\"bid_id\":\"5359403918734405361\",\"placement_id\":\"1995257847363113_1997038003851764\",\"sdk_version\":\"4.25.0-appnexus.bidding\",\"device_id\":\"87ECBA49-908A-428F-9DE7-4B9CED4F486C\",\"template\":7,\"payload\":\"null\"}";

	// TODO nicole add this back in
	NSString *bidPayload = (NSString *)info[@"adm"];
	CGFloat height = [(NSString *)info[@"height"] floatValue];
	CGSize adSize = CGSizeMake(-1, height);

	// TODO nicole validate adSize against FBAdSize

	// Load FBAdView using reflection so we can load the ad properly in the FBAudienceNetwork SDK
	Class fbAdViewClass = NSClassFromString(@"FBAdView");
	#pragma clang diagnostic push
	#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (fbAdViewClass != nil) {
        SEL initMethodSel = NSSelectorFromString(@"initWithPlacementID:adSize:rootViewController:");
        id fbAdViewObj = [fbAdViewClass alloc];
        if ([fbAdViewObj respondsToSelector:initMethodSel]) {
            NSMethodSignature *methSig = [fbAdViewObj methodSignatureForSelector:initMethodSel];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methSig];

            [invocation setSelector:initMethodSel];
            [invocation setTarget:fbAdViewObj];

            // Set arguments for init method
            NSString *placementId = [self parsePlacementIdFromBidPayload:bidPayload];
            struct FBAdSize fbAdSize;
            fbAdSize.size = adSize;
            UIViewController *vc = (UIViewController *)[NSObject new];

            [invocation setArgument:&placementId atIndex:2];
            [invocation setArgument:&fbAdSize atIndex:3];
            [invocation setArgument:&vc atIndex:4];

            // Invoke init method and use temp result to avoid crash later
            [invocation invoke];
            id __unsafe_unretained tempResultSet;
            [invocation getReturnValue: &tempResultSet];
            id result = tempResultSet;

            // Set selector variables for other methods we need to call on FBAdView
            SEL setDelegateSel = NSSelectorFromString(kFBSetDelegateSelName);
            SEL loadAdSel = NSSelectorFromString(kFBLoadAdWithBidPayloadSelName);
            SEL disableAutoRefreshSel = NSSelectorFromString(@"disableAutoRefresh");

            if ([result respondsToSelector:setDelegateSel] &&
                [result respondsToSelector:loadAdSel] &&
                [result respondsToSelector:disableAutoRefreshSel]) {
                    // Set up FBAdView and loadAdWithBidPayload
                    [result performSelector:setDelegateSel withObject:self];
                    [result performSelector:disableAutoRefreshSel];
                    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                    UIView *topView = window.rootViewController.view;
                    //[topView addSubview:result];
                    [result performSelector:loadAdSel withObject:bidPayload];
            }
            self.adView = result;
        }
    }
    #pragma clang diagnostic pop
}

- (NSString *)parsePlacementIdFromBidPayload:(NSString *)bidPayload {
    NSError *jsonError;
	NSData *objectData = [bidPayload dataUsingEncoding:NSUTF8StringEncoding];
	NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];
	return [json objectForKey:@"placement_id"];
}

#pragma mark FBAdViewDelegate methods
- (void)adView:(UIView *)adView didFailWithError:(NSError *)error {
	NSLog(@"Facebook mediated ad failed to load with error: %@", error);
	[self.delegate ad:adView didFailWithError:error];
}

- (void)adViewDidLoad:(UIView *)adView {
	[adView setFrame:CGRectMake(0, 10, 300, 250)];
	[self.delegate didLoadAd:adView];
	adView = nil;
}

- (void)adViewWillLogImpression:(UIView *)adView {
	NSLog(@"Facebook mediated ad will log impression.");
}

- (void)adViewDidClick:(UIView *)adView {
	NSLog(@"Facebook mediated ad did click.");
	[self.delegate didClickAd:adView];
}

- (void)adViewDidFinishHandlingClick:(UIView *)adView {
    NSLog(@"Facebook mediated ad did finish handling click.");
}

- (UIViewController *)viewControllerForPresentingModalView {
	return [self.delegate viewControllerForPresentingModalView];
}

@end
