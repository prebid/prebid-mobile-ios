//
//  OXASKAdNetworksParameterBuilder.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMLog.h"
#import "OXMMacros.h"
#import "OXMORTB.h"

#import "OXASKAdNetworksParameterBuilder.h"

#pragma mark - Internal Extension
@interface OXASKAdNetworksParameterBuilder()

//Keys into Bundle info Dict
@property (nonatomic, class, readonly) NSString *SKAdNetworkItemsKey;
@property (nonatomic, class, readonly) NSString *SKAdNetworkIdentifierKey;

@property (nonatomic, strong, readonly) id<OXMBundleProtocol> bundle;
@property (nonatomic, strong, readonly) OXATargeting *targeting;
@end

#pragma mark - Implementation

@implementation OXASKAdNetworksParameterBuilder

#pragma mark - Properties

//Keys into Bundle info Dict
+ (NSString *)SKAdNetworkItemsKey {
    return @"SKAdNetworkItems";
}

+ (NSString *)SKAdNetworkIdentifierKey {
    return @"SKAdNetworkIdentifier";
}

#pragma mark - Initialization

- (nonnull instancetype)initWithBundle:(id<OXMBundleProtocol>)bundle targeting:(OXATargeting *)targeting {
    if (!(self = [super init])) {
        return nil;
    }
    OXMAssert(bundle && targeting);
    _bundle = bundle;
    _targeting = targeting;
    
    return self;
}

#pragma mark - OXMParameterBuilder

- (void)buildBidRequest:(OXMORTBBidRequest *)bidRequest {   
    if (!(self.bundle && bidRequest)) {
        OXMLogError(@"Invalid properties");
        return;
    }
    
    NSArray<NSString *> *skadnetids = [self SKAdNetworkIds];
    if (!skadnetids) {
        return;
    }
    
    NSString *sourceapp = self.targeting.sourceapp;
    if (!sourceapp) {
        OXMLogError(@"Info.plist contains SKAdNetwork but sourceapp is nil!");
    }
    
    for (OXMORTBImp *imp in bidRequest.imp) {
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
        NSArray* skadNetworks = infoDict[OXASKAdNetworksParameterBuilder.SKAdNetworkItemsKey];
        if (skadNetworks) {
            NSMutableArray<NSString *> *networkIds = [NSMutableArray<NSString *> arrayWithCapacity:skadNetworks.count];
            [skadNetworks enumerateObjectsUsingBlock:^(NSDictionary *itemDict, NSUInteger idx, BOOL *stop) {
                [networkIds addObject:itemDict[OXASKAdNetworksParameterBuilder.SKAdNetworkIdentifierKey]];
            }];
            return [networkIds copy];
        }
    }
    return nil;
}

@end
