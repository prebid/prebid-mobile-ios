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

#import <XCTest/XCTest.h>
#import "PBServerRequestBuilder.h"
#import "PBTargetingParams.h"
#import "PBServerAdapter.h"
#import "PBException.h"
#import "PBHost.h"
#import "PBBidResponse.h"

static NSString *const kPrebidMobileVersion = @"0.1.1";
static NSString *const kAPNPrebidServerUrl = @"https://prebid.adnxs.com/pbs/v1/openrtb2/auction";
static NSString *const kRPPrebidServerUrl = @"https://prebid-server.rubiconproject.com/auction";
static NSString *testResponse = @"";

@interface PBTestProtocol: NSURLProtocol
@end

@implementation PBTestProtocol
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if ([NSURLProtocol propertyForKey:@"PrebidURLProtocolHandledKey" inRequest:request]) {
        return NO;
    }
    if ([request.URL.absoluteString containsString:kAPNPrebidServerUrl]) {
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading {
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:@"PrebidURLProtocolHandledKey" inRequest:newRequest];

    NSData *data = [testResponse dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        NSURLResponse* response = [[NSHTTPURLResponse alloc] initWithURL:[self.request URL] statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:@{@"Access-Control-Allow-Origin": kAPNPrebidServerUrl, @"Access-Control-Allow-Credentials" : @"true"}];
                [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
                [self.client URLProtocol:self didLoadData:data];
                [self.client URLProtocolDidFinishLoading:self];
    }

}

- (void)stopLoading
{
    
}

@end

@interface PBServerAdapterTests : XCTestCase<PBBidResponseDelegate>
@property void (^completionHandler)(NSArray *bids);
@property (nonatomic, strong) NSArray *adUnits;
@end

@implementation PBServerAdapterTests

- (void)setUp {
    [super setUp];
    PBAdUnit *adUnit = [[PBAdUnit alloc] initWithIdentifier:@"test_identifier" andAdType:PBAdUnitTypeBanner andConfigId:@"test_config_id"];
    [adUnit addSize:CGSizeMake(250, 300)];
    self.adUnits = @[adUnit];
}

- (void)tearDown {
    self.adUnits = nil;
    [super tearDown];
}

- (void)didCompleteWithError:(nonnull NSError *)error {
    self.completionHandler(nil);
}

- (void)didReceiveSuccessResponse:(nonnull NSArray<PBBidResponse *> *)bid {
    self.completionHandler(bid);
}
-(void)testAllBidsAreCached
{
    testResponse = @"{\"id\":\"3dc76667-a500-4e01-a43b-368e36d6c7cc\",\"seatbid\":[{\"bid\":[{\"id\":\"4009307468250838284\",\"impid\":\"Banner_300x250\",\"price\":0.5,\"adm\":\"<script><\/script>\",\"adid\":\"73501515\",\"adomain\":[\"appnexus.com\"],\"iurl\":\"https:\/\/nym1-ib.adnxs.com\/cr?id=73501515\",\"cid\":\"958\",\"crid\":\"73501515\",\"w\":300,\"h\":250,\"ext\":{\"prebid\":{\"targeting\":{\"hb_bidder\":\"appnexus\",\"hb_bidder_appnexus\":\"appnexus\",\"hb_creative_loadtype\":\"html\",\"hb_env\":\"mobile-app\",\"hb_env_appnexus\":\"mobile-app\",\"hb_pb\":\"0.50\",\"hb_pb_appnexus\":\"0.50\",\"hb_size\":\"300x250\",\"hb_size_appnexus\":\"300x250\"},\"type\":\"banner\"},\"bidder\":{\"appnexus\":{\"brand_id\":1,\"auction_id\":7466795334738195000,\"bidder_id\":2,\"bid_ad_type\":0}}}}],\"seat\":\"appnexus\"},{\"bid\":[{\"id\":\"4009307468250838284\",\"impid\":\"Banner_300x250\",\"price\":0.5,\"adm\":\"<script><\/script>\",\"adid\":\"73501515\",\"adomain\":[\"rubicon.com\"],\"iurl\":\"https:\/\/nym1-ib.adnxs.com\/cr?id=73501515\",\"cid\":\"958\",\"crid\":\"73501515\",\"w\":300,\"h\":250,\"ext\":{\"prebid\":{\"targeting\":{\"hb_bidder_rubicon\":\"rubicon\",\"hb_creative_loadtype\":\"html\",\"hb_env_rubicon\":\"mobile-app\",\"hb_pb_rubicon\":\"0.50\",\"hb_size_rubicon\":\"300x250\"},\"type\":\"banner\"}}}],\"seat\":\"rubicon\"},{\"bid\":[{\"id\":\"4009307468250838284\",\"impid\":\"Banner_300x250\",\"price\":0.5,\"adm\":\"<script><\/script>\",\"adid\":\"73501515\",\"adomain\":[\"superlongnamethatshouldbecropped.com\"],\"iurl\":\"https:\/\/nym1-ib.adnxs.com\/cr?id=73501515\",\"cid\":\"958\",\"crid\":\"73501515\",\"w\":300,\"h\":250,\"ext\":{\"prebid\":{\"targeting\":{\"hb_bidder_superlongnamet\":\"superlongnamethatshouldbecropped\",\"hb_creative_loadtype\":\"html\",\"hb_env_superlongnamethat\":\"mobile-app\",\"hb_pb_superlongnamethats\":\"0.50\",\"hb_size_superlongnametha\":\"300x250\"},\"type\":\"banner\"}}}],\"seat\":\"superlongnamethatshouldbecropped\"}],\"ext\":{\"responsetimemillis\":{\"appnexus\":19}}}";
    [NSURLProtocol registerClass:[PBTestProtocol class]];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Dummy Expectation"];
    PBAdUnit *adUnit1 = [[PBAdUnit alloc] initWithIdentifier:@"ad1" andAdType:PBAdUnitTypeBanner andConfigId:@"test_config_id1"];
    [adUnit1 addSize:CGSizeMake(250, 300)];
    PBAdUnit *adUnit2 = [[PBAdUnit alloc] initWithIdentifier:@"ad2" andAdType:PBAdUnitTypeBanner andConfigId:@"test_config_id2"];
    [adUnit2 addSize:CGSizeMake(250, 300)];
    self.adUnits = @[adUnit1, adUnit2];
    PBServerAdapter *serverAdapter = [[PBServerAdapter alloc] initWithAccountId:@"test_account_id" andHost:PBServerHostAppNexus andAdServer:PBPrimaryAdServerDFP];
    [serverAdapter requestBidsWithAdUnits:self.adUnits withDelegate:self];
    self.completionHandler = ^(NSArray *bids){
        // veryfy that all bids has a cache id
        // veryfy that only top bid has hb_cache_id
        // verify cache_id is truncated after 20 characters
        XCTAssertTrue(bids.count == 3);
        BOOL cacheIdHasBeenSeen = NO;
        for(PBBidResponse *bid in bids){
            BOOL isCacheIdPresent = NO;
            BOOL isTopBid = NO;
            NSString *cacheKey = @"";
            NSLog(@"Bid keywords: %@", bid.customKeywords);
            for (NSString *key in bid.customKeywords.allKeys) {
                if ([key containsString:@"hb_cache_id_"]) {
                    isCacheIdPresent = YES;
                    cacheKey = key;
                    XCTAssertTrue(key.length <=20);
                }
                if ([key isEqualToString:@"hb_bidder"]) {
                    isTopBid = YES;
                }
                if ([key isEqualToString:@"hb_cache_id"]) {
                    if (cacheIdHasBeenSeen) {
                        XCTFail(@"should not be setting hb_cache_id twice");
                    } else {
                        cacheIdHasBeenSeen = YES;
                    }
                }
             
            }
            if (isTopBid) {
                XCTAssertTrue([bid.customKeywords.allKeys containsObject:@"hb_cache_id"]);
                XCTAssertEqual([bid.customKeywords objectForKey:@"hb_cache_id"], [bid.customKeywords objectForKey:cacheKey]);
            } else {
                XCTAssertTrue(![bid.customKeywords.allKeys containsObject:@"hb_cahce_id"]);
            }
            XCTAssertTrue(isCacheIdPresent);
        }
        
        [expectation fulfill];
    };
    [self waitForExpectationsWithTimeout:20.0 handler:nil];
}
- (void)testRequestBodyForAdUnit {
    
    [[PBTargetingParams sharedInstance] setUserKeywords:@"targeting1" withValue:@"value1"];
    [[PBTargetingParams sharedInstance] setUserKeywords:@"targeting2" withValue:@"value2"];
    
    NSURL *hostURL = [NSURL URLWithString:kAPNPrebidServerUrl];
    
    [[PBServerRequestBuilder sharedInstance] setHostURL: hostURL];
    NSURLRequest *request = [[PBServerRequestBuilder sharedInstance] buildRequest:self.adUnits withAccountId:@"account_id" shouldCacheLocal:NO withSecureParams:NO];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Dummy expectation"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        
        
        NSError* error;
        NSDictionary* requestBody = [NSJSONSerialization JSONObjectWithData:[request HTTPBody]
                                                                    options:kNilOptions
                                                                      error:&error];
        
        XCTAssertNotNil(requestBody);
        
        XCTAssertEqualObjects(requestBody[@"app"][@"publisher"][@"id"], @"account_id");
        
        NSDictionary *app = requestBody[@"app"][@"ext"][@"prebid"];
        XCTAssertNotNil(app[@"version"]);
        
        XCTAssertEqualObjects(app[@"source"], @"prebid-mobile");
        
        NSString *targetingParams = requestBody[@"user"][@"keywords"];
        
        XCTAssertNotNil(targetingParams);
        
        NSDictionary *device = requestBody[@"device"];
        XCTAssertEqualObjects(device[@"os"], @"iOS");
        XCTAssertEqualObjects(device[@"make"], @"Apple");
        
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:20.0 handler:nil];
}

