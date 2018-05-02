#import "LineItemKeywordsManager.h"
#import <PrebidMobile/PrebidCache.h>

NSString * const KeywordsManagerPriceKey = @"hb_pb";
NSString * const KeywordsManagerCacheIdKey = @"hb_cache_id";
NSString * const KeywordsManagerSizeKey = @"hb_size";
NSString * const KeywordsManagerCacheEndPoint = @"https://prebid.adnxs.com/pbc/v1/cache";
CGFloat const KeywordsManagerPriceFiftyCentsRange = 0.50f; // round to this for now, should be rounded according to setup
NSString *const KeywordsManagerCreative300x250 = @"{\"id\":\"2016846452925826906\",\"impid\":\"Home\",\"price\":0.5,\"adm\":\"<script src=\\\"https:\/\/nym1-ib.adnxs.com\/ab?e=wqT_3QKDCKADBAAAAwDWAAUBCMnajdcFELvyus6-34mmWBiqvffUj9SulS4qNgkAAAECCOA_EQEHNAAA4D8ZAAAAgOtR4D8hERIAKREJADERG6AwleLdBDi-B0C-B0gCUMuWhiNYrdpEYABokUB4jN4EgAEBigEDVVNEkgUG8FKYAawCoAH6AagBAbABALgBAsABA8gBAtABAtgBGeABAfABAIoCO3VmKCdhJywgMTM5OTcwMCwgMTUyNDg1NDA4OSk7dWYoJ3InLCA3MzUwMTUxNTYeAPCNkgLtASFjakhFMVFpZS01SUhFTXVXaGlNWUFDQ3Qya1F3QURnQVFBUkl2Z2RRbGVMZEJGZ0FZTW9EYUFCd0RuaW9BNEFCRG9nQnFBT1FBUUdZQVFHZ0FRR29BUU93QVFDNUFTbUxpSU1BQU9BX3dRRXBpNGlEQUFEZ1A4a0JaaUVfTS1DUTlUX1pBUUFBQQEDJFBBXzRBRUE5UUUBDixBbUFJQW9BSUF0UUkFEAB2DQiId0FJQXlBSUE0QUlBNkFJQS1BSXlnQU1Fa0FNQW1BTUJxQU8F0GR1Z01KVGxsTk1qbzBNRE00mgItITlnZzFuZzbwAChyZHBFSUFRb0FEbzIwACjSAnc4MzY1ODQ0LAUIBDU4DQgAOQkIBDYxCQgANxEIDSgEODAFGAQ5MAkwCDkxMwkQADENEAQyMgkQADIJMAQ5MglQBDkzDShgMzfYAugH4ALH0wHyAhEKBkFEVl9JRBIHMSnkBRQIQ1BHBRQYMzU0NjYyNwEUCAVDUAET8OQIMTQ5OTA3NTCAAwGIAwGQAwCYAxSgAwGqAwDAA6wCyAMA0gMoCAASJDEwMzAwZDA5LWQ4Y2ItNDg5MC1iY2UxLTAwNDAyM2VlZGYyNNgDAOADAOgDAvgDAIAEAJIECS9vcGVucnRiMpgEAKIECzEwLjEuMTMuMTg4qAS80AWyBAwIABAAGAAgADAAOAC4BADABADIBADSBA05NTgjTllNMjo0MDM42gQCCAHgBADwBMuWhiOCBSJjb20uQXBwTmV4dXMuUHJlYmlkTW9iaWxlVmFsaWRhdG9yiAUBmAUAoAX_____BQS4AaoFJDA2QTQwRkYwLTcyMjctNEM5RC1BNTMzLTBCQjMwNDg1QzY4RMAFAMkFAAABAhTwP9IFCQkBCgEBVNgFAeAFAfAFAfoFBAgAEACQBgCYBgA.&s=86c1538731dbfd0c01ea6a59fe28a77bf9e74ccc&test=1&pp=${AUCTION_PRICE}\\\"><\/script>\",\"adid\":\"73501515\",\"adomain\":[\"appnexus.com\"],\"iurl\":\"https:\/\/nym1-ib.adnxs.com\/cr?id=73501515\",\"cid\":\"958\",\"crid\":\"73501515\",\"w\":300,\"h\":250}";

