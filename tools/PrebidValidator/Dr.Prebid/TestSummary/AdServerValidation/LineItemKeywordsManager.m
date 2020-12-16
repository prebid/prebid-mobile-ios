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

#import "LineItemKeywordsManager.h"
#import "PBVSharedConstants.h"

NSString * const KeywordsManagerPriceKey = @"hb_pb";
NSString * const KeywordsManagerCacheIdKey = @"hb_cache_id";
NSString * const KeywordsManagerSizeKey = @"hb_size";
NSString * const AppNexusHostedCacheEndPoint = @"https://prebid.adnxs.com/pbc/v1/cache";
NSString * const RubiconHostedCacheEndPoint = @"https://prebid-server.rubiconproject.com/cache";
CGFloat const KeywordsManagerPriceFiftyCentsRange = 0.50f; // round to this for now, should be rounded according to setup
NSString *const KeywordsManagerCreative300x250 = @"{\"id\":\"7438652069000399098\",\"impid\":\"Home\",\"price\":0.5,\"adm\":\"<script type=\\\"text\/javascript\\\">document.write('<a href=\\\"http:\/\/prebid.org\\\" target=\\\"_blank\\\"><img width=\\\"300\\\" height=\\\"250\\\" style=\\\"border-style: none\\\" src=\\\"https:\/\/vcdn.adnxs.com\/p\/creative-image\/27\/c0\/52\/67\/27c05267-5a6d-4874-834e-18e218493c32.png\\\"\/><\/a>');<\/script>\",\"adid\":\"29681110\",\"adomain\":[\"appnexus.com\"],\"iurl\":\"https:\/\/nym1-ib.adnxs.com\/cr?id=29681110\",\"cid\":\"958\",\"crid\":\"29681110\",\"w\":300,\"h\":250}";

NSString *const KeywordsManagerCreative300x600 = @"{\"id\":\"7438652069000399098\",\"impid\":\"Home\",\"price\":0.5,\"adm\":\"<script type=\\\"text\/javascript\\\">document.write('<a href=\\\"http:\/\/prebid.org\\\" target=\\\"_blank\\\"><img width=\\\"300\\\" height=\\\"600\\\" style=\\\"border-style: none\\\" src=\\\"https:\/\/vcdn.adnxs.com\/p\/creative-image\/79\/0f\/47\/8f\/790f478f-7de1-4472-9496-d21182055f90.png\\\"\/><\/a>');<\/script>\",\"adid\":\"29681110\",\"adomain\":[\"appnexus.com\"],\"iurl\":\"https:\/\/nym1-ib.adnxs.com\/cr?id=29681110\",\"cid\":\"958\",\"crid\":\"29681110\",\"w\":300,\"h\":600}";

NSString *const KeywordsManagerCreative320x50 = @"{\"id\":\"7438652069000399098\",\"impid\":\"Home\",\"price\":0.5,\"adm\":\"<script type=\\\"text\/javascript\\\">document.write('<a href=\\\"http:\/\/prebid.org\\\" target=\\\"_blank\\\"><img width=\\\"320\\\" height=\\\"50\\\" style=\\\"border-style: none\\\" src=\\\"https:\/\/vcdn.adnxs.com\/p\/creative-image\/ab\/0f\/23\/7f\/ab0f237f-634c-4012-8c3b-6638da2d6982.png\\\"\/><\/a>');<\/script>\",\"adid\":\"29681110\",\"adomain\":[\"appnexus.com\"],\"iurl\":\"https:\/\/nym1-ib.adnxs.com\/cr?id=29681110\",\"cid\":\"958\",\"crid\":\"29681110\",\"w\":320,\"h\":50}";

NSString *const KeywordsManagerCreative320x100 = @"{\"id\":\"7438652069000399098\",\"impid\":\"Home\",\"price\":0.5,\"adm\":\"<script type=\\\"text\/javascript\\\">document.write('<a href=\\\"http:\/\/prebid.org\\\" target=\\\"_blank\\\"><img width=\\\"320\\\" height=\\\"100\\\" style=\\\"border-style: none\\\" src=\\\"https:\/\/vcdn.adnxs.com\/p\/creative-image\/a2\/96\/f9\/1c\/a296f91c-3d9f-4c44-a27f-2e1722ed6f82.png\\\"\/><\/a>');<\/script>\",\"adid\":\"29681110\",\"adomain\":[\"appnexus.com\"],\"iurl\":\"https:\/\/nym1-ib.adnxs.com\/cr?id=29681110\",\"cid\":\"958\",\"crid\":\"29681110\",\"w\":320,\"h\":100}";

