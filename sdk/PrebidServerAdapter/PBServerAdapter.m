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
static NSString *const kRPPrebidServerUrl = @"https://prebid-server.rubiconproject.com/openrtb2/auction";
static NSString *const kASPrebidServerUrl = @"https://tagmans3.adsolutions.com/pbs/v0/openrtb2/auction";
static int const kBatchCount = 10;

@interface PBServerAdapter ()

@property (nonatomic, strong) NSString *accountId;

@property (assign) PBPrimaryAdServerType primaryAdServer;

@property (nonatomic, assign, readwrite) PBServerHost host;

@end

@implementation PBServerAdapter

- (nonnull instancetype)initWithAccountId:(nonnull NSString *)accountId andAdServer:(PBPrimaryAdServerType) adServer{
    if (self = [super init]) {
        _accountId = accountId;
        _isSecure = TRUE;
        _host = PBServerHostAppNexus;
        _primaryAdServer = adServer;
    }
    return self;
}

- (nonnull instancetype)initWithAccountId:(nonnull NSString *)accountId andHost:(PBServerHost) host andAdServer:(PBPrimaryAdServerType) adServer{
    if (self = [super init]) {
        _accountId = accountId;
        _isSecure = TRUE;
        _host = host;
        _primaryAdServer = adServer;
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
        NSRange range = NSMakeRange(j, MIN(kBatchCount, adUnitsRemaining));
        NSArray<PBAdUnit *> *subAdUnitArray = [adUnits subarrayWithRange:range];
        adUnitsRemaining-=range.length;
        j+=range.length;
        
        NSURLRequest *request = [[PBServerRequestBuilder sharedInstance] buildRequest:subAdUnitArray withAccountId:self.accountId withSecureParams:self.isSecure];
        
        [[PBServerFetcher sharedInstance] makeBidRequest:request withCompletionHandler:^(NSDictionary *adUnitToBidsMap, NSError *error) {
            if (error) {
                [delegate didCompleteWithError:error];
                return;
            }
            for (NSString *adUnitId in [adUnitToBidsMap allKeys]) {
                NSArray *bidsArray = (NSArray *)[adUnitToBidsMap objectForKey:adUnitId];
                NSMutableArray *bidResponsesArray = [[NSMutableArray alloc] init];
                NSMutableArray * contentsToCache = [[NSMutableArray alloc] init];
                for (NSDictionary *bid in bidsArray) {
                    NSString *escapedBid = [self escapeJsonString:[self jsonStringFromDictionary:bid]];
                    [contentsToCache addObject:escapedBid];
                }
                for (int i = 0; i< bidsArray.count; i++) {
                    NSMutableDictionary *adServerTargetingCopy = [bidsArray[i][@"ext"][@"prebid"][@"targeting"] mutableCopy];
                    if (adServerTargetingCopy != nil) {
                        // Check if resposne has cache id, since prebid server cache would fail for some reason and not set cache id on the response
                        // If cache id is not present, we do not pass the bid back
                        bool hasCacheID = NO;
                        for (NSString *key in adServerTargetingCopy.allKeys) {
                            if ([key containsString:@"hb_cache_id"]) {
                                hasCacheID = YES;
                            }
                        }
                        if (hasCacheID) {
                            PBBidResponse *bidResponse = [PBBidResponse bidResponseWithAdUnitId:adUnitId adServerTargeting:adServerTargetingCopy];
                            PBLogDebug(@"Bid Successful with rounded bid targeting keys are %@ for adUnit id is %@", [bidResponse.customKeywords description], adUnitId);
                            [bidResponsesArray addObject:bidResponse];
                        }
                    }
                }
                if (bidResponsesArray.count == 0) {
                    // use code 0 to represent the no bid case for now
                    [delegate didCompleteWithError:[NSError errorWithDomain:@"prebid.org" code:0 userInfo:nil] ];
                } else {
                    [delegate didReceiveSuccessResponse:bidResponsesArray];
                }
            }
        }];
        
    }
}

- (NSString *)jsonStringFromDictionary: (NSDictionary *) dict
{
    //strip all the extra lines in the creative before converting to escaped json string - start
    NSMutableDictionary *copiedDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
    
    NSString *copiedAdm = (NSString *)copiedDict[@"adm"];
    
    NSString *strippedTextLine = [copiedAdm stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    copiedDict[@"adm"] = strippedTextLine;
    //end - do not remove this
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:copiedDict
                                                       options:0
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"%s: error: %@", __func__, error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

- (NSString *) escapeJsonString: (NSString *) aString
{
    NSMutableString *s = [NSMutableString stringWithString:aString];
    
    [s replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"/" withString:@"\\/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\n" withString:@"\\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\b" withString:@"\\b" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\f" withString:@"\\f" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\r" withString:@"\\r" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\t" withString:@"\\t" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    return [NSString stringWithString:s];
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
        case PBServerHostAdsolutions:
            url = [NSURL URLWithString:kASPrebidServerUrl];
            break;
        default:
            url = nil;
            break;
    }
    
    return url;
}
@end
