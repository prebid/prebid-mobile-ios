//
//  PBMNetworkParameterBuilder.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMNetworkParameterBuilder.h"

#import<CoreTelephony/CTCarrier.h>

#import "PBMORTB.h"
#import "PBMMacros.h"

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
    
    CTCarrier *carrier = self.ctTelephonyNetworkInfo.subscriberCellularProvider;
    if (!carrier) {
        return;
    }
    
    // reachability type
    PBMNetworkType networkStatus = [self.reachability currentReachabilityStatus];
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