NSString *const KeywordsManagerCreative320x480 = @"{\"id\":\"7438652069000399098\",\"impid\":\"Home\",\"price\":0.5,\"adm\":\"<script type=\\\"text\/javascript\\\">document.write('<a href=\\\"http:\/\/prebid.org\\\" target=\\\"_blank\\\"><img width=\\\"320\\\" height=\\\"480\\\" style=\\\"border-style: none\\\" src=\\\"https:\/\/vcdn.adnxs.com\/p\/creative-image\/d4\/46\/18\/cd\/d44618cd-8d0a-44d5-b255-60283551774e.png\\\"\/><\/a>');<\/script>\",\"adid\":\"29681110\",\"adomain\":[\"appnexus.com\"],\"iurl\":\"https:\/\/nym1-ib.adnxs.com\/cr?id=29681110\",\"cid\":\"958\",\"crid\":\"29681110\",\"w\":320,\"h\":480}";

NSString *const KeywordsManagerCreative728x90 = @"{\"id\":\"7438652069000399098\",\"impid\":\"Home\",\"price\":0.5,\"adm\":\"<script type=\\\"text\/javascript\\\">document.write('<a href=\\\"http:\/\/prebid.org\\\" target=\\\"_blank\\\"><img width=\\\"728\\\" height=\\\"90\\\" style=\\\"border-style: none\\\" src=\\\"https:\/\/vcdn.adnxs.com\/p\/creative-image\/f6\/11\/33\/19\/f6113319-e789-4408-b69d-b178d60c5a6e.png\\\"\/><\/a>');<\/script>\",\"adid\":\"29681110\",\"adomain\":[\"appnexus.com\"],\"iurl\":\"https:\/\/nym1-ib.adnxs.com\/cr?id=29681110\",\"cid\":\"958\",\"crid\":\"29681110\",\"w\":728,\"h\":90}";



NSString *const KeywordsManagerFakeCacheId = @"FakeCacheId_ShouldNotAffectTest";

@interface LineItemKeywordsManager()
@property NSDictionary *sizeToCacheIdFromAppNexusServer;
@property NSDictionary *sizeToCacheIdFromRubiconServer;

@end

@implementation LineItemKeywordsManager

