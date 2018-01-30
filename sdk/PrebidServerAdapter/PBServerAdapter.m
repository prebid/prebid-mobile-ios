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
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "PrebidCache.h"
#import <sys/utsname.h>
#import <UIKit/UIKit.h>

#import "PBBidResponse.h"
#import "PBBidResponseDelegate.h"
#import "PBLogging.h"
#import "PBServerAdapter.h"
#import "PBServerFetcher.h"
#import "PBServerGlobal.h"
#import "PBServerLocation.h"
#import "PBServerReachability.h"
#import "PBTargetingParams.h"

static NSString *const kAPNAdServerResponseKeyNoBid = @"nobid";
static NSString *const kAPNAdServerResponseKeyUUID = @"uuid";
static NSString *const kAPNAdServerCacheIdKey = @"hb_cache_id";
static NSString *const kPrebidMobileVersion = @"0.1.1";
static NSTimeInterval const kAdTimeoutInterval = 360;

static NSString *const kPrebidServerOpenRTBEndpoint = @"https://prebid.adnxs.com/pbs/v1/openrtb2/auction";

@interface PBServerAdapter ()

@property (nonatomic, strong) NSString *accountId;

@end

@implementation PBServerAdapter

- (nonnull instancetype)initWithAccountId:(nonnull NSString *)accountId {
    if (self = [super init]) {
        _accountId = accountId;
    }
    return self;
}

- (void)requestBidsWithAdUnits:(nullable NSArray<PBAdUnit *> *)adUnits
                  withDelegate:(nonnull id<PBBidResponseDelegate>)delegate {
    NSURLRequest *request = [self buildRequestForAdUnits:adUnits];
    
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

- (NSURLRequest *)buildRequestForAdUnits:(NSArray<PBAdUnit *> *)adUnits {
    NSURL *url = [NSURL URLWithString:kPrebidServerOpenRTBEndpoint];
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:url
                                                                       cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                   timeoutInterval:1000];
    [mutableRequest setHTTPMethod:@"POST"];
    NSDictionary *requestBody = [self openRTBRequestBodyForAdUnits:adUnits];
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:requestBody
                                                       options:kNilOptions
                                                         error:&error];
    if (!error) {
        [mutableRequest setHTTPBody:postData];
        return [mutableRequest copy];
    } else {
        return nil;
    }
}

- (NSDictionary *)openRTBRequestBodyForAdUnits:(NSArray<PBAdUnit *> *)adUnits {
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];

    requestDict[@"id"] = [[NSUUID UUID] UUIDString];
    
    requestDict[@"app"] = [self openrtbApp];
    requestDict[@"device"] = [self openrtbDevice];
    requestDict[@"user"] = [self openrtbUser];
    requestDict[@"imp"] = [self openrtbImpsFromAdUnits:adUnits];
    requestDict[@"ext"] = [self openrtbRequestExtension];

#ifdef DEBUG
	requestDict[@"test"] = @(YES);
#endif

    return [requestDict copy];
}

- (NSDictionary *)openrtbRequestExtension {
    NSMutableDictionary *requestPrebidExt = [[NSMutableDictionary alloc] init];
    
    if (self.shouldCacheLocal == FALSE) {
        requestPrebidExt[@"cache"] = @{@"bids" : [[NSMutableDictionary alloc] init]};
    }
    requestPrebidExt[@"targeting"] = @{@"lengthmax" : @(20), @"pricegranularity":@"medium"};
    
    NSMutableDictionary *requestExt = [[NSMutableDictionary alloc] init];
    requestExt[@"prebid"] = requestPrebidExt;
    return [requestExt copy];
}

