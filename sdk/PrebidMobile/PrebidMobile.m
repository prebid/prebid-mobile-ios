/*   Copyright 2017 Prebid.org, Inc.
 
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

#import "PrebidMobile.h"
#import "PrebidURLProtocol.h"

@implementation PrebidMobile

+ (void)registerAdUnits:(nonnull NSArray<PBAdUnit *> *)adUnits
          withAccountId:(nonnull NSString *)accountId {
    [[PBBidManager sharedInstance] registerAdUnits:adUnits withAccountId:accountId];
}

+ (void)registerAdUnits:(nonnull NSArray<PBAdUnit *> *)adUnits
          withAccountId:(nonnull NSString *)accountId
               withHost:(PBServerHost)host
     andPrimaryAdServer:(PBPrimaryAdServerType)adServer {
    [NSURLProtocol registerClass:[PrebidURLProtocol class]];
    [[PBBidManager sharedInstance] registerAdUnits:adUnits withAccountId:accountId withHost:host andPrimaryAdServer:adServer];
}

+ (void)setBidKeywordsOnAdObject:(nonnull id)adObject
                    withAdUnitId:(nonnull NSString *)adUnitId {
    PBLogDebug(@"Set bid keywords on ad object for ad unit %@", adUnitId);
    PBAdUnit *__nullable adUnit = [[PBBidManager sharedInstance] adUnitByIdentifier:adUnitId];
    [[PBBidManager sharedInstance] assertAdUnitRegistered:adUnitId];
    
    SEL setPbIdentifier = NSSelectorFromString(@"setPb_identifier:");
    if ([adObject respondsToSelector:setPbIdentifier]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [adObject performSelector:setPbIdentifier withObject:adUnit];
#pragma clang diagnostic pop
    }
}

+ (void)setBidKeywordsOnAdObject:(id)adObject
                    withAdUnitId:(NSString *)adUnitIdentifier
                     withTimeout:(int)timeoutInMilliseconds
               completionHandler:(void (^)(void))handler {
    void (^completionHandler)(void) = ^{
        [self setBidKeywordsOnAdObject:adObject withAdUnitId:adUnitIdentifier];
        handler();
    };
    [[PBBidManager sharedInstance] attachTopBidHelperForAdUnitId:adUnitIdentifier
                                                      andTimeout:timeoutInMilliseconds
                                               completionHandler:completionHandler];
}

@end
