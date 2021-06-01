//
//  PBMSKAdNetworksParameterBuilder.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMLog.h"
#import "PBMMacros.h"
#import "PBMORTB.h"

#import "PBMSKAdNetworksParameterBuilder.h"

#import "PrebidMobileRenderingSwiftHeaders.h"
#import <PrebidMobileRendering/PrebidMobileRendering-Swift.h>

#pragma mark - Internal Extension
@interface PBMSKAdNetworksParameterBuilder()

//Keys into Bundle info Dict
@property (nonatomic, class, readonly) NSString *SKAdNetworkItemsKey;
@property (nonatomic, class, readonly) NSString *SKAdNetworkIdentifierKey;

@property (nonatomic, strong, readonly) id<PBMBundleProtocol> bundle;
@property (nonatomic, strong, readonly) PrebidRenderingTargeting *targeting;
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

- (nonnull instancetype)initWithBundle:(id<PBMBundleProtocol>)bundle targeting:(PrebidRenderingTargeting *)targeting {
    if (!(self = [super init])) {
        return nil;
    }
    PBMAssert(bundle && targeting);
    _bundle = bundle;
    _targeting = targeting;
    
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
    
    for (PBMORTBImp *imp in bidRequest.imp) {
        imp.extSkadn.sourceapp = [sourceapp copy];
        imp.extSkadn.skadnetids = skadnetids;
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
