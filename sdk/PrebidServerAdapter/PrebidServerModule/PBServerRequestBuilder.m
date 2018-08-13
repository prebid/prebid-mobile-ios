/*   Copyright 2018 Prebid.org, Inc.
 
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

#import "PBServerRequestBuilder.h"
#import "PBServerGlobal.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "PBServerReachability.h"
#import "PBTargetingParams.h"
#import "PBConfig.h"
#import "PBServerLocation.h"


static NSString *const kPrebidMobileVersion = @"0.4";

@implementation PBServerRequestBuilder

+ (instancetype)sharedInstance {
    static dispatch_once_t _dispatchHandle = 0;
    static PBServerRequestBuilder *_sharedInstance = nil;
    
    dispatch_once(&_dispatchHandle, ^{
        if (_sharedInstance == nil)
            _sharedInstance = [[PBServerRequestBuilder alloc] init];
        
    });
    return _sharedInstance;
}

- (NSURLRequest *_Nullable)buildRequest:(nullable NSArray<PBAdUnit *> *)adUnits withAccountId:(NSString *) accountID withSecureParams:(BOOL) isSecure {
    
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:self.hostURL
                                                                       cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                   timeoutInterval:1000];
    [mutableRequest setHTTPMethod:@"POST"];
    NSDictionary *requestBody = [self openRTBRequestBodyForAdUnits:adUnits withAccountId:accountID withSecureParams:isSecure];
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

- (NSDictionary *)openRTBRequestBodyForAdUnits:(NSArray<PBAdUnit *> *)adUnits withAccountId:(NSString *) accountID withSecureParams:(BOOL) isSecure{
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    
    requestDict[@"id"] = [[NSUUID UUID] UUIDString];
    requestDict[@"source"] = [self openrtbSource];
    requestDict[@"app"] = [self openrtbApp:accountID];
    requestDict[@"device"] = [self openrtbDevice];
    if([[PBTargetingParams sharedInstance] isGDPREnabled] == YES){
        requestDict[@"regs"] = [self openrtbRegs];
    }
    requestDict[@"user"] = [self openrtbUser];
    requestDict[@"imp"] = [self openrtbImpsFromAdUnits:adUnits withSecureSettings:isSecure];
    requestDict[@"ext"] = [self openrtbRequestExtension:accountID];
    
    return [requestDict copy];
}

- (NSDictionary *) openrtbSource {
    
    NSMutableDictionary *sourceDict = [[NSMutableDictionary alloc] init];
    sourceDict[@"tid"] = @"123";
    
    return sourceDict;
}

- (NSDictionary *)openrtbRequestExtension:(NSString *) accountId
{
    NSMutableDictionary *requestPrebidExt = [[NSMutableDictionary alloc] init];
    
    NSString *priceGranularityValue = [[PBConfig sharedInstance] priceGranularity];
    if (priceGranularityValue) {
        requestPrebidExt[@"targeting"] = @{@"lengthmax" : @(20), @"pricegranularity":priceGranularityValue};
    } else {
        requestPrebidExt[@"targeting"] = @{};
    } 
 
    NSString *storeRequestIdValue = [[PBConfig sharedInstance] storeRequestId];
    if (storeRequestIdValue) {
        requestPrebidExt[@"storedrequest"] = @{@"id":storeRequestIdValue};
    } else {
        requestPrebidExt[@"storedrequest"] = @{@"id" :accountId};
    }
 
    NSMutableDictionary *requestExt = [[NSMutableDictionary alloc] init];
    requestExt[@"prebid"] = requestPrebidExt;
    return [requestExt copy];
}

- (NSArray *)openrtbImpsFromAdUnits:(NSArray<PBAdUnit *> *)adUnits withSecureSettings:(BOOL) isSecure {
    NSMutableArray *imps = [[NSMutableArray alloc] init];
    
    for (PBAdUnit *adUnit in adUnits) {
        NSMutableDictionary *imp = [[NSMutableDictionary alloc] init];
        imp[@"id"] = adUnit.identifier;
        if(isSecure){
            imp[@"secure"] = @1;
        }
        NSMutableArray *sizeArray = [[NSMutableArray alloc] initWithCapacity:adUnit.adSizes.count];
        for (id size in adUnit.adSizes) {
            CGSize arSize = [size CGSizeValue];
            NSDictionary *sizeDict = [NSDictionary dictionaryWithObjectsAndKeys:@(arSize.width), @"w", @(arSize.height), @"h", nil];
            [sizeArray addObject:sizeDict];
        }
        NSDictionary *formats = @{@"format": sizeArray};
        imp[@"banner"] = formats;
        
        if (adUnit.adType == PBAdUnitTypeInterstitial) {
            imp[@"instl"] = @(1);
        }
        
        //to be used when openRTB doesnt support storedRequests
        /*NSMutableDictionary *placementDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@9924885,@"placementId", nil];
         
         NSMutableDictionary *vendorDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:placementDict,@"appnexus", nil];
         imp[@"ext"] = vendorDict;*/
        
        //to be used when openRTB supports storedRequests
        NSMutableDictionary *prebidAdUnitExt = [[NSMutableDictionary alloc] init];
        prebidAdUnitExt[@"storedrequest"] = @{@"id" : adUnit.configId};
        
        NSMutableDictionary *adUnitExt = [[NSMutableDictionary alloc] init];
        adUnitExt[@"prebid"] = prebidAdUnitExt;
        
        imp[@"ext"] = adUnitExt;
        
        
        [imps addObject:imp];
    }
    return [imps copy];
}

