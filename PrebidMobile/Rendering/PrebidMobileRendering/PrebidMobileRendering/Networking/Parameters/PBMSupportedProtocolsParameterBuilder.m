//
//  PBMSupportedProtocolsParameterBuilder.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMSupportedProtocolsParameterBuilder.h"
#import "PBMLog.h"
#import "PBMMacros.h"
#import "PBMORTB.h"

#import "PrebidMobileRenderingSwiftHeaders.h"
#import <PrebidMobileRendering/PrebidMobileRendering-Swift.h>

#pragma mark - Constants

static int const PBMSupportMRAIDProtocol1 = 3;
static int const PBMSupportMRAIDProtocol2 = 5;
static int const PBMSupportMRAIDProtocol3 = 6;
static int const PBMSupportOpenMeasurementProtocol = 7;


#pragma mark - Internal Extension

@interface PBMSupportedProtocolsParameterBuilder ()

@property (nonatomic, strong) PrebidRenderingConfig *sdkConfiguration;

@end

#pragma mark - Implementation

@implementation PBMSupportedProtocolsParameterBuilder

#pragma mark - Properties

+ (NSString *)supportedVersionsParamKey {
    return @"af";
}

#pragma mark - Initialization

- (nonnull instancetype)initWithSDKConfiguration:(nonnull PrebidRenderingConfig *)sdkConfiguration {
    self = [super init];
    if (self) {
        PBMAssert(sdkConfiguration);
        
        self.sdkConfiguration = sdkConfiguration;
    }
    
    return self;
}

#pragma mark - PBMParameterBuilder

- (void)buildBidRequest:(PBMORTBBidRequest *)bidRequest {
    if(!bidRequest) {
        PBMLogError(@"Invalid properties");
        return;
    }
        
    //Walk all imp's banners and set their API value to 3,5

    NSArray<NSNumber *> *supportedVersions = [self getSupportedVersions];
    for (PBMORTBImp *imp in bidRequest.imp) {
        if (imp.banner) {
            imp.banner.api = [supportedVersions copy];
        }
    }
}

- (NSArray<NSNumber *> *)getSupportedVersions {
    NSMutableArray<NSNumber *> *res = [NSMutableArray array];
    
    [res addObject:@(PBMSupportMRAIDProtocol1)];
    [res addObject:@(PBMSupportMRAIDProtocol2)];
    [res addObject:@(PBMSupportMRAIDProtocol3)];
    
    [res addObject:@(PBMSupportOpenMeasurementProtocol)];
    
    return res;
}

- (NSString *)getSupportedVersionsString {
    NSString *res = @"";
    
    NSArray<NSNumber *> *supportedVersions = [self getSupportedVersions];
    for (NSNumber *version in supportedVersions) {
        if ([res length]) {
            res = [res stringByAppendingString:@","];
        }
        
        res = [res stringByAppendingString:[version stringValue]];
    }
    
    return res;
}

@end
