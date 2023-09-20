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

#import "PBMMacros.h"
#import "PBMORTB.h"

#import "PBMSKAdNetworksParameterBuilder.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

#pragma mark - Internal Extension
@interface PBMSKAdNetworksParameterBuilder()

//Keys into Bundle info Dict
@property (nonatomic, class, readonly) NSString *SKAdNetworkItemsKey;
@property (nonatomic, class, readonly) NSString *SKAdNetworkIdentifierKey;

@property (nonatomic, strong, readonly) id<PBMBundleProtocol> bundle;
@property (nonatomic, strong, readonly) Targeting *targeting;
@property (nonatomic, strong, readwrite) PBMAdConfiguration *adConfiguration;

@end

#pragma mark - Implementation

@implementation PBMSKAdNetworksParameterBuilder

#pragma mark - Properties

//Keys into Bundle info Dict
+ (NSString *)SKAdNetworkItemsKey {
    return @"SKAdNetworkItems";
}

+ (NSString *)SKAdNetworkIdentifierKey {
    return @"SKAdNetworkIdentifier";
}

#pragma mark - Initialization

- (nonnull instancetype)initWithBundle:(id<PBMBundleProtocol>)bundle
                             targeting:(Targeting *)targeting
                       adConfiguration:(PBMAdConfiguration *)adConfiguration {
    if (!(self = [super init])) {
        return nil;
    }
    PBMAssert(bundle && targeting);
    _bundle = bundle;
    _targeting = targeting;
    _adConfiguration = adConfiguration;
    
    return self;
}

#pragma mark - PBMParameterBuilder

- (void)buildBidRequest:(PBMORTBBidRequest *)bidRequest {   
    if (!(self.bundle && bidRequest)) {
        PBMLogError(@"Invalid properties");
        return;
    }
    
    NSArray<NSString *> *skadnetids = [self SKAdNetworkIds];
    if (!skadnetids) {
        return;
    }
    
    NSString *sourceapp = self.targeting.sourceapp;
    if (!sourceapp) {
        PBMLogError(@"Info.plist contains SKAdNetwork but sourceapp is nil!");
    }
    
    if (!self.adConfiguration.isOriginalAPI) {
        for (PBMORTBImp *imp in bidRequest.imp) {
            imp.extSkadn.sourceapp = [sourceapp copy];
            imp.extSkadn.skadnetids = skadnetids;
        }
    }
}

/**
 Returns an array of SKAdNetwork ids or nil
 */
- (NSArray<NSString *> *)SKAdNetworkIds {
    if (@available(iOS 14.0, *)) {
        NSDictionary* infoDict = self.bundle.infoDictionary;
        NSArray* skadNetworks = infoDict[PBMSKAdNetworksParameterBuilder.SKAdNetworkItemsKey];
        if (skadNetworks) {
            NSMutableArray<NSString *> *networkIds = [NSMutableArray<NSString *> arrayWithCapacity:skadNetworks.count];
            [skadNetworks enumerateObjectsUsingBlock:^(NSDictionary *itemDict, NSUInteger idx, BOOL *stop) {
                [networkIds addObject:itemDict[PBMSKAdNetworksParameterBuilder.SKAdNetworkIdentifierKey]];
            }];
            return [networkIds copy];
        }
    }
    return nil;
}

@end
