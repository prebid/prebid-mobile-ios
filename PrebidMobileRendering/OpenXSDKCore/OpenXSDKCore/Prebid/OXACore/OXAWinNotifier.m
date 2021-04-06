//
//  OXAWinNotifier.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXAWinNotifier.h"
#import "OXAWinNotifier+Private.h"

#import "OXABid.h"
#import "OXABid+Internal.h"
#import "OXAORTBMacrosHelper.h"
#import "OXMFunctions+Private.h"
#import "OXMServerConnectionProtocol.h"
#import "OXMServerResponse.h"

@implementation OXAWinNotifier

+ (void)notifyThroughConnection:(id<OXMServerConnectionProtocol>)connection
                     winningBid:(OXABid *)bid
                       callback:(OXAAdMarkupStringHandler)adMarkupConsumer
{
    OXAORTBMacrosHelper * const macrosHelper = [[OXAORTBMacrosHelper alloc] initWithBid:bid.bid];
    
    OXAAdMarkupStringHandler (^ const chainNotificationAction)(NSString * _Nullable, OXAAdMarkupStringHandler) =
    ^(NSString * _Nullable notificationUrl, OXAAdMarkupStringHandler _Nonnull onResult) {
        if (notificationUrl == nil) {
            return onResult;
        }
        return ^(NSString * _Nullable adMarkup) {
            if (adMarkup != nil) {
                // markup already known -- report to chained callbacks and send notification in parallel
                onResult(adMarkup);
                [connection download:notificationUrl callback:^(OXMServerResponse * response) { /* nop */ }];
            } else {
                // markup not yet known -- get a single response
                [connection download:notificationUrl callback:^(OXMServerResponse * _Nonnull response) {
                    NSString *adMarkupFromResponse = nil;
                    if (response.error == nil && response.rawData != nil) {
                        NSString * const rawResponseString = [[NSString alloc] initWithData:response.rawData
                                                                                   encoding:NSUTF8StringEncoding];

                        NSString * const rawAdMarkupString = [OXAWinNotifier adMarkupStringFromResponse:rawResponseString];
                        // replace macros in received markup
                        adMarkupFromResponse = [macrosHelper replaceMacrosInString:rawAdMarkupString];
                    }
                    // pass the markup down the chain
                    onResult(adMarkupFromResponse);
                }];
            }
        };
    };
    
    NSString * const uuidUrl = [OXAWinNotifier cacheUrlFromTargeting:bid.targetingInfo idKey:@"hb_uuid"];
    NSString * const cacheUrl = [OXAWinNotifier cacheUrlFromTargeting:bid.targetingInfo idKey:@"hb_cache_id"];
    
    OXAAdMarkupStringHandler chainedNotifications = adMarkupConsumer;
    chainedNotifications = chainNotificationAction(bid.nurl, chainedNotifications);
    chainedNotifications = chainNotificationAction(uuidUrl, chainedNotifications);
    chainedNotifications = chainNotificationAction(cacheUrl, chainedNotifications);
    
    chainedNotifications(bid.adm); // launch chained events
}

+ (OXAWinNotifierBlock)winNotifierBlockWithConnection:(id<OXMServerConnectionProtocol>)connection {
    return ^(OXABid *bid, OXAAdMarkupStringHandler adMarkupConsumer) {
        [OXAWinNotifier notifyThroughConnection:connection winningBid:bid callback:adMarkupConsumer];
    };
}

+ (OXAWinNotifierFactoryBlock)factoryBlock {
    return ^OXAWinNotifierBlock (id<OXMServerConnectionProtocol> connection) {
        return [OXAWinNotifier winNotifierBlockWithConnection:connection];
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
    OXMJsonDictionary * const jsonResponse = [OXMFunctions dictionaryFromJSONString:rawResponseString error:nil];
    return jsonResponse ? jsonResponse[@"adm"] : rawResponseString;
}

@end
