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

#import "PBMSupportedProtocolsParameterBuilder.h"
#import "PBMMacros.h"
#import "PBMORTB.h"

#import "PrebidMobileSwiftHeaders.h"
#import <PrebidMobile/PrebidMobile-Swift.h>

#pragma mark - Constants

static int const PBMSupportMRAIDProtocol1 = 3;
static int const PBMSupportMRAIDProtocol2 = 5;
static int const PBMSupportMRAIDProtocol3 = 6;
static int const PBMSupportOpenMeasurementProtocol = 7;


#pragma mark - Internal Extension

@interface PBMSupportedProtocolsParameterBuilder ()

@property (nonatomic, strong) Prebid *sdkConfiguration;

@end

#pragma mark - Implementation

@implementation PBMSupportedProtocolsParameterBuilder

#pragma mark - Properties

+ (NSString *)supportedVersionsParamKey {
    return @"af";
}

#pragma mark - Initialization

- (nonnull instancetype)initWithSDKConfiguration:(nonnull Prebid *)sdkConfiguration {
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
