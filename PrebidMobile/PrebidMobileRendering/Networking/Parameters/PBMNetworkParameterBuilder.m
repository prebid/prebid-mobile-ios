/*   Copyright 2018-2021 Prebid.org, Inc.

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

#import "PBMNetworkParameterBuilder.h"

#import <CoreTelephony/CTCarrier.h>

#import "PBMORTB.h"
#import "PBMMacros.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

#pragma mark - Internal Extension

@interface PBMNetworkParameterBuilder ()

@property (nonatomic, strong) CTTelephonyNetworkInfo *ctTelephonyNetworkInfo;
@property (nonatomic, strong) PBMReachability *reachability;

@end

#pragma mark - Implementation

@implementation PBMNetworkParameterBuilder

#pragma mark - Initialization
- (instancetype)initWithCtTelephonyNetworkInfo:(CTTelephonyNetworkInfo *)ctTelephonyNetworkInfo reachability:(PBMReachability *)reachability {
    self = [super init];
    if (self) {
        PBMAssert(ctTelephonyNetworkInfo && reachability);
        self.ctTelephonyNetworkInfo = ctTelephonyNetworkInfo;
        self.reachability = reachability;
    }
    
    return self;
}

#pragma mark - PBMParameterBuilder

- (void)buildBidRequest:(PBMORTBBidRequest *)bidRequest {
    if (!(self.ctTelephonyNetworkInfo && bidRequest)) {
        PBMLogError(@"Invalid properties");
        return;
    }
    
    // reachability type
    PBMNetworkType networkStatus = [self.reachability currentReachabilityStatus];
    bidRequest.device.connectiontype = [NSNumber numberWithInteger:networkStatus];
    
    [self setCarrierIn:bidRequest];
}

- (void)setCarrierIn:(PBMORTBBidRequest *)bidRequest {
    CTCarrier * carrier;
    
    if (@available(iOS 16.0, *)) {
        // do nothing - CTCarrier is deprecated with no replacement
    } else if (@available(iOS 12.0, *)) {
        carrier = [[self.ctTelephonyNetworkInfo.serviceSubscriberCellularProviders allValues] firstObject];
    } else {
        // Fallback on earlier versions
        carrier = self.ctTelephonyNetworkInfo.subscriberCellularProvider;
    }
    
    if (!carrier) {
        return;
    }
    
    //Update params dict
    NSString *countryCode = carrier.mobileCountryCode;
    NSString *carrierCode = carrier.mobileNetworkCode;
    if (countryCode && carrierCode) {
        NSString *mccmnc = [NSString stringWithFormat:@"%@-%@", countryCode, carrierCode];
        bidRequest.device.mccmnc = mccmnc;
    }
    
    //Update ORTB
    // carrier
    bidRequest.device.carrier = carrier.carrierName;
}

@end
