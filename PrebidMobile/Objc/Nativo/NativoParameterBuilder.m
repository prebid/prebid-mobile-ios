//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    

#import "NativoParameterBuilder.h"
#import "PBMORTB.h"
#import "SwiftImport.h"
#import "NativoORTBDevice.h"
#import "PBMORTBAbstract+Protected.h"


@interface NativoParameterBuilder ()
@property (nonatomic, strong, nonnull, readonly) AdUnitConfig *adConfiguration;
@end

@implementation NativoParameterBuilder

- (instancetype)initWithAdConfiguration:(AdUnitConfig *)adConfiguration {
    _adConfiguration = adConfiguration;
    return self;
}

// Add tagid to imp for placement mapping
- (void)buildBidRequest:(nonnull PBMORTBBidRequest *)bidRequest {
    // TEMP - add IP until Nativo ad server dynamically finds it
    NativoORTBDevice *device = [[NativoORTBDevice alloc]
                                initWithJsonDictionary:[bidRequest.device toJsonDictionary]];
    device.ip = @"108.214.18.218";
    bidRequest.device = device;
    
    // Set tagid
    for (PBMORTBImp *nextImp in bidRequest.imp) {
        nextImp.tagid = self.adConfiguration.configId;
    }
}


@end