// OpenRTB 2.5 Object: App in section 3.2.14
- (NSDictionary *)openrtbApp:(NSString *) accountId {
    NSMutableDictionary *app = [[NSMutableDictionary alloc] init];
    
    NSString *bundle = [[NSBundle mainBundle] bundleIdentifier];
    if (bundle) {
        app[@"bundle"] = bundle;
    }
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (version) {
        app[@"ver"] = version;
    }
    
    app[@"publisher"] = @{@"id": accountId};
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

-(NSDictionary *) openrtbRegs {
    
    NSMutableDictionary *regsDict = [[NSMutableDictionary alloc] init];
    
    BOOL gdpr = [[PBTargetingParams sharedInstance] subjectToGDPR];
    
    regsDict[@"ext"] = @{@"gdpr" : @(@(gdpr).integerValue)};
    
    return regsDict;
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
    
    NSDictionary<NSString *, NSArray *> * targetingParams = [[PBTargetingParams sharedInstance] userKeywords];
    
    NSString *keywordString = [self fetchKeywordsString:targetingParams];
    
    if(![keywordString isEqualToString:@""]){
        userDict[@"keywords"] = keywordString;
    }
    
    if([[PBTargetingParams sharedInstance] isGDPREnabled] == YES){
    
        NSString *consentString = [[PBTargetingParams sharedInstance] gdprConsentString];
        if(consentString != nil){
            userDict[@"ext"] = @{@"consent" : consentString};
        }
        
    }
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

-(NSString *) fetchKeywordsString:(NSDictionary *) kewordsDictionary {
    
    NSString *keywordString = @"";
    
    for (NSString *key in kewordsDictionary.allKeys) {
        
        NSArray *values = kewordsDictionary[key];
        
        for (NSString *value in values) {
            
            NSString *keyvalue = @"";
            
            if([value isEqualToString:@""]){
                keyvalue = key;
            } else {
                keyvalue = [NSString stringWithFormat:@"%@=%@", key, value];
            }
            
            if([keywordString isEqualToString:@""]){
                
                keywordString = keyvalue;
                
            } else {
                
                keywordString = [NSString stringWithFormat:@"%@,%@", keywordString, keyvalue];
                
            }
            
        }
    }
    
    return keywordString;
}

@end
