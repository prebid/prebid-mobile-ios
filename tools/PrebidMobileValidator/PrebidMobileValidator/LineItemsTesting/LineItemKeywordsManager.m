#import "LineItemKeywordsManager.h"
#import <PrebidMobile/PrebidCache.h>

NSString * const KeywordsManagerPriceKey = @"hb_pb";
NSString * const KeywordsManagerCacheIdKey = @"hb_cache_id";
NSString * const KeywordsManagerSizeKey = @"hb_size";
NSString * const KeywordsManagerCacheEndPoint = @"https://prebid.adnxs.com/pbc/v1/cache";
CGFloat const KeywordsManagerPriceFiftyCentsRange = 0.50f; // round to this for now, should be rounded according to setup
NSString *const KeywordsManagerCreative300x250 = @"{\"id\":\"2016846452925826906\",\"impid\":\"Home\",\"price\":0.5,\"adm\":\"<script src=\\\"https:\/\/nym1-ib.adnxs.com\/ab?e=wqT_3QKDCKADBAAAAwDWAAUBCMnajdcFELvyus6-34mmWBiqvffUj9SulS4qNgkAAAECCOA_EQEHNAAA4D8ZAAAAgOtR4D8hERIAKREJADERG6AwleLdBDi-B0C-B0gCUMuWhiNYrdpEYABokUB4jN4EgAEBigEDVVNEkgUG8FKYAawCoAH6AagBAbABALgBAsABA8gBAtABAtgBGeABAfABAIoCO3VmKCdhJywgMTM5OTcwMCwgMTUyNDg1NDA4OSk7dWYoJ3InLCA3MzUwMTUxNTYeAPCNkgLtASFjakhFMVFpZS01SUhFTXVXaGlNWUFDQ3Qya1F3QURnQVFBUkl2Z2RRbGVMZEJGZ0FZTW9EYUFCd0RuaW9BNEFCRG9nQnFBT1FBUUdZQVFHZ0FRR29BUU93QVFDNUFTbUxpSU1BQU9BX3dRRXBpNGlEQUFEZ1A4a0JaaUVfTS1DUTlUX1pBUUFBQQEDJFBBXzRBRUE5UUUBDixBbUFJQW9BSUF0UUkFEAB2DQiId0FJQXlBSUE0QUlBNkFJQS1BSXlnQU1Fa0FNQW1BTUJxQU8F0GR1Z01KVGxsTk1qbzBNRE00mgItITlnZzFuZzbwAChyZHBFSUFRb0FEbzIwACjSAnc4MzY1ODQ0LAUIBDU4DQgAOQkIBDYxCQgANxEIDSgEODAFGAQ5MAkwCDkxMwkQADENEAQyMgkQADIJMAQ5MglQBDkzDShgMzfYAugH4ALH0wHyAhEKBkFEVl9JRBIHMSnkBRQIQ1BHBRQYMzU0NjYyNwEUCAVDUAET8OQIMTQ5OTA3NTCAAwGIAwGQAwCYAxSgAwGqAwDAA6wCyAMA0gMoCAASJDEwMzAwZDA5LWQ4Y2ItNDg5MC1iY2UxLTAwNDAyM2VlZGYyNNgDAOADAOgDAvgDAIAEAJIECS9vcGVucnRiMpgEAKIECzEwLjEuMTMuMTg4qAS80AWyBAwIABAAGAAgADAAOAC4BADABADIBADSBA05NTgjTllNMjo0MDM42gQCCAHgBADwBMuWhiOCBSJjb20uQXBwTmV4dXMuUHJlYmlkTW9iaWxlVmFsaWRhdG9yiAUBmAUAoAX_____BQS4AaoFJDA2QTQwRkYwLTcyMjctNEM5RC1BNTMzLTBCQjMwNDg1QzY4RMAFAMkFAAABAhTwP9IFCQkBCgEBVNgFAeAFAfAFAfoFBAgAEACQBgCYBgA.&s=86c1538731dbfd0c01ea6a59fe28a77bf9e74ccc&test=1&pp=${AUCTION_PRICE}\\\"><\/script>\",\"adid\":\"73501515\",\"adomain\":[\"appnexus.com\"],\"iurl\":\"https:\/\/nym1-ib.adnxs.com\/cr?id=73501515\",\"cid\":\"958\",\"crid\":\"73501515\",\"w\":300,\"h\":250}";
NSString *const KeywordsManagerFakeCacheId = @"FakeCacheId_ShouldNotAffectTest";

@interface LineItemKeywordsManager()
@property NSString *cacheIdFromServer;
@end

@implementation LineItemKeywordsManager

+(id)sharedManager
{
    static LineItemKeywordsManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
        // cache response once for the entire app life cycle since we don't consider impression tracking for testing
        NSData *webData = [KeywordsManagerCreative300x250 dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:webData options:0 error:&error];
        NSMutableDictionary *content = [[NSMutableDictionary alloc]init];
        content[@"type"] = @"json";
        content[@"value"] = jsonDict;
        NSArray *puts = @[content];
        NSDictionary *postDict  = [NSDictionary dictionaryWithObject:puts forKey:@"puts"];
        NSURL *url = [[NSURL alloc]initWithString:KeywordsManagerCacheEndPoint];
        NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:url
                                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                       timeoutInterval:1000];
        [mutableRequest setHTTPMethod:@"POST"];
        NSData *postData = [NSJSONSerialization dataWithJSONObject:postDict
                                                           options:kNilOptions
                                                             error:&error];
        [mutableRequest setHTTPBody:postData];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *cacheIdTask = [session dataTaskWithRequest:mutableRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error) {
                NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSArray *uuids = response[@"responses"];
                sharedManager.cacheIdFromServer = uuids[0][@"uuid"];
            }
        }];
        [cacheIdTask resume];
        
        
    });
    return sharedManager;
}

- (NSDictionary<NSString *, NSString *> *)keywordsWithBidPrice:(NSString *)bidPrice forSize:(NSString *)sizeString usingLocalCache:(BOOL) useLocalCache {
    NSMutableDictionary *keywords = [[NSMutableDictionary alloc] init];
    if (useLocalCache) {
        NSData *webData = [KeywordsManagerCreative300x250 dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:webData options:0 error:&error];
        NSString *cacheId = [[NSUUID UUID] UUIDString];
        [[PrebidCache globalCache] setObject:jsonDict forKey:cacheId];
        keywords[KeywordsManagerCacheIdKey] = cacheId;
    } else {
        if (self.cacheIdFromServer) {
            keywords[KeywordsManagerCacheIdKey] = self.cacheIdFromServer;
        } else {
            keywords[KeywordsManagerCacheIdKey] = KeywordsManagerFakeCacheId;
        }
    }
    keywords[KeywordsManagerPriceKey] =  bidPrice;
    keywords[KeywordsManagerSizeKey] = sizeString;
    return [keywords copy];
}


- (nonnull NSString *)formatValue:(CGFloat)value toRange:(CGFloat)range {
    NSString *__nonnull formattedValue = [NSString
                                          stringWithFormat:@"%.2f", [self roundValue:value toRange:range]];
    
    return (formattedValue);
}

- (CGFloat)roundValue:(CGFloat)value toRange:(CGFloat)range {
    CGFloat newValue = value;
    
    if (range != 0)
        newValue = ((int)(value / range)) * range;
    
    return (newValue);
}

@end