- (NSArray *)openrtbImpsFromAdUnits:(NSArray<PBAdUnit *> *)adUnits {
    NSMutableArray *imps = [[NSMutableArray alloc] init];

    for (PBAdUnit *adUnit in adUnits) {
        NSMutableDictionary *imp = [[NSMutableDictionary alloc] init];
        imp[@"id"] = adUnit.identifier;
        if(self.isSecure){
            imp[@"secure"] = @1;
        }
        NSMutableArray *sizeArray = [[NSMutableArray alloc] initWithCapacity:adUnit.adSizes.count];
        for (id size in adUnit.adSizes) {
            CGSize arSize = [size CGSizeValue];
            NSDictionary *sizeDict = [NSDictionary dictionaryWithObjectsAndKeys:@(arSize.width), @"w", @(arSize.height), @"h", nil];
            [sizeArray addObject:sizeDict];
        }
        // TODO check for video here when we add video (Nicole)
        NSDictionary *formats = @{@"format": sizeArray};
        imp[@"banner"] = formats;

        if (adUnit.adType == PBAdUnitTypeInterstitial) {
            imp[@"instl"] = @(1);
        }
        
        //to be removed when openRTB supports storedRequests
        NSMutableDictionary *placementDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@9924885,@"placementId", nil];
        
        NSMutableDictionary *vendorDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:placementDict,@"appnexus", nil];
        imp[@"ext"] = vendorDict;
        
        //to be uncommented when openRTB adUnit ID is working
        /*NSMutableDictionary *prebidAdUnitExt = [[NSMutableDictionary alloc] init];
        prebidAdUnitExt[@"storedrequest"] = @{@"id" : adUnit.configId};

        NSMutableDictionary *adUnitExt = [[NSMutableDictionary alloc] init];
        adUnitExt[@"prebid"] = prebidAdUnitExt;

        imp[@"ext"] = adUnitExt;*/
        
        
        [imps addObject:imp];
    }
    return [imps copy];
}

// OpenRTB 2.5 Object: App in section 3.2.14
- (NSDictionary *)openrtbApp {
    NSMutableDictionary *app = [[NSMutableDictionary alloc] init];
    
    NSString *bundle = [[NSBundle mainBundle] bundleIdentifier];
    if (bundle) {
        app[@"bundle"] = bundle;
    }
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (version) {
        app[@"ver"] = version;
    }
    
    app[@"publisher"] = @{@"id": self.accountId};
    app[@"ext"] = @{@"prebid" : @{@"version" : kPrebidMobileVersion, @"source" : @"prebid-mobile"}};
    return [app copy];
}

// OpenRTB 2.5 Object: Device in section 3.2.18
- (NSDictionary *)openrtbDevice {
    NSMutableDictionary *deviceDict = [[NSMutableDictionary alloc] init];
    
    NSString *userAgent = PBSUserAgent();
    if (userAgent) {
        deviceDict[@"ua"] = userAgent;
    }
    NSDictionary *geo = [self openrtbGeo];
    if (geo) {
        deviceDict[@"geo"] = geo;
    }
    
    deviceDict[@"make"] = @"Apple";
    deviceDict[@"os"] = @"iOS";
    deviceDict[@"osv"] = [[UIDevice currentDevice] systemVersion];
    deviceDict[@"h"] = @([[UIScreen mainScreen] bounds].size.height);
    deviceDict[@"w"] = @([[UIScreen mainScreen] bounds].size.width);
    
    NSString *deviceModel = PBSDeviceModel();
    if (deviceModel) {
        deviceDict[@"model"] = deviceModel;
    }
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    
    if (carrier.carrierName.length > 0) {
        deviceDict[@"carrier"] = carrier.carrierName;
    }
    
    PBServerReachability *reachability = [PBServerReachability reachabilityForInternetConnection];
    PBSNetworkStatus status = [reachability currentReachabilityStatus];
    NSUInteger connectionType = 0;
    switch (status) {
        case PBSNetworkStatusReachableViaWiFi:
            connectionType = 1;
            break;
        case PBSNetworkStatusReachableViaWWAN:
            connectionType = 2;
            break;
        default:
            connectionType = 0;
            break;
    }
    deviceDict[@"connectiontype"] = @(connectionType);
    
    if (carrier.mobileCountryCode.length > 0 && carrier.mobileNetworkCode.length > 0) {
        deviceDict[@"mccmnc"] = [[carrier.mobileCountryCode stringByAppendingString:@"-"] stringByAppendingString:carrier.mobileNetworkCode];
    }
    // Limit ad tracking
    deviceDict[@"lmt"] = @(!PBSAdvertisingTrackingEnabled());
    
    NSString *deviceId = PBSUDID();
    if (deviceId) {
        deviceDict[@"ifa"] = deviceId;
    }

    NSInteger timeInMiliseconds = (NSInteger)[[NSDate date] timeIntervalSince1970];
    deviceDict[@"devtime"] = @(timeInMiliseconds);
    
    CGFloat pixelRatio = [[UIScreen mainScreen] scale];
    deviceDict[@"pxratio"] = @(pixelRatio);

    return [deviceDict copy];
}

