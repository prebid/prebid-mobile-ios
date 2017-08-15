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

#import "PrebidMobileDFPMediationAdapter.h"

struct FBAdSize {
    CGSize size;
};

static NSString *const customEventErrorDomain = @"org.prebid.PrebidMobileMediationAdapter";
static NSString *const kPrebidCacheEndpoint = @"https://prebid.adnxs.com/pbc/v1/get?uuid=";

@interface PrebidMobileDFPMediationAdapter()

@property (strong, nonatomic) NSString *cacheId;
@property (strong, nonatomic) NSString *bidder;

@end

@implementation PrebidMobileDFPMediationAdapter

@synthesize delegate;

- (void)requestBannerAd:(GADAdSize)adSize
              parameter:(NSString *)serverParameter
                  label:(NSString *)serverLabel
                request:(GADCustomEventRequest *)request {
    NSArray *keywords = request.userKeywords;
    for (NSString *keyword in keywords) {
        if ([keyword containsString:@"hb_cache_id"]) {
            NSArray *splitValue = [keyword componentsSeparatedByString:@":"];
            self.cacheId = splitValue[1];
        }
        if ([keyword containsString:@"hb_bidder"]) {
            NSArray *splitValue = [keyword componentsSeparatedByString:@":"];
            self.bidder = splitValue[1];
            // TODO nicole remove override
            self.bidder = @"audienceNetwork";
        }
    }
    [self requestAdmAndLoadAd];
}

- (void)requestAdmAndLoadAd {
    // TODO nicole add back in
    NSString *cacheURL = [kPrebidCacheEndpoint stringByAppendingString:self.cacheId];

    NSMutableURLRequest *cacheRequest = [[NSMutableURLRequest alloc] init];
    [cacheRequest setHTTPMethod:@"GET"];
    [cacheRequest setURL:[NSURL URLWithString:cacheURL]];

    NSURLSession *session = [NSURLSession sharedSession];

    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:cacheRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            NSError *parseError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            //TODO nicole switch out real code
            //[self loadAd:responseDictionary];
            NSLog(@"The response is - %@",responseDictionary);
        } else {
            NSLog(@"ERROR");
        }
    }];
    [dataTask resume];
    // TODO nicole remove below code
    [self loadAd:@{}];
}

- (NSString *)parsePlacementIdFromBidPayload:(NSString *)bidPayload {
    NSError *jsonError;
    NSData *objectData = [bidPayload dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];
    return [json objectForKey:@"placement_id"];
}

- (void)loadAd:(NSDictionary *)responseDict {
    // TODO nicole remove bid payload override
    NSString *bidPayload = @"{\"type\":\"ID\",\"bid_id\":\"4401013946958491377\",\"placement_id\":\"1995257847363113_1997038003851764\",\"sdk_version\":\"4.25.0-appnexus.bidding\",\"device_id\":\"87ECBA49-908A-428F-9DE7-4B9CED4F486C\",\"template\":7,\"payload\":\"null\"}";
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([self.bidder isEqualToString:@"audienceNetwork"]) {
        // TODO nicole add this back in
        //NSString *bidPayload = (NSString *)responseDict[@"adm"];
        //CGFloat width = [(NSString *)responseDict[@"width"] floatValue];
        //CGFloat height = [(NSString *)responseDict[@"height"] floatValue];
        //CGSize adSize = CGSizeMake(width, height);

        // TODO nicole validate adSize against FBAdSize

        // Load FBAdView using reflection so we can load the ad properly in the FBAudienceNetwork SDK
        Class fbAdViewClass = NSClassFromString(@"FBAdView");
        SEL initMethodSel = NSSelectorFromString(@"initWithPlacementID:adSize:rootViewController:");
        id fbAdViewObj = [fbAdViewClass alloc];
        NSMethodSignature *methSig = [fbAdViewObj methodSignatureForSelector:initMethodSel];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methSig];

        [invocation setSelector:initMethodSel];
        [invocation setTarget:fbAdViewObj];

        // Set arguments for init method
        NSString *placementId = [self parsePlacementIdFromBidPayload:bidPayload];
        struct FBAdSize fbAdSize;
        fbAdSize.size = CGSizeMake(-1, 250);
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
        SEL setDelegateSel = NSSelectorFromString(@"setDelegate:");
        SEL loadAdSel = NSSelectorFromString(@"loadAdWithBidPayload:");
        SEL disableAutoRefreshSel = NSSelectorFromString(@"disableAutoRefresh");

        // Set up FBAdView and loadAdWithBidPayload
        [result performSelector:setDelegateSel withObject:self];
        [result performSelector:disableAutoRefreshSel];
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        UIView *topView = window.rootViewController.view;
        [topView addSubview:result];
        [result performSelector:loadAdSel withObject:bidPayload];
    } else {
            
    }
#pragma clang diagnostic pop
}

#pragma mark FBAdViewDelegate methods
- (void)adView:(UIView *)adView didFailWithError:(NSError *)error {
    NSLog(@"Facebook mediated ad failed to load with error: %@", error);
    [self.delegate customEventBanner:self didFailAd:error];
}

- (void)adViewDidLoad:(UIView *)adView {
    NSLog(@"Ad was loaded and ready to be displayed22");
    NSLog(@"Facebook mediated ad did load.");
    [adView setFrame:CGRectMake(0, 10, 300, 250)];
    [self.delegate customEventBanner:self didReceiveAd:adView];
    adView = nil;
}

- (void)adViewWillLogImpression:(UIView *)adView {
    NSLog(@"Facebook mediated ad will log impression.");
}

- (void)adViewDidClick:(UIView *)adView {
    NSLog(@"Facebook mediated ad did click.");
    [self.delegate customEventBannerWasClicked:self];
}

- (void)adViewDidFinishHandlingClick:(UIView *)adView {
    NSLog(@"Facebook mediated ad did finish handling click.");
}

- (UIViewController *)viewControllerForPresentingModalView {
    return [self.delegate viewControllerForPresentingModalView];
}

@end
