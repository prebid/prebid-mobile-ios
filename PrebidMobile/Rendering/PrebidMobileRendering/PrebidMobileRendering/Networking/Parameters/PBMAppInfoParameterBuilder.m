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

#import "PBMConstants.h"
#import "PBMLog.h"
#import "PBMMacros.h"
#import "PBMORTB.h"
#import "PBMORTBBidRequest.h"

#import "PBMAppInfoParameterBuilder.h"

#import "PrebidMobileRenderingSwiftHeaders.h"
#import <PrebidMobileRendering/PrebidMobileRendering-Swift.h>

#pragma mark - Internal Extension

@interface PBMAppInfoParameterBuilder ()

@property (nonatomic, strong, readonly) id<PBMBundleProtocol> bundle;
@property (nonatomic, strong, readonly) PrebidRenderingTargeting *targeting;

@end

#pragma mark - Implementation

@implementation PBMAppInfoParameterBuilder

#pragma mark - Properties

//Keys into Bundle info Dict
+ (NSString *)bundleNameKey {
    return @"CFBundleName";
}

+ (NSString *)bundleDisplayNameKey {
    return @"CFBundleDisplayName";
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
    
    NSString *bundleIdentifier = self.bundle.bundleIdentifier;
    if (bundleIdentifier) {
        bidRequest.app.bundle = bundleIdentifier;
    }

    NSDictionary *bundleDict = self.bundle.infoDictionary;
    if (bundleDict) {
        NSString *bundleDisplayName = bundleDict[PBMAppInfoParameterBuilder.bundleDisplayNameKey];
        NSString *bundleName = bundleDict[PBMAppInfoParameterBuilder.bundleNameKey];
        NSString *appName = bundleDisplayName ? bundleDisplayName : bundleName;
        if (appName) {
            bidRequest.app.name = appName;
        }
    }
    
    NSString *publisherName = self.targeting.publisherName;
    if (!bidRequest.app.publisher.name && publisherName) {
        if (!bidRequest.app.publisher) {
            bidRequest.app.publisher = [PBMORTBPublisher new];
        }
        bidRequest.app.publisher.name = publisherName;
    }
}

@end