- (void)testBuildRequestForAdUnitsInvalidHost {
    PBServerAdapter *serverAdapter = [[PBServerAdapter alloc] initWithAccountId:@"test_account_id" andHost:PBServerHostAppNexus andAdServer:PBPrimaryAdServerDFP];
    @try {
        [serverAdapter requestBidsWithAdUnits:self.adUnits withDelegate:self];
    } @catch (PBException *exception) {
        NSExceptionName expectedException = @"PBHostInvalidException";
        XCTAssertNotNil(exception);
        XCTAssertEqual(exception.name, expectedException);
    }
}

- (void)testBuildRequestForAdUnitsValidHost {
    
    NSURL *hostURL = [NSURL URLWithString:kRPPrebidServerUrl];
    
    [[PBServerRequestBuilder sharedInstance] setHostURL: hostURL];
    NSURLRequest *request = [[PBServerRequestBuilder sharedInstance] buildRequest:self.adUnits withAccountId:@"account_id" shouldCacheLocal:NO withSecureParams:NO];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Dummy expectation"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        
        XCTAssertEqualObjects(request.URL, [NSURL URLWithString:kRPPrebidServerUrl]);
        
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:20.0 handler:nil];

}

- (void)testRequestBodyForAdUnitWithDFPAdServer {
    
    NSURL *hostURL = [NSURL URLWithString:kAPNPrebidServerUrl];
    
    [[PBServerRequestBuilder sharedInstance] setHostURL: hostURL];
    NSURLRequest *request = [[PBServerRequestBuilder sharedInstance] buildRequest:self.adUnits withAccountId:@"account_id" shouldCacheLocal:YES withSecureParams:NO];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Dummy expectation"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        
        
        NSError* error;
        NSDictionary* requestBody = [NSJSONSerialization JSONObjectWithData:[request HTTPBody]
                                                                    options:kNilOptions
                                                                      error:&error];
        
        XCTAssertNotNil(requestBody);
        
        XCTAssertNil(requestBody[@"ext"][@"prebid"][@"cache"]);
        
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:20.0 handler:nil];
    
    
}

