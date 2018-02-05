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

#import <AdSupport/AdSupport.h>
#import "PrebidCache.h"
#import <sys/utsname.h>
#import <UIKit/UIKit.h>

#import "PBBidResponse.h"
#import "PBBidResponseDelegate.h"
#import "PBLogging.h"
#import "PBServerAdapter.h"
#import "PBServerFetcher.h"
#import "PBTargetingParams.h"
#import "PBServerRequestBuilder.h"
#import "PBException.h"

static NSString *const kAPNAdServerCacheIdKey = @"hb_cache_id";

static NSString *const kAPNPrebidServerUrl = @"https://prebid.adnxs.com/pbs/v1/openrtb2/auction";
static NSString *const kRPPrebidServerUrl = @"https://prebid-server.rubiconproject.com/auction";
static NSTimeInterval const kAdTimeoutInterval = 360;

@interface PBServerAdapter ()

@property (nonatomic, strong) NSString *accountId;

@property (nonatomic, assign, readwrite) PBServerHost host;

@end

@implementation PBServerAdapter

- (nonnull instancetype)initWithAccountId:(nonnull NSString *)accountId {
    if (self = [super init]) {
        _accountId = accountId;
        _isSecure = TRUE;
        _shouldCacheLocal = TRUE;
        _host = PBServerHostAppNexus;
    }
    return self;
}

- (nonnull instancetype)initWithAccountId:(nonnull NSString *)accountId andHost:(PBServerHost) host {
    if (self = [super init]) {
        _accountId = accountId;
        _isSecure = TRUE;
        _shouldCacheLocal = TRUE;
        _host = host;
    }
    return self;
}

- (void)requestBidsWithAdUnits:(nullable NSArray<PBAdUnit *> *)adUnits
                  withDelegate:(nonnull id<PBBidResponseDelegate>)delegate {
    
    NSURL *hostUrl = [self urlForHost:_host];
    if (hostUrl == nil) {
        @throw [PBException exceptionWithName:PBHostInvalidException];
    }
    
    [[PBServerRequestBuilder sharedInstance] setHostURL:hostUrl];
    
    //batch the adunits to group of 10 & send to the server instead of this bulk request
    int adUnitsRemaining = (int)[adUnits count];
    int j = 0;
    
    while(adUnitsRemaining) {
        NSRange range = NSMakeRange(j, MIN(10, adUnitsRemaining));
        NSArray<PBAdUnit *> *subAdUnitArray = [adUnits subarrayWithRange:range];
        adUnitsRemaining-=range.length;
        j+=range.length;
        
        NSURLRequest *request = [[PBServerRequestBuilder sharedInstance] buildRequest:subAdUnitArray withAccountId:self.accountId shouldCacheLocal:self.shouldCacheLocal withSecureParams:self.isSecure];
        
        __weak __typeof__(self) weakSelf = self;
        
        [[PBServerFetcher sharedInstance] makeBidRequest:request withCompletionHandler:^(NSDictionary *adUnitToBidsMap, NSError *error) {
            
            __typeof__(self) strongSelf = weakSelf;
            if (error) {
                [delegate didCompleteWithError:error];
                return;
            }
            for (NSString *adUnitId in [adUnitToBidsMap allKeys]) {
                NSArray *bidsArray = (NSArray *)[adUnitToBidsMap objectForKey:adUnitId];
                NSMutableArray *bidResponsesArray = [[NSMutableArray alloc] init];
                for (NSDictionary *bid in bidsArray) {
                    PBBidResponse *bidResponse = [PBBidResponse bidResponseWithAdUnitId:adUnitId adServerTargeting:bid[@"ext"][@"prebid"][@"targeting"]];
                    if (strongSelf.shouldCacheLocal == TRUE) {
                        NSString *cacheId = [[NSUUID UUID] UUIDString];
                        NSMutableDictionary *bidCopy = [bid mutableCopy];
                        NSMutableDictionary *adServerTargetingCopy = [bidCopy[@"ext"][@"prebid"][@"targeting"] mutableCopy];
                        if([adServerTargetingCopy valueForKey:kAPNAdServerCacheIdKey] == nil){
                            adServerTargetingCopy[kAPNAdServerCacheIdKey] = cacheId;
                        }
                        NSMutableDictionary *extCopy = [bidCopy[@"ext"] mutableCopy];
                        NSMutableDictionary *prebidExtCopy = [bidCopy[@"ext"][@"prebid"] mutableCopy];
                        prebidExtCopy[@"targeting"] = adServerTargetingCopy;
                        extCopy[@"prebid"] = prebidExtCopy;
                        bidCopy[@"ext"] = extCopy;
                        [[PrebidCache globalCache] setObject:bidCopy forKey:cacheId withTimeoutInterval:kAdTimeoutInterval];
                        
                        bidResponse = [PBBidResponse bidResponseWithAdUnitId:adUnitId adServerTargeting:adServerTargetingCopy];
                    }
                    PBLogDebug(@"Bid Successful with rounded bid targeting keys are %@ for adUnit id is %@", bidResponse.customKeywords, adUnitId);
                    [bidResponsesArray addObject:bidResponse];
                }
                [delegate didReceiveSuccessResponse:bidResponsesArray];
            }
        }];
        
    }
}

- (NSURL *)urlForHost:(PBServerHost)host {
    NSURL *url;
    switch (host) {
        case PBServerHostAppNexus:
            url = [NSURL URLWithString:kAPNPrebidServerUrl];
            break;
        case PBServerHostRubicon:
            url = [NSURL URLWithString:kRPPrebidServerUrl];
            break;
        default:
            url = nil;
            break;
    }
    
    return url;
}
@end
