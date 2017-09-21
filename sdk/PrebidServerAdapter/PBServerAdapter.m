/*   Copyright 2017 APPNEXUS INC
 
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

#import <arpa/inet.h>
#import <AdSupport/AdSupport.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <ifaddrs.h>
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
static NSString *const kPrebidMobileVersion = @"0.0.3";

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
    [[PBServerFetcher sharedInstance] makeBidRequest:request withCompletionHandler:^(NSDictionary *adUnitToBidsMap, NSError *error) {
        if (error) {
            [delegate didCompleteWithError:error];
            return;
        }
        for (NSString *adUnitId in [adUnitToBidsMap allKeys]) {
            NSArray *bidsArray = (NSArray *)[adUnitToBidsMap objectForKey:adUnitId];
            NSMutableArray *bidResponsesArray = [[NSMutableArray alloc] init];
            for (NSDictionary *bid in bidsArray) {
                PBBidResponse *bidResponse = [PBBidResponse bidResponseWithAdUnitId:adUnitId adServerTargeting:bid[@"ad_server_targeting"]];
                PBLogDebug(@"Bid Successful with rounded bid targeting keys are %@ for adUnit id is %@", bidResponse.customKeywords, adUnitId);
                [bidResponsesArray addObject:bidResponse];
            }
            [delegate didReceiveSuccessResponse:bidResponsesArray];
        }
    }];
}

- (NSURLRequest *)buildRequestForAdUnits:(NSArray<PBAdUnit *> *)adUnits {
    NSURL *url = [NSURL URLWithString:@"https://prebid.adnxs.com/pbs/v1/auction"];
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:url
                                                                       cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                   timeoutInterval:1000];
    [mutableRequest setHTTPMethod:@"POST"];
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:[self requestBodyForAdUnits:adUnits]
                                                       options:kNilOptions
                                                         error:&error];
    if (!error) {
        [mutableRequest setHTTPBody:postData];
        return [mutableRequest copy];
    } else {
        return nil;
    }
}

- (NSDictionary *)requestBodyForAdUnits:(NSArray<PBAdUnit *> *)adUnits {
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    
    requestDict[@"cache_markup"] = @(1);
    requestDict[@"sort_bids"] = @(1);
    // need this so DFP targeting keys aren't too long
    requestDict[@"max_key_length"] = @(20);
    requestDict[@"account_id"] = self.accountId;
    requestDict[@"tid"] = [[NSUUID UUID] UUIDString];
    requestDict[@"prebid_version"] = @"0.21.0-pre";
    
    requestDict[@"sdk"] = @{@"source": @"prebid-mobile",
                            @"version": kPrebidMobileVersion,
                            @"platform": @"iOS"};

    NSDictionary *user = [self user];
    if (user) {
        requestDict[@"user"] = user;
    }
    NSDictionary *device = [self device];
    if (device) {
        requestDict[@"device"] = device;
    }
    NSDictionary *appID = [self app];
    if (appID != nil) {
        requestDict[@"app"] = appID;
    }
    NSArray *keywords = [self keywords];
    if (keywords) {
        requestDict[@"keywords"] = keywords;
    }
    
    NSMutableArray *adUnitConfigs = [[NSMutableArray alloc] init];
    for (PBAdUnit *adUnit in adUnits) {
        NSMutableDictionary *adUnitConfig = [[NSMutableDictionary alloc] init];
        adUnitConfig[@"code"] = adUnit.identifier;
        
        NSMutableArray *sizeArray = [[NSMutableArray alloc] initWithCapacity:adUnit.adSizes.count];
        for (id size in adUnit.adSizes) {
            CGSize arSize = [size CGSizeValue];
            NSDictionary *sizeDict = [NSDictionary dictionaryWithObjectsAndKeys:@(arSize.width), @"w", @(arSize.height), @"h", nil];
            [sizeArray addObject:sizeDict];
        }
        adUnitConfig[@"sizes"] = sizeArray;
        
        adUnitConfig[@"config_id"] = adUnit.configId;
        [adUnitConfigs addObject:adUnitConfig];
    }
    requestDict[@"ad_units"] = adUnitConfigs;
    
    return [requestDict copy];
}

- (NSDictionary *)user {
    NSMutableDictionary *userDict = [[NSMutableDictionary alloc] init];
    
    NSInteger ageValue = [[PBTargetingParams sharedInstance] age];
    if (ageValue > 0) {
        userDict[@"age"] = @(ageValue);
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
    
    NSString *language = [NSLocale preferredLanguages][0];
    if (language.length) {
        userDict[@"language"] = language;
    }
    
    return [userDict copy];
}

- (NSArray *)keywords {
    NSDictionary *customKeywords = [[PBTargetingParams sharedInstance] customKeywords];
    if (customKeywords.count < 1) {
        return nil;
    }
    
    NSMutableArray *kvSegmentsArray = [[NSMutableArray alloc] init];
    
    [customKeywords enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *stringKey = PBSConvertToNSString(key);
        NSArray *arrayValue = PBSConvertToNSArray(value);
        if (stringKey.length > 0 && arrayValue.count > 0) {
            [kvSegmentsArray addObject:@{ @"key": stringKey,
                                          @"value": arrayValue }];
        }
    }];
    return [kvSegmentsArray copy];
}

- (NSDictionary *)device {
    NSMutableDictionary *deviceDict = [[NSMutableDictionary alloc] init];
    
    NSString *userAgent = PBSUserAgent();
    if (userAgent) {
        deviceDict[@"ua"] = userAgent;
    }
    
    NSDictionary *geo = [self geo];
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
    deviceDict[@"ip"] = [self getIPAddress];
    
    NSInteger timeInMiliseconds = (NSInteger)[[NSDate date] timeIntervalSince1970];
    deviceDict[@"devtime"] = @(timeInMiliseconds);
    
    return [deviceDict copy];
}

// Get IP Address
- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

- (NSDictionary *)geo {
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

- (NSDictionary *)app {
    if ([[PBTargetingParams sharedInstance] itunesID] != nil) {
        NSString *itunesid = [[PBTargetingParams sharedInstance] itunesID];
        return @{ @"appid": itunesid, @"ver": kPrebidMobileVersion };
    } else {
        NSString *appId = [[NSBundle mainBundle] bundleIdentifier];
        if (appId == nil) {
            appId = @"";
        }
        return @{ @"bundle": appId, @"ver": kPrebidMobileVersion };
    }
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
