//
//  OXMAppInfoParameterBuilder.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMConstants.h"
#import "OXMLog.h"
#import "OXMMacros.h"
#import "OXMORTB.h"
#import "OXMORTBBidRequest.h"
#import "OXASDKConfiguration.h"

#import "OXMAppInfoParameterBuilder.h"

#pragma mark - Internal Extension

@interface OXMAppInfoParameterBuilder ()

@property (nonatomic, strong, readonly) id<OXMBundleProtocol> bundle;
@property (nonatomic, strong, readonly) OXATargeting *targeting;

@end

#pragma mark - Implementation

@implementation OXMAppInfoParameterBuilder

#pragma mark - Properties

//Keys into Bundle info Dict
+ (NSString *)bundleNameKey {
    return @"CFBundleName";
}

+ (NSString *)bundleDisplayNameKey {
    return @"CFBundleDisplayName";
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
    
    NSString *bundleIdentifier = self.bundle.bundleIdentifier;
    if (bundleIdentifier) {
        bidRequest.app.bundle = bundleIdentifier;
    }

    NSDictionary *bundleDict = self.bundle.infoDictionary;
    if (bundleDict) {
        NSString *bundleDisplayName = bundleDict[OXMAppInfoParameterBuilder.bundleDisplayNameKey];
        NSString *bundleName = bundleDict[OXMAppInfoParameterBuilder.bundleNameKey];
        NSString *appName = bundleDisplayName ? bundleDisplayName : bundleName;
        if (appName) {
            bidRequest.app.name = appName;
        }
    }
    
    NSString *publisherName = self.targeting.publisherName;
    if (!bidRequest.app.publisher.name && publisherName) {
        if (!bidRequest.app.publisher) {
            bidRequest.app.publisher = [OXMORTBPublisher new];
        }
        bidRequest.app.publisher.name = publisherName;
    }
}

@end
