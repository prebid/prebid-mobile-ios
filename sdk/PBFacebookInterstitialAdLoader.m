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

#import "PBFacebookInterstitialAdLoader.h"
#import "PBConstants.h"

@implementation PBFacebookInterstitialAdLoader

- (void)loadInterstitialAd:(NSDictionary *)info {
    // TODO nicole remove bid payload override
    NSString *bidPayload = @"{\"type\":\"ID\",\"bid_id\":\"4401013946958491377\",\"placement_id\":\"1995257847363113_1997038003851764\",\"sdk_version\":\"4.25.0-appnexus.bidding\",\"device_id\":\"87ECBA49-908A-428F-9DE7-4B9CED4F486C\",\"template\":7,\"payload\":\"null\"}";
    
    // TODO nicole add this back in
    //NSString *bidPayload = (NSString *)info[@"adm"];
    
    // Load FBInterstitialAd using reflection so we can load the ad properly in the FBAudienceNetwork SDK
    Class fbInterstitialAdClass = NSClassFromString(kFBInterstitialAdClassName);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (fbInterstitialAdClass != nil) {
        SEL initMethodSel = NSSelectorFromString(kFBInterstitialInitMethodSelName);
        id fbInterstitialAdObj = [fbInterstitialAdClass alloc];
        if ([fbInterstitialAdObj respondsToSelector:initMethodSel]) {
            NSString *placementId = [self parsePlacementIdFromBidPayload:bidPayload];
            [fbInterstitialAdObj performSelector:initMethodSel withObject:placementId];
            
            // Set selector variables for other methods we need to call on FBAdView
            SEL setDelegateSel = NSSelectorFromString(kFBSetDelegateSelName);
            SEL loadAdSel = NSSelectorFromString(kFBLoadAdWithBidPayloadSelName);
            
            if ([fbInterstitialAdObj respondsToSelector:setDelegateSel] &&
                [fbInterstitialAdObj respondsToSelector:loadAdSel]) {
                // Set up FBAdView and loadAdWithBidPayload
                [fbInterstitialAdObj performSelector:setDelegateSel withObject:self];
                [fbInterstitialAdObj performSelector:loadAdSel withObject:bidPayload];
            }
            self.interstitialAd = fbInterstitialAdObj;
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


#pragma mark FBInterstitialAdDelegate methods

- (void)interstitialAdDidLoad:(id)interstitialAd {
    //[self.interstitialAd showAdFromRootViewController:[[UIApplication sharedApplication] keyWindow].rootViewController];
    NSLog(@"fb interstitial ad did load");
    [self.delegate didLoadAd:interstitialAd];
}

- (void)interstitialAd:(id)interstitialAd didFailWithError:(NSError *)error {
    NSLog(@"fb interstitial ad did fail with error");
    [self.delegate ad:interstitialAd didFailWithError:error];
}

- (void)interstitialAdDidClick:(id)interstitialAd {
    NSLog(@"fb interstitial ad did click");
    [self.delegate didClickAd:interstitialAd];
}

@end