+(id)sharedManager
{
    static LineItemKeywordsManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)refreshCacheIds
{
    // cache response once for the entire app life cycle since we don't consider impression tracking for testing
    // create json for size 300x250 creative
    NSData *size300x250 = [KeywordsManagerCreative300x250 dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *size300x250json = [NSJSONSerialization JSONObjectWithData:size300x250 options:0 error:nil];
    NSMutableDictionary *content300x250 = [[NSMutableDictionary alloc]init];
    content300x250[@"type"] = @"json";
    content300x250[@"value"] = size300x250json;
    // create json for size 300x600 creative
    NSData *size300x600 = [KeywordsManagerCreative300x600 dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *size300x600json = [NSJSONSerialization JSONObjectWithData:size300x600 options:0 error:nil];
    NSMutableDictionary *content300x600 = [[NSMutableDictionary alloc]init];
    content300x600[@"type"] = @"json";
    content300x600[@"value"] = size300x600json;
    // create json for size 320x50 creative
    NSData *size320x50 = [KeywordsManagerCreative320x50 dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *size320x50json = [NSJSONSerialization JSONObjectWithData:size320x50 options:0 error:nil];
    NSMutableDictionary *content320x50 = [[NSMutableDictionary alloc]init];
    content320x50[@"type"] = @"json";
    content320x50[@"value"] = size320x50json;
    // create json for size 320x100 creative
    NSData *size320x100 = [KeywordsManagerCreative320x100 dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *size320x100json = [NSJSONSerialization JSONObjectWithData:size320x100 options:0 error:nil];
    NSMutableDictionary *content320x100 = [[NSMutableDictionary alloc]init];
    content320x100[@"type"] = @"json";
    content320x100[@"value"] = size320x100json;
    // create json for size 320x480 creative
    NSData *size320x480 = [KeywordsManagerCreative320x480 dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *size320x480json = [NSJSONSerialization JSONObjectWithData:size320x480 options:0 error:nil];
    NSMutableDictionary *content320x480 = [[NSMutableDictionary alloc]init];
    content320x480[@"type"] = @"json";
    content320x480[@"value"] = size320x480json;
    // create json for size 728x90 creative
    NSData *size728x90 = [KeywordsManagerCreative728x90 dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *size728x90json = [NSJSONSerialization JSONObjectWithData:size728x90 options:0 error:nil];
    NSMutableDictionary *content728x90 = [[NSMutableDictionary alloc]init];
    content728x90[@"type"] = @"json";
    content728x90[@"value"] = size728x90json;
    // combine into one json
    NSArray *puts = @[content300x250,content300x600, content320x50, content320x100, content320x480, content728x90];
    NSDictionary *postDict  = [NSDictionary dictionaryWithObject:puts forKey:@"puts"];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDict
                                                       options:kNilOptions
                                                         error:nil];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [[NSURL alloc]initWithString:AppNexusHostedCacheEndPoint];
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:url
                                                                       cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                   timeoutInterval:1000];
    [mutableRequest setHTTPMethod:@"POST"];
    [mutableRequest setHTTPBody:postData];
    NSURLSessionDataTask *cacheIdTask = [session dataTaskWithRequest:mutableRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSError *jsonError;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (!jsonError) {
                NSArray *uuids = response[@"responses"];
                self.sizeToCacheIdFromAppNexusServer = [[NSMutableDictionary alloc]init];
                [self.sizeToCacheIdFromAppNexusServer setValue:uuids[0][@"uuid"] forKey:kSizeString300x250];
                [self.sizeToCacheIdFromAppNexusServer setValue:uuids[1][@"uuid"] forKey:kSizeString300x600];
                [self.sizeToCacheIdFromAppNexusServer setValue:uuids[2][@"uuid"] forKey:kSizeString320x50];
                [self.sizeToCacheIdFromAppNexusServer setValue:uuids[3][@"uuid"] forKey:kSizeString320x100];
                [self.sizeToCacheIdFromAppNexusServer setValue:uuids[4][@"uuid"] forKey:kSizeString320x480];
                [self.sizeToCacheIdFromAppNexusServer setValue:uuids[5][@"uuid"] forKey:kSizeString728x90];
            }
        }
    }];
    [cacheIdTask resume];
    NSURL *urlRubicon = [[NSURL alloc]initWithString:RubiconHostedCacheEndPoint];
    NSMutableURLRequest *mutableRequestRubicon = [[NSMutableURLRequest alloc] initWithURL:urlRubicon
                                                                       cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                   timeoutInterval:1000];
    [mutableRequestRubicon setHTTPMethod:@"POST"];
    [mutableRequestRubicon setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [mutableRequestRubicon setHTTPBody:postData];
    NSURLSessionDataTask *cacheIdTask2 = [session dataTaskWithRequest:mutableRequestRubicon completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSError *jsonError;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (!jsonError) {
                NSArray *uuids = response[@"responses"];
                self.sizeToCacheIdFromRubiconServer = [[NSMutableDictionary alloc]init];
                [self.sizeToCacheIdFromRubiconServer setValue:uuids[0][@"uuid"] forKey:kSizeString300x250];
                [self.sizeToCacheIdFromRubiconServer setValue:uuids[1][@"uuid"] forKey:kSizeString300x600];
                [self.sizeToCacheIdFromRubiconServer setValue:uuids[2][@"uuid"] forKey:kSizeString320x50];
                [self.sizeToCacheIdFromRubiconServer setValue:uuids[3][@"uuid"] forKey:kSizeString320x100];
                [self.sizeToCacheIdFromRubiconServer setValue:uuids[4][@"uuid"] forKey:kSizeString320x480];
                [self.sizeToCacheIdFromRubiconServer setValue:uuids[5][@"uuid"] forKey:kSizeString728x90];
            }
        }
    }];
    [cacheIdTask2 resume];
    // Prebid Cache expires every 4 minutes 30 seconds, refresh the bids here
    [NSTimer scheduledTimerWithTimeInterval:270 target:self selector:@selector(refreshCacheIds) userInfo:nil repeats:NO];
}

- (NSDictionary<NSString *, NSString *> *)keywordsWithBidPrice:(NSString *)bidPrice forSize:(NSString *)sizeString forHost:(NSString *) host{
    NSMutableDictionary *keywords = [[NSMutableDictionary alloc] init];
    if (host != nil && [host isEqualToString:kRubiconString]) {
        if (self.sizeToCacheIdFromRubiconServer) {
            if ([sizeString isEqualToString:@"Interstitial"]) {
                keywords[KeywordsManagerCacheIdKey] = self.sizeToCacheIdFromRubiconServer[kSizeString320x480];
            } else {
                keywords[KeywordsManagerCacheIdKey] = self.sizeToCacheIdFromRubiconServer[sizeString];
            }
        } else {
            keywords[KeywordsManagerCacheIdKey] = KeywordsManagerFakeCacheId;
        }
    } else {
        if (self.sizeToCacheIdFromAppNexusServer) {
            if ([sizeString isEqualToString:@"Interstitial"]) {
                keywords[KeywordsManagerCacheIdKey] = self.sizeToCacheIdFromAppNexusServer[kSizeString320x480];
            } else {
                keywords[KeywordsManagerCacheIdKey] = self.sizeToCacheIdFromAppNexusServer[sizeString];
            }
        } else {
            keywords[KeywordsManagerCacheIdKey] = KeywordsManagerFakeCacheId;
        }
    }
    keywords[KeywordsManagerPriceKey] =  bidPrice;
    if ([sizeString containsString:@"Interstitial"]) {
        keywords[KeywordsManagerSizeKey] = @"320x480";
    } else {
        keywords[KeywordsManagerSizeKey] = sizeString;
    }

    keywords[@"hb_env"] = @"mobile-app";
    return [keywords copy];
}

@end
