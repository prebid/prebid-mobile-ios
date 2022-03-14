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
#import "DemandRequestBuilder.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <AdSupport/AdSupport.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
@import PrebidMobile;


static NSString *const kPrebidMobileVersion = @"0.5.3";

@implementation DemandRequestBuilder

- (NSURLRequest *_Nullable)buildRequest:(nullable NSArray<AdUnit *> *)adUnits withAccountId:(NSString *) accountID withSecureParams:(BOOL) isSecure {
    
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

- (NSDictionary *)openRTBRequestBodyForAdUnits:(NSArray<AdUnit *> *)adUnits withAccountId:(NSString *) accountID withSecureParams:(BOOL) isSecure{
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    
    requestDict[@"id"] = [[NSUUID UUID] UUIDString];
    requestDict[@"source"] = [self openrtbSource];
    requestDict[@"app"] = [self openrtbApp:accountID];
    requestDict[@"device"] = [self openrtbDevice];
    if ([Targeting.shared getSubjectToGDPR]){
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

- (NSDictionary *)openrtbRequestExtension: (NSString *)accountId
{
    NSMutableDictionary *requestPrebidExt = [[NSMutableDictionary alloc] init];
    requestPrebidExt[@"targeting"] = @{};
    requestPrebidExt[@"storedrequest"] = @{@"id" :accountId};
    requestPrebidExt[@"cache"] = @{@"bids" : [[NSMutableDictionary alloc] init]};
    NSMutableDictionary *requestExt = [[NSMutableDictionary alloc] init];
    requestExt[@"prebid"] = requestPrebidExt;
    return [requestExt copy];
}

- (NSArray *)openrtbImpsFromAdUnits:(NSArray<AdUnit *> *)adUnits withSecureSettings:(BOOL) isSecure {
    NSMutableArray *imps = [[NSMutableArray alloc] init];
    
    for (AdUnit *adUnit in adUnits) {
        NSMutableDictionary *imp = [[NSMutableDictionary alloc] init];
        imp[@"id"] = [[NSUUID UUID] UUIDString];
        if(isSecure){
            imp[@"secure"] = @1;
        }
        NSMutableArray *sizeArray = [[NSMutableArray alloc] initWithCapacity:self.adSizes.count];
        for (id size in self.adSizes) {
            CGSize arSize = [size CGSizeValue];
            NSDictionary *sizeDict = [NSDictionary dictionaryWithObjectsAndKeys:@(arSize.width), @"w", @(arSize.height), @"h", nil];
            [sizeArray addObject:sizeDict];
        }
        
        if ([adUnit isKindOfClass:[NativeRequest class]]) {
            NativeRequest *request = (NativeRequest *)adUnit;
            imp[@"native"] = [request getNativeRequestObject];
        } else {
            if ([adUnit isKindOfClass:[InterstitialAdUnit class]]) {
                imp[@"instl"] = @(1);
                NSDictionary *sizeDict = [NSDictionary dictionaryWithObjectsAndKeys:@([[UIScreen mainScreen] bounds].size.width), @"w", @([[UIScreen mainScreen] bounds].size.height), @"h", nil];
                [sizeArray addObject:sizeDict];
            }

            NSDictionary *formats = @{@"format": sizeArray};
            imp[@"banner"] = formats;
        }
        //to be used when openRTB supports storedRequests
        NSMutableDictionary *prebidAdUnitExt = [[NSMutableDictionary alloc] init];
        prebidAdUnitExt[@"storedrequest"] = @{@"id" : self.configId};
        
//        TODO: use it for  testing
//        prebidAdUnitExt[@"storedauctionresponse"] = @{@"id" : @"1001-rubicon-300x250"};
        
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
    
    NSString *bundle = Targeting.shared.itunesID;
    if (bundle == nil) {
        bundle = [[NSBundle mainBundle] bundleIdentifier];
    }
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
    
    NSDictionary *geo = [self openrtbGeo];
    if (geo) {
        deviceDict[@"geo"] = geo;
    }
    
    deviceDict[@"make"] = @"Apple";
    deviceDict[@"os"] = @"iOS";
    deviceDict[@"osv"] = [[UIDevice currentDevice] systemVersion];
    deviceDict[@"h"] = @([[UIScreen mainScreen] bounds].size.height);
    deviceDict[@"w"] = @([[UIScreen mainScreen] bounds].size.width);
    
    deviceDict[@"model"] = UIDevice.currentDevice.model;
    
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    
    if (carrier.carrierName.length > 0) {
        deviceDict[@"carrier"] = carrier.carrierName;
    }
    
    deviceDict[@"connectiontype"] = @(1);
    
    if (carrier.mobileCountryCode.length > 0 && carrier.mobileNetworkCode.length > 0) {
        deviceDict[@"mccmnc"] = [[carrier.mobileCountryCode stringByAppendingString:@"-"] stringByAppendingString:carrier.mobileNetworkCode];
    }
    // Limit ad tracking
    deviceDict[@"lmt"] = @(![[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]);
    
    
    NSString *deviceId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
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
    
        return nil;
}

-(NSDictionary *) openrtbRegs {
    
    NSMutableDictionary *regsDict = [[NSMutableDictionary alloc] init];
    
    BOOL gdpr = [[Targeting shared] getSubjectToGDPR];
    
    regsDict[@"ext"] = @{@"gdpr" : @(@(gdpr).integerValue)};
    
    return regsDict;
}

// OpenRTB 2.5 Object: User in section 3.2.20
- (NSDictionary *)openrtbUser {
    NSMutableDictionary *userDict = [[NSMutableDictionary alloc] init];
    
    NSInteger ageValue = Targeting.shared.yearOfBirth;
    if (ageValue > 0) {
        userDict[@"yob"] = @(ageValue);
    }
    
    NSString *gender;
    switch ([[Targeting shared] userGender]) {
        case GenderMale:
            gender = @"M";
            break;
        case GenderFemale:
            gender = @"F";
            break;
        default:
            gender = @"O";
            break;
    }
    userDict[@"gender"] = gender;
    
    if([[Targeting shared] getSubjectToGDPR]){
        
        NSString *consentString = [[Targeting shared] gdprConsentString];
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
