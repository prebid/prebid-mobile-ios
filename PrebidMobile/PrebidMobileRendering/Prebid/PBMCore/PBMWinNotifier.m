/*   Copyright 2018-2021 Prebid.org, Inc.

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

#import "PBMWinNotifier.h"
#import "PBMWinNotifier+Private.h"

#import "PBMORTBMacrosHelper.h"
#import "PBMFunctions+Private.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

@implementation PBMWinNotifier

+ (void)notifyThroughConnection:(id<PrebidServerConnectionProtocol>)connection
                     winningBid:(Bid *)bid
                       callback:(PBMAdMarkupStringHandler)adMarkupConsumer
{
    PBMORTBMacrosHelper * const macrosHelper = [[PBMORTBMacrosHelper alloc] initWithBid:bid.bid];
    
    PBMAdMarkupStringHandler (^ const chainNotificationAction)(NSString * _Nullable, PBMAdMarkupStringHandler) =
    ^(NSString * _Nullable notificationUrl, PBMAdMarkupStringHandler _Nonnull onResult) {
        if (notificationUrl == nil) {
            return onResult;
        }
        return ^(NSString * _Nullable adMarkup) {
            if (adMarkup != nil) {
                // markup already known -- report to chained callbacks and send notification in parallel
                onResult(adMarkup);
                [connection download:notificationUrl callback:^(PrebidServerResponse * response) { /* nop */ }];
            } else {
                // markup not yet known -- get a single response
                [connection download:notificationUrl callback:^(PrebidServerResponse * _Nonnull response) {
                    NSString *adMarkupFromResponse = nil;
                    if (response.error == nil && response.rawData != nil) {
                        NSString * const rawResponseString = [[NSString alloc] initWithData:response.rawData
                                                                                   encoding:NSUTF8StringEncoding];

                        NSString * const rawAdMarkupString = [PBMWinNotifier adMarkupStringFromResponse:rawResponseString];
                        // replace macros in received markup
                        adMarkupFromResponse = [macrosHelper replaceMacrosInString:rawAdMarkupString];
                    }
                    // pass the markup down the chain
                    onResult(adMarkupFromResponse);
                }];
            }
        };
    };
    
    NSString * const uuidUrl = [PBMWinNotifier cacheUrlFromTargeting:bid.targetingInfo idKey:@"hb_uuid"];
    NSString * const cacheUrl = [PBMWinNotifier cacheUrlFromTargeting:bid.targetingInfo idKey:@"hb_cache_id"];
    
    PBMAdMarkupStringHandler chainedNotifications = adMarkupConsumer;
    chainedNotifications = chainNotificationAction(bid.nurl, chainedNotifications);
    chainedNotifications = chainNotificationAction(uuidUrl, chainedNotifications);
    chainedNotifications = chainNotificationAction(cacheUrl, chainedNotifications);
    chainedNotifications(bid.adm); // launch chained events
}

+ (PBMWinNotifierBlock)winNotifierBlockWithConnection:(id<PrebidServerConnectionProtocol>)connection {
    return ^(Bid *bid, PBMAdMarkupStringHandler adMarkupConsumer) {
        [PBMWinNotifier notifyThroughConnection:connection winningBid:bid callback:adMarkupConsumer];
    };
}

+ (PBMWinNotifierFactoryBlock)factoryBlock {
    return ^PBMWinNotifierBlock (id<PrebidServerConnectionProtocol> connection) {
        return [PBMWinNotifier winNotifierBlockWithConnection:connection];
    };
}

// MARK: - Private

+ (nullable NSString *)cacheUrlFromTargeting:(NSDictionary<NSString *, NSString *> *)targeting idKey:(NSString *)idKey{
    NSString * const host = targeting[@"hb_cache_host"];
    NSString * const path = targeting[@"hb_cache_path"];
    NSString * const uuid = targeting[idKey];
    if (!(host != nil && path != nil && uuid != nil)) {
        return nil;
    }
    return [NSString stringWithFormat:@"https://%@%@?uuid=%@", host, path, uuid];
}

/**
 Extracts ad markup from a cached response
 https://github.com/prebid/prebid-server/blob/994d0f06100f4ef872226112e58e1ad9075cd844/openrtb_ext/bid.go#L133
 NOTE: `hb_cache_id` will fetch the entire bid JSON, while `hb_uuid` will fetch just the VAST XML.
 */
+ (NSString *)adMarkupStringFromResponse:(NSString *)rawResponseString {
    PBMJsonDictionary * const jsonResponse = [PBMFunctions dictionaryFromJSONString:rawResponseString error:nil];
    return jsonResponse ? jsonResponse[@"adm"] : rawResponseString;
}

@end
