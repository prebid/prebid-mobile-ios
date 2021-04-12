//
//  OXMNetworkParameterBuilder.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMNetworkParameterBuilder.h"

#import<CoreTelephony/CTCarrier.h>

#import "OXMORTB.h"
#import "OXMMacros.h"

#pragma mark - Internal Extension

@interface OXMNetworkParameterBuilder ()

@property (nonatomic, strong) CTTelephonyNetworkInfo *ctTelephonyNetworkInfo;
@property (nonatomic, strong) OXMReachability *reachability;

@end

#pragma mark - Implementation

@implementation OXMNetworkParameterBuilder

#pragma mark - Initialization
- (instancetype)initWithCtTelephonyNetworkInfo:(CTTelephonyNetworkInfo *)ctTelephonyNetworkInfo reachability:(OXMReachability *)reachability {
    self = [super init];
    if (self) {
        OXMAssert(ctTelephonyNetworkInfo && reachability);
        self.ctTelephonyNetworkInfo = ctTelephonyNetworkInfo;
        self.reachability = reachability;
    }
    
    return self;
}

#pragma mark - OXMParameterBuilder

- (void)buildBidRequest:(OXMORTBBidRequest *)bidRequest {
    if (!(self.ctTelephonyNetworkInfo && bidRequest)) {
        OXMLogError(@"Invalid properties");
        return;
    }
    
    CTCarrier *carrier = self.ctTelephonyNetworkInfo.subscriberCellularProvider;
    if (!carrier) {
        return;
    }
    
    // reachability type
    OXANetworkType networkStatus = [self.reachability currentReachabilityStatus];
    bidRequest.device.connectiontype = [NSNumber numberWithInteger:networkStatus];
    
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
