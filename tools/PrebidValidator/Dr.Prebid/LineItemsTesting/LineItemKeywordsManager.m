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
#import <PrebidMobile/PrebidCache.h>

NSString * const KeywordsManagerPriceKey = @"hb_pb";
NSString * const KeywordsManagerCacheIdKey = @"hb_cache_id";
NSString * const KeywordsManagerSizeKey = @"hb_size";
NSString * const KeywordsManagerCacheEndPoint = @"https://prebid.adnxs.com/pbc/v1/cache";
CGFloat const KeywordsManagerPriceFiftyCentsRange = 0.50f; // round to this for now, should be rounded according to setup
NSString *const KeywordsManagerCreative300x250 = @"{\"id\":\"7438652069000399098\",\"impid\":\"Home\",\"price\":0.5,\"adm\":\"<script type=\\\"text\/javascript\\\">document.write('<a href=\\\"http:\/\/prebid.org\\\" target=\\\"_blank\\\"><img width=\\\"300\\\" height=\\\"250\\\" style=\\\"border-style: none\\\" src=\\\"https:\/\/vcdn.adnxs.com\/p\/creative-image\/e3\/59\/55\/3f\/e359553f-7356-4f5c-8644-cea6517430c7.jpg\\\"\/><\/a>');<\/script>\",\"adid\":\"29681110\",\"adomain\":[\"appnexus.com\"],\"iurl\":\"https:\/\/nym1-ib.adnxs.com\/cr?id=29681110\",\"cid\":\"958\",\"crid\":\"29681110\",\"w\":300,\"h\":250}";

NSString *const KeywordsManagerCreative320x480 = @"{\"id\":\"7438652069000399098\",\"impid\":\"Home\",\"price\":0.5,\"adm\":\"<script type=\\\"text\/javascript\\\">document.write('<a href=\\\"http:\/\/prebid.org\\\" target=\\\"_blank\\\"><img width=\\\"320\\\" height=\\\"480\\\" style=\\\"border-style: none\\\" src=\\\"https:\/\/vcdn.adnxs.com\/p\/creative-image\/bd\/95\/05\/da\/bd9505da-d89f-445f-896c-915f89a1c01a.jpg\\\"\/><\/a>');<\/script>\",\"adid\":\"29681110\",\"adomain\":[\"appnexus.com\"],\"iurl\":\"https:\/\/nym1-ib.adnxs.com\/cr?id=29681110\",\"cid\":\"958\",\"crid\":\"29681110\",\"w\":320,\"h\":480}";

NSString *const KeywordsManagerCreative320x50 = @"{\"id\":\"7438652069000399098\",\"impid\":\"Home\",\"price\":0.5,\"adm\":\"<script type=\\\"text\/javascript\\\">document.write('<a href=\\\"http:\/\/prebid.org\\\" target=\\\"_blank\\\"><img width=\\\"320\\\" height=\\\"50\\\" style=\\\"border-style: none\\\" src=\\\"https:\/\/vcdn.adnxs.com\/p\/creative-image\/73\/c7\/0d\/f5\/73c70df5-d450-4832-9894-fe88e868a67c.jpg\\\"\/><\/a>');<\/script>\",\"adid\":\"29681110\",\"adomain\":[\"appnexus.com\"],\"iurl\":\"https:\/\/nym1-ib.adnxs.com\/cr?id=29681110\",\"cid\":\"958\",\"crid\":\"29681110\",\"w\":320,\"h\":50}";

NSString *const KeywordsManagerFakeCacheId = @"FakeCacheId_ShouldNotAffectTest";

@interface LineItemKeywordsManager()
@property NSDictionary *sizeToCacheIdFromServer;
@end

@implementation LineItemKeywordsManager

