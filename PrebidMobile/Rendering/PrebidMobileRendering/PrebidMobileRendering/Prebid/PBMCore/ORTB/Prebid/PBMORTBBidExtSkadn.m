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

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#import "PBMORTBAbstract+Protected.h"
#import "PBMORTBBidExtSkadn.h"

@interface PBMORTBSkadnFidelity ()

- (NSDictionary<NSString *, id> * _Nullable) getSkadnInfo;

@end

@implementation PBMORTBBidExtSkadn

- (instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary {
    if (self = [super init]) {
        _version = jsonDictionary[@"version"];
        _network = jsonDictionary[@"network"];
        _campaign = jsonDictionary[@"campaign"];
        _itunesitem = jsonDictionary[@"itunesitem"];
        _nonce = [[NSUUID alloc] initWithUUIDString:jsonDictionary[@"nonce"]];
        _sourceapp = jsonDictionary[@"sourceapp"];
        _timestamp = jsonDictionary[@"timestamp"];
        _signature = jsonDictionary[@"signature"];
        
        NSMutableArray<PBMORTBSkadnFidelity *> *fidelities = [NSMutableArray<PBMORTBSkadnFidelity *> new];
        NSMutableArray<PBMJsonDictionary *> *fidelitiesData = jsonDictionary[@"fidelities"];
        
        for (PBMJsonDictionary *fidelityData in fidelitiesData) {
            if (fidelityData && [fidelityData isKindOfClass:[NSDictionary class]])
                [fidelities addObject:[[PBMORTBSkadnFidelity alloc] initWithJsonDictionary:fidelityData]];
        }
        
        _fidelities = fidelities;
    }
    return self;
}

- (PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary * const ret = [[PBMMutableJsonDictionary alloc] init];
    
    ret[@"version"] = self.version;
    ret[@"network"] = self.network;
    ret[@"campaign"] = self.campaign;
    ret[@"itunesitem"] = self.itunesitem;
    ret[@"nonce"] = [self.nonce UUIDString];
    ret[@"sourceapp"] = self.sourceapp;
    ret[@"timestamp"] = self.timestamp;
    ret[@"signature"] = self.signature;
    ret[@"fidelities"] = self.fidelities;
    [ret pbmRemoveEmptyVals];
    
    return ret;
}

- (NSMutableDictionary<NSString *, id> * _Nullable) getSkadnInfo {
    if (@available(iOS 14.0, *)) {
        NSMutableDictionary<NSString * , id> *productParams = [[NSMutableDictionary alloc] init];
        
        if (self.itunesitem != nil &&
            self.network != nil &&
            self.campaign != nil &&
            self.version != nil &&
            self.sourceapp != nil) {
            [productParams setValue:SKStoreProductParameterITunesItemIdentifier forKey:self.itunesitem.stringValue];
            [productParams setValue:SKStoreProductParameterAdNetworkIdentifier forKey:self.network];
            [productParams setValue:SKStoreProductParameterAdNetworkCampaignIdentifier forKey:self.campaign.stringValue];
            [productParams setValue:SKStoreProductParameterAdNetworkVersion forKey:self.version];
            [productParams setValue:SKStoreProductParameterAdNetworkSourceAppStoreIdentifier forKey:self.sourceapp.stringValue];
            
            if(self.timestamp != nil &&
               self.nonce != nil &&
               self.signature != nil) {
                [productParams setValue:SKStoreProductParameterAdNetworkTimestamp forKey:self.timestamp.stringValue];
                [productParams setValue:SKStoreProductParameterAdNetworkNonce forKey:self.nonce.UUIDString];
                [productParams setValue:SKStoreProductParameterAdNetworkAttributionSignature forKey:self.signature];
            }
            
            return productParams;
        }
    }
    return nil;
}

- (NSMutableDictionary<NSString *, id> * _Nullable) getSkadnProductParameters {
    NSMutableDictionary<NSString *, id> * _Nullable productParams = self.getSkadnInfo;
    if (@available(iOS 14.5, *)) {
        if (self.fidelities != nil) {
            for(PBMORTBSkadnFidelity *fid in self.fidelities) {
                if ([fid.fidelity isEqual:@1]) {
                    [productParams setValue:SKStoreProductParameterAdNetworkTimestamp forKey: fid.timestamp.stringValue];
                    [productParams setValue:SKStoreProductParameterAdNetworkNonce forKey: fid.nonce.UUIDString];
                    [productParams setValue:SKStoreProductParameterAdNetworkAttributionSignature forKey: fid.signature];
                }
            }
        }
    }
    
    return productParams;
}

@end