- (void)testRequestBodyForAdUnitWithMoPubAdServer {
    NSURL *hostURL = [NSURL URLWithString:kAPNPrebidServerUrl];
    
    [[PBServerRequestBuilder sharedInstance] setHostURL: hostURL];
    NSURLRequest *request = [[PBServerRequestBuilder sharedInstance] buildRequest:self.adUnits withAccountId:@"account_id" shouldCacheLocal:NO withSecureParams:NO];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Dummy expectation"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        
        
        NSError* error;
        NSDictionary* requestBody = [NSJSONSerialization JSONObjectWithData:[request HTTPBody]
                                                                    options:kNilOptions
                                                                      error:&error];
        
        XCTAssertNotNil(requestBody);
        XCTAssertNil(requestBody[@"ext"][@"prebid"][@"cache"]);
        
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:20.0 handler:nil];

    
}

-(void) testBatchRequestBidsWithAdUnits{
    PBAdUnit *adUnit1 = [[PBAdUnit alloc] initWithIdentifier:@"test1" andAdType:PBAdUnitTypeBanner andConfigId:@"config1"];
    [adUnit1 addSize:CGSizeMake(250, 300)];
    
    PBAdUnit *adUnit2 = [[PBAdUnit alloc] initWithIdentifier:@"test2" andAdType:PBAdUnitTypeBanner andConfigId:@"config2"];
    [adUnit2 addSize:CGSizeMake(250, 300)];
    
    PBAdUnit *adUnit3 = [[PBAdUnit alloc] initWithIdentifier:@"test3" andAdType:PBAdUnitTypeBanner andConfigId:@"config3"];
    [adUnit3 addSize:CGSizeMake(250, 300)];
    
    PBAdUnit *adUnit4 = [[PBAdUnit alloc] initWithIdentifier:@"test4" andAdType:PBAdUnitTypeBanner andConfigId:@"config4"];
    [adUnit4 addSize:CGSizeMake(250, 300)];
    
    PBAdUnit *adUnit5 = [[PBAdUnit alloc] initWithIdentifier:@"test5" andAdType:PBAdUnitTypeBanner andConfigId:@"config5"];
    [adUnit5 addSize:CGSizeMake(250, 300)];
    
    PBAdUnit *adUnit6 = [[PBAdUnit alloc] initWithIdentifier:@"test6" andAdType:PBAdUnitTypeBanner andConfigId:@"config6"];
    [adUnit6 addSize:CGSizeMake(250, 300)];
    
    PBAdUnit *adUnit7 = [[PBAdUnit alloc] initWithIdentifier:@"test7" andAdType:PBAdUnitTypeBanner andConfigId:@"config7"];
    [adUnit7 addSize:CGSizeMake(250, 300)];
    
    PBAdUnit *adUnit8 = [[PBAdUnit alloc] initWithIdentifier:@"test8" andAdType:PBAdUnitTypeBanner andConfigId:@"config8"];
    [adUnit8 addSize:CGSizeMake(250, 300)];
    
    PBAdUnit *adUnit9 = [[PBAdUnit alloc] initWithIdentifier:@"test9" andAdType:PBAdUnitTypeBanner andConfigId:@"config9"];
    [adUnit9 addSize:CGSizeMake(250, 300)];
    
    PBAdUnit *adUnit10 = [[PBAdUnit alloc] initWithIdentifier:@"test10" andAdType:PBAdUnitTypeBanner andConfigId:@"config10"];
    [adUnit10 addSize:CGSizeMake(250, 300)];
    
    PBAdUnit *adUnit11 = [[PBAdUnit alloc] initWithIdentifier:@"test11" andAdType:PBAdUnitTypeBanner andConfigId:@"config11"];
    [adUnit11 addSize:CGSizeMake(250, 300)];
    
    PBAdUnit *adUnit12 = [[PBAdUnit alloc] initWithIdentifier:@"test12" andAdType:PBAdUnitTypeBanner andConfigId:@"config12"];
    [adUnit12 addSize:CGSizeMake(250, 300)];
    
    NSArray *adUnitsArray = @[adUnit1,adUnit2,adUnit3,adUnit4,adUnit5,adUnit6,adUnit7,adUnit8,adUnit9,adUnit10, adUnit11, adUnit12];
    
    PBServerAdapter *serverAdapter = [[PBServerAdapter alloc] initWithAccountId:@"test_account_id" andHost:PBServerHostAppNexus andAdServer:PBPrimaryAdServerDFP];
    @try {
        [serverAdapter requestBidsWithAdUnits:adUnitsArray withDelegate:self];
    } @catch (PBException *exception) {
        NSExceptionName expectedException = @"PBHostInvalidException";
        XCTAssertNotNil(exception);
        XCTAssertEqual(exception.name, expectedException);
    }
}

@end
