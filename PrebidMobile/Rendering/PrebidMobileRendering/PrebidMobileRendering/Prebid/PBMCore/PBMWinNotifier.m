//
//  PBMWinNotifier.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMWinNotifier.h"
#import "PBMWinNotifier+Private.h"

#import "PBMBid.h"
#import "PBMBid+Internal.h"
#import "PBMORTBMacrosHelper.h"
#import "PBMFunctions+Private.h"
#import "PBMServerConnectionProtocol.h"
#import "PBMServerResponse.h"

@implementation PBMWinNotifier

+ (void)notifyThroughConnection:(id<PBMServerConnectionProtocol>)connection
                     winningBid:(PBMBid *)bid
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
                [connection download:notificationUrl callback:^(PBMServerResponse * response) { /* nop */ }];
            } else {
                // markup not yet known -- get a single response
                [connection download:notificationUrl callback:^(PBMServerResponse * _Nonnull response) {
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

+ (PBMWinNotifierBlock)winNotifierBlockWithConnection:(id<PBMServerConnectionProtocol>)connection {
    return ^(PBMBid *bid, PBMAdMarkupStringHandler adMarkupConsumer) {
        [PBMWinNotifier notifyThroughConnection:connection winningBid:bid callback:adMarkupConsumer];
    };
}

+ (PBMWinNotifierFactoryBlock)factoryBlock {
    return ^PBMWinNotifierBlock (id<PBMServerConnectionProtocol> connection) {
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