NSString *const KeywordsManagerCreative320x480 = @"{\"id\":\"0\",\"impid\":\"Home\",\"price\":0.5,\"adm\":\"    <script type=\\\"text\/javascript\\\">\\n      rubicon_cb = Math.random(); rubicon_rurl = document.referrer; if(top.location==document.location){rubicon_rurl = document.location;} rubicon_rurl = escape(rubicon_rurl);\\n      window.rubicon_ad = \\\"4020200\\\" + \\\".\\\" + \\\"js\\\";\\n      window.rubicon_creative = \\\"4378024\\\" + \\\".\\\" + \\\"js\\\";\\n    <\/script>\\n<div style=\\\"width: 0; height: 0; overflow: hidden;\\\"><img border=\\\"0\\\" width=\\\"1\\\" height=\\\"1\\\" src=\\\"https:\/\/beacon-us-iad2.rubiconproject.com\/beacon\/d\/71d2cec2-04b4-4090-9d14-e2ff28520a6a?oo=0&accountId=14062&siteId=70608&zoneId=335918&e=6A1E40E384DA563BCE45DB48A19E3A13CAABEE4AAA35CFFB211A0AE25006D5B7DA92292648F8FA73783A88C763809211C28DC130F5EA7320B1E23F972118B570446C2865710F5C0F6F4554B9D3B62238172CD28438FCBB6A7CC7995518CBBD57EE0674A90822325E3F78ADE0AD4BF73EF73B3C3880EB7D3802278611F6049DA4F82652B0011BD506\\\" alt=\\\"\\\" \/><\/div>\\n\\n\\n<a href=\\\"http:\/\/optimized-by.rubiconproject.com\/t\/14062\/70608\/335918-67.4020200.4378024?url=http%3A%2F%2Fwww.rubiconproject.com\\\" target=\\\"_blank\\\"><img src=\\\"https:\/\/secure-assets.rubiconproject.com\/campaigns\/14062\/39\/56\/90\/1468870536campaign_file_kgfzmh.jpeg\\\" border=\\\"0\\\" alt=\\\"\\\" \/><\/a>\\n\\n\\n\\n<div style=\\\"height:0px;width:0px;overflow:hidden\\\"><iframe src=\\\"https:\/\/eus.rubiconproject.com\/usync.html?geo=**&co=**\\\" frameborder=\\\"0\\\" marginwidth=\\\"0\\\" marginheight=\\\"0\\\" scrolling=\\\"NO\\\" width=\\\"0\\\" height=\\\"0\\\" style=\\\"height:0px;width:0px\\\"><\/iframe><\/div>\\n\\n\",\"crid\":\"4378024\",\"w\":320,\"h\":480}";

NSString *const KeywordsManagerCreative320x50 = @"{\"id\":\"0\",\"impid\":\"Home\",\"price\":0.5,\"adm\":\"    <script type=\\\"text\/javascript\\\">\\n      rubicon_cb = Math.random(); rubicon_rurl = document.referrer; if(top.location==document.location){rubicon_rurl = document.location;} rubicon_rurl = escape(rubicon_rurl);\\n      window.rubicon_ad = \\\"4020938\\\" + \\\".\\\" + \\\"js\\\";\\n      window.rubicon_creative = \\\"4379068\\\" + \\\".\\\" + \\\"js\\\";\\n    <\/script>\\n<div style=\\\"width: 0; height: 0; overflow: hidden;\\\"><img border=\\\"0\\\" width=\\\"1\\\" height=\\\"1\\\" src=\\\"https:\/\/beacon-us-iad2.rubiconproject.com\/beacon\/d\/c12e672d-1abc-4768-8f30-322d691159e7?oo=0&accountId=14062&siteId=70608&zoneId=335918&e=6A1E40E384DA563BF25A1E610BBD87C6C9D35A486DA98064EB464551AB8C4CF3063FB26E28E34714658E185F53BDB9EEC28DC130F5EA73200D702F8FE790D41AD259E90E1D8EC5AC6F4554B9D3B62238172CD28438FCBB6A7CC7995518CBBD57E9C9E430D7C08D85EF1A0E8941E41D2879529F663822DC4504849D224A7549B24A1E9886F9AC9B78\\\" alt=\\\"\\\" \/><\/div>\\n\\n\\n<a href=\\\"http:\/\/optimized-by.rubiconproject.com\/t\/14062\/70608\/335918-43.4020938.4379068?url=http%3A%2F%2Fwww.rubiconproject.com\\\" target=\\\"_blank\\\"><img src=\\\"https:\/\/secure-assets.rubiconproject.com\/campaigns\/14062\/39\/56\/90\/1468956010campaign_file_judul4.gif\\\" border=\\\"0\\\" alt=\\\"\\\" \/><\/a>\\n\\n\\n\\n<div style=\\\"height:0px;width:0px;overflow:hidden\\\"><iframe src=\\\"https:\/\/eus.rubiconproject.com\/usync.html?geo=**&co=**\\\" frameborder=\\\"0\\\" marginwidth=\\\"0\\\" marginheight=\\\"0\\\" scrolling=\\\"NO\\\" width=\\\"0\\\" height=\\\"0\\\" style=\\\"height:0px;width:0px\\\"><\/iframe><\/div>\\n\\n\",\"crid\":\"4379068\",\"w\":320,\"h\":50}";

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
        NSLog(@"POST DATA: %@", postDict);
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
