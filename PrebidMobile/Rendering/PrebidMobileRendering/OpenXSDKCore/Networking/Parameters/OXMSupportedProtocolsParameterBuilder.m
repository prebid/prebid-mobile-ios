//
//  OXMSupportedProtocolsParameterBuilder.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMSupportedProtocolsParameterBuilder.h"
#import "OXMLog.h"
#import "OXMMacros.h"
#import "OXASDKConfiguration.h"
#import "OXMORTB.h"

#pragma mark - Constants

static int const OXMSupportMRAIDProtocol1 = 3;
static int const OXMSupportMRAIDProtocol2 = 5;
static int const OXMSupportMRAIDProtocol3 = 6;
static int const OXMSupportOpenMeasurementProtocol = 7;


#pragma mark - Internal Extension

@interface OXMSupportedProtocolsParameterBuilder ()

@property (nonatomic, strong) OXASDKConfiguration *sdkConfiguration;

@end

#pragma mark - Implementation

@implementation OXMSupportedProtocolsParameterBuilder

#pragma mark - Properties

+ (NSString *)supportedVersionsParamKey {
    return @"af";
}

#pragma mark - Initialization

- (nonnull instancetype)initWithSDKConfiguration:(nonnull OXASDKConfiguration *)sdkConfiguration {
    self = [super init];
    if (self) {
        OXMAssert(sdkConfiguration);
        
        self.sdkConfiguration = sdkConfiguration;
    }
    
    return self;
}

#pragma mark - OXMParameterBuilder

- (void)buildBidRequest:(OXMORTBBidRequest *)bidRequest {
    if(!bidRequest) {
        OXMLogError(@"Invalid properties");
        return;
    }
        
    //Walk all imp's banners and set their API value to 3,5

    NSArray<NSNumber *> *supportedVersions = [self getSupportedVersions];
    for (OXMORTBImp *imp in bidRequest.imp) {
        if (imp.banner) {
            imp.banner.api = [supportedVersions copy];
        }
    }
}

- (NSArray<NSNumber *> *)getSupportedVersions {
    NSMutableArray<NSNumber *> *res = [NSMutableArray array];
    
    [res addObject:@(OXMSupportMRAIDProtocol1)];
    [res addObject:@(OXMSupportMRAIDProtocol2)];
    [res addObject:@(OXMSupportMRAIDProtocol3)];
    
    [res addObject:@(OXMSupportOpenMeasurementProtocol)];
    
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