+(id)sharedManager
{
    static LineItemKeywordsManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
        // cache response once for the entire app life cycle since we don't consider impression tracking for testing
        NSData *size300x250 = [KeywordsManagerCreative300x250 dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *size300x250json = [NSJSONSerialization JSONObjectWithData:size300x250 options:0 error:nil];
        NSMutableDictionary *content300x250 = [[NSMutableDictionary alloc]init];
        content300x250[@"type"] = @"json";
        content300x250[@"value"] = size300x250json;
        NSData *size320x480 = [KeywordsManagerCreative320x480 dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *size320x480json = [NSJSONSerialization JSONObjectWithData:size320x480 options:0 error:nil];
        NSMutableDictionary *content320x480 = [[NSMutableDictionary alloc]init];
        content320x480[@"type"] = @"json";
        content320x480[@"value"] = size320x480json;
        NSData *size320x50 = [KeywordsManagerCreative320x50 dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *size320x50json = [NSJSONSerialization JSONObjectWithData:size320x50 options:0 error:nil];
        NSMutableDictionary *content320x50 = [[NSMutableDictionary alloc]init];
        content320x50[@"type"] = @"json";
        content320x50[@"value"] = size320x50json;
        NSArray *puts = @[content300x250, content320x480, content320x50];
        NSDictionary *postDict  = [NSDictionary dictionaryWithObject:puts forKey:@"puts"];
        NSURL *url = [[NSURL alloc]initWithString:KeywordsManagerCacheEndPoint];
        NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:url
                                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                       timeoutInterval:1000];
        [mutableRequest setHTTPMethod:@"POST"];
        NSData *postData = [NSJSONSerialization dataWithJSONObject:postDict
                                                           options:kNilOptions
                                                             error:nil];
        [mutableRequest setHTTPBody:postData];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *cacheIdTask = [session dataTaskWithRequest:mutableRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error) {
                NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSArray *uuids = response[@"responses"];
                sharedManager.sizeToCacheIdFromServer = [[NSMutableDictionary alloc]init];
                [sharedManager.sizeToCacheIdFromServer setValue:uuids[0][@"uuid"] forKey:@"300x250"];
                [sharedManager.sizeToCacheIdFromServer setValue:uuids[1][@"uuid"] forKey:@"320x480"];
                [sharedManager.sizeToCacheIdFromServer setValue:uuids[2][@"uuid"] forKey:@"320x50"];
            }
        }];
        [cacheIdTask resume];
        
        
    });
    return sharedManager;
}

- (NSDictionary<NSString *, NSString *> *)keywordsWithBidPrice:(NSString *)bidPrice forSize:(NSString *)sizeString usingLocalCache:(BOOL) useLocalCache {
    NSMutableDictionary *keywords = [[NSMutableDictionary alloc] init];
    if (useLocalCache) {
        NSData *webData;
        if ([sizeString isEqualToString:@"300x250"]) {
            webData = [KeywordsManagerCreative300x250 dataUsingEncoding:NSUTF8StringEncoding];
        } else if ([sizeString isEqualToString:@"320x480"]){
            webData = [KeywordsManagerCreative320x480 dataUsingEncoding:NSUTF8StringEncoding];
        } else {
            webData = [KeywordsManagerCreative320x50 dataUsingEncoding:NSUTF8StringEncoding];
        }
        NSError *error;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:webData options:0 error:&error];
        NSString *cacheId = [[NSUUID UUID] UUIDString];
        [[PrebidCache globalCache] setObject:jsonDict forKey:cacheId];
        keywords[KeywordsManagerCacheIdKey] = cacheId;
    } else {
        if (self.sizeToCacheIdFromServer) {
            keywords[KeywordsManagerCacheIdKey] = self.sizeToCacheIdFromServer[sizeString];
        } else {
            keywords[KeywordsManagerCacheIdKey] = KeywordsManagerFakeCacheId;
        }
    }
    keywords[KeywordsManagerPriceKey] =  bidPrice;
    keywords[KeywordsManagerSizeKey] = sizeString;
    return [keywords copy];
}

@end