// OpenRTB 2.5 Object: Geo in section 3.2.19
- (NSDictionary *)openrtbGeo {
    CLLocation *clLocation = [[PBTargetingParams sharedInstance] location];
    PBServerLocation *location;
    if (clLocation) {
        location = [PBServerLocation getLocationWithLatitude:clLocation.coordinate.latitude longitude:clLocation.coordinate.longitude timestamp:clLocation.timestamp horizontalAccuracy:clLocation.horizontalAccuracy];
    }
    if (location) {
        NSMutableDictionary *geoDict = [[NSMutableDictionary alloc] init];
        CGFloat latitude = location.latitude;
        CGFloat longitude = location.longitude;
        
        if (location.precision >= 0) {
            NSNumberFormatter *nf = [[self class] precisionNumberFormatter];
            nf.maximumFractionDigits = location.precision;
            nf.minimumFractionDigits = location.precision;
            geoDict[@"lat"] = [nf numberFromString:[NSString stringWithFormat:@"%f", location.latitude]];
            geoDict[@"lon"] = [nf numberFromString:[NSString stringWithFormat:@"%f", location.longitude]];
        } else {
            geoDict[@"lat"] = @(latitude);
            geoDict[@"lon"] = @(longitude);
        }
        
        NSDate *locationTimestamp = location.timestamp;
        NSTimeInterval ageInSeconds = -1.0 * [locationTimestamp timeIntervalSinceNow];
        NSInteger ageInMilliseconds = (NSInteger)(ageInSeconds * 1000);
        
        geoDict[@"lastfix"] = @(ageInMilliseconds);
        geoDict[@"accuracy"] = @((NSInteger)location.horizontalAccuracy);
        
        return [geoDict copy];
    } else {
        return nil;
    }
}

// OpenRTB 2.5 Object: User in section 3.2.20
- (NSDictionary *)openrtbUser {
    NSMutableDictionary *userDict = [[NSMutableDictionary alloc] init];

    NSInteger ageValue = [[PBTargetingParams sharedInstance] age];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger year = [components year];
    if (ageValue > 0) {
        userDict[@"yob"] = @(year - ageValue);
    }

    PBTargetingParamsGender genderValue = [[PBTargetingParams sharedInstance] gender];
    NSString *gender;
    switch (genderValue) {
        case PBTargetingParamsGenderMale:
            gender = @"M";
            break;
        case PBTargetingParamsGenderFemale:
            gender = @"F";
            break;
        default:
            gender = @"O";
            break;
    }
    userDict[@"gender"] = gender;

    return [userDict copy];
}

+ (NSNumberFormatter *)precisionNumberFormatter {
    static dispatch_once_t precisionNumberFormatterToken;
    static NSNumberFormatter *precisionNumberFormatter;
    dispatch_once(&precisionNumberFormatterToken, ^{
        precisionNumberFormatter = [[NSNumberFormatter alloc] init];
        precisionNumberFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    });
    return precisionNumberFormatter;
}

@end
