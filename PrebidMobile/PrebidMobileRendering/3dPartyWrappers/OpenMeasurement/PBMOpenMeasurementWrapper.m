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

#import "PBMError.h"
#import "PBMFunctions.h"
#import "PBMFunctions+Private.h"
#import "PBMMacros.h"
#import "PBMOpenMeasurementWrapper.h"
#import "PBMServerConnectionProtocol.h"
#import "PBMServerResponse.h"
#import "PBMJSLibraryManager.h"

#import "PrebidMobileSwiftHeaders.h"
#import <PrebidMobile/PrebidMobile-Swift.h>

@import OMSDK_Prebidorg;

#pragma mark - Constants

static NSString * const PBMOpenMeasurementPartnerName   = @"Prebidorg";
static NSString * const PBMOpenMeasurementJSLibURL      = @"https://my.server.com/omsdk.js";
static NSString * const PBMOpenMeasurementCustomRefId   = @"";

#pragma mark - Private Interface

@interface PBMOpenMeasurementWrapper ()

@property (nonatomic, readonly) NSString *partnerName;
@property (nonatomic, readonly) NSString *jsLibURL;
@property (nonatomic, readonly) NSString *customRefId;

@property (nonatomic, copy, nullable) NSString *jsLib;
@property (nonatomic, strong, nonnull) OMIDPrebidorgPartner *partner;

@end

#pragma mark - Implementation

@implementation PBMOpenMeasurementWrapper

#pragma mark - Initialization

+ (instancetype)shared {
    static PBMOpenMeasurementWrapper *shared;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[PBMOpenMeasurementWrapper alloc] init];
    });
    
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializeOMSDK];
    }
    
    return self;
}

#pragma mark - Properties

- (NSString *)partnerName {
    return PBMOpenMeasurementPartnerName;
}

- (NSString *)jsLibURL {
    return PBMOpenMeasurementJSLibURL;
}

- (NSString *)customRefId {
    return PBMOpenMeasurementCustomRefId;
}

#pragma mark - PBMMeasurementProtocol

- (void)initializeJSLibWithBundle:(NSBundle *)bundle completion:(nullable PBMVoidBlock)completion {
    [self loadLocalJSLibWithBundle:bundle];
    if (completion) {
        completion();
    }
}

- (nullable NSString *)injectJSLib:(NSString *)html error:(NSError **)error {
    if (!html) {
        [PBMError createError:error description:@"Empty ad's html"];
        return nil;
    }
    
    if (!self.jsLib) {
        [PBMError createError:error description:@"The js lib for Open Measurement is not loaded."];
        return nil;
    }
    
    NSString *res = [OMIDPrebidorgScriptInjector injectScriptContent:self.jsLib
                                                        intoHTML:html
                                                           error:error];
    
    return res;
}

- (nullable PBMOpenMeasurementSession *)initializeWebViewSession:(WKWebView *)webView contentUrl:(NSString *)contentUrl {

    NSError *contextError;
    OMIDPrebidorgAdSessionContext *context = [[OMIDPrebidorgAdSessionContext alloc] initWithPartner:self.partner
                                                                                    webView:webView
                                                                                 contentUrl:contentUrl
                                                                  customReferenceIdentifier:self.customRefId
                                                                                      error:&contextError];
    
    if (contextError) {
        LogError(@"Unable to create Open Measurement session context with error: %@", [contextError localizedDescription]);
        return nil;
    }
    
    NSError *configurationError;
    
    OMIDPrebidorgAdSessionConfiguration *config = [[OMIDPrebidorgAdSessionConfiguration alloc] initWithCreativeType:OMIDCreativeTypeHtmlDisplay
                                                                                             impressionType:OMIDImpressionTypeOnePixel
                                                                                            impressionOwner:OMIDNativeOwner
                                                                                           mediaEventsOwner:OMIDNoneOwner
                                                                                 isolateVerificationScripts:NO
                                                                                                      error:&configurationError];
    
    if (configurationError) {
        LogError(@"Unable to create Open Measurement session configuration with error: %@", [configurationError localizedDescription]);
        return nil;
    }
    
    NSError *sessionError;
    PBMOpenMeasurementSession *session = [[PBMOpenMeasurementSession alloc] initWithContext:context configuration:config];
    if (!session) {
        LogError(@"Unable to create Open Measurement session with error: %@", [sessionError localizedDescription]);
        return nil;
    }
    
    [session setupMainView:webView];
  
    return session;
}

- (PBMOpenMeasurementSession *)initializeNativeVideoSession:(UIView *)videoView
                                     verificationParameters:(PBMVideoVerificationParameters *)verificationParameters {
    
    if (!self.jsLib) {
        LogError(@"Open Measurement SDK can't work without valid js script");
        return nil;
    }
    
    NSError *contextError;
    OMIDPrebidorgAdSessionContext *context = [[OMIDPrebidorgAdSessionContext alloc] initWithPartner:self.partner
                                                                                     script:self.jsLib
                                                                                  resources:[self getScriptResources:verificationParameters]
                                                                                 contentUrl:nil
                                                                  customReferenceIdentifier:nil
                                                                                      error:&contextError];
    if (contextError) {
        LogError(@"Unable to create Open Measurement session context with error: %@", [contextError localizedDescription]);
        return nil;
    }
    
    NSError *configurationError;
    
    OMIDPrebidorgAdSessionConfiguration *config = [[OMIDPrebidorgAdSessionConfiguration alloc] initWithCreativeType:OMIDCreativeTypeVideo
                                                                                             impressionType:OMIDImpressionTypeOnePixel
                                                                                            impressionOwner:OMIDNativeOwner
                                                                                           mediaEventsOwner:OMIDNativeOwner
                                                                                 isolateVerificationScripts:NO
                                                                                                      error:&configurationError];
    if (configurationError) {
        LogError(@"Unable to create Open Measurement session configuration with error: %@", [configurationError localizedDescription]);
        return nil;
    }
    
    NSError *sessionError;
    PBMOpenMeasurementSession *session = [[PBMOpenMeasurementSession alloc] initWithContext:context configuration:config];
    if (!session) {
        LogError(@"Unable to create Open Measurement session with error: %@", [sessionError localizedDescription]);
        return nil;
    }
    
    [session setupMainView:videoView];
    
    return session;
}

- (PBMOpenMeasurementSession *)initializeNativeDisplaySession:(UIView *)view
                                                    omidJSUrl:(NSString *)omidJSUrl
                                                    vendorKey:(NSString *)vendorKey
                                                   parameters:(NSString *)verificationParameters {
    
    if (!self.jsLib) {
        LogError(@"Open Measurement SDK can't work without valid js script");
        return nil;
    }
    
    NSArray<OMIDPrebidorgVerificationScriptResource *> *resources = [self scriptResourcesFrom:omidJSUrl
                                                                                vendorKey:vendorKey
                                                                               parameters:verificationParameters];
    NSError *contextError;
    OMIDPrebidorgAdSessionContext *context = [[OMIDPrebidorgAdSessionContext alloc] initWithPartner:self.partner
                                                                                     script:self.jsLib
                                                                                  resources:resources
                                                                                 contentUrl:nil
                                                                  customReferenceIdentifier:nil
                                                                                      error:&contextError];
    if (contextError) {
        LogError(@"Unable to create Open Measurement session context with error: %@",
                    [contextError localizedDescription]);
        return nil;
    }
    
    NSError *configurationError;
    
    OMIDPrebidorgAdSessionConfiguration *config = [[OMIDPrebidorgAdSessionConfiguration alloc]      initWithCreativeType:OMIDCreativeTypeNativeDisplay
              impressionType:OMIDImpressionTypeOnePixel
             impressionOwner:OMIDNativeOwner
            mediaEventsOwner:OMIDNoneOwner
  isolateVerificationScripts:NO
                       error:&configurationError];
    if (configurationError) {
        LogError(@"Unable to create Open Measurement session configuration with error: %@",
                    [configurationError localizedDescription]);
        return nil;
    }
    
    NSError *sessionError;
    PBMOpenMeasurementSession *session = [[PBMOpenMeasurementSession alloc] initWithContext:context configuration:config];
    if (!session) {
        LogError(@"Unable to create Open Measurement session with error: %@", [sessionError localizedDescription]);
        return nil;
    }
    
    [session setupMainView:view];
    
    return session;
}


#pragma mark - Internal Methods

- (void)initializeOMSDK {
    NSError *error;
    BOOL sdkStarted = [[OMIDPrebidorgSDK sharedInstance] activate];
    
    if (!sdkStarted) {
        LogError(@"Prebid SDK can't initialize Open Measurement SDK with error: %@", [error localizedDescription]);
    }
    
    self.partner = [[OMIDPrebidorgPartner alloc] initWithName:self.partnerName
                                            versionString:[PBMFunctions omidVersion]];
}

- (void)downloadJSLibWithConnection:(id<PBMServerConnectionProtocol>)connection completion:(nullable PBMVoidBlock)completion {
    if (!connection) {
        LogError(@"Connection is nil");
        if (completion) {
            completion();
        }
        
        return;
    }
    
    @weakify(self);
    [connection download:self.jsLibURL callback:^(PBMServerResponse * _Nonnull response) {
        @strongify(self);
        // Delayed call to not process all error cases.
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
        
        if (!response) {
            LogError(@"Unable to load Open Measurement js library.");
            return;
        }
        
        if (response.error) {
            LogError(@"Unable to load Open Measurement js library with error: %@", [response.error localizedDescription]);
            return;
        }
        
        self.jsLib = [[NSString alloc] initWithData:response.rawData encoding:NSUTF8StringEncoding];
    }];
}

- (void)loadLocalJSLibWithBundle:(NSBundle *)bundle {
    [PBMJSLibraryManager sharedManager].bundle = bundle;
    NSString *omScript = [[PBMJSLibraryManager sharedManager] getOMSDKLibrary];
    if (!omScript) {
        LogError(@"Could not load omsdk.js from file");
        return;
    }
    
    self.jsLib = omScript;
}


- (nonnull NSArray<OMIDPrebidorgVerificationScriptResource *> *)getScriptResources:(PBMVideoVerificationParameters *)vastVerificationParamaters {
    NSMutableArray *scripts = [NSMutableArray new];
    
    for (PBMVideoVerificationResource *vastResource in vastVerificationParamaters.verificationResources) {
        if (!(vastResource.url && vastResource.vendorKey && vastResource.params)) {
            LogError(@"Invalid Verification Resource. All properties should be provided. Url: %@, vendorKey: %@, params: %@", vastResource.url, vastResource.vendorKey, vastResource.params);
            continue;
        }
        
        NSURL *url = [[NSURL alloc] initWithString:vastResource.url];
        if (!url) {
            LogError(@"The URL for OM Verification Resource is invalid. Url: %@", vastResource.url);
            continue;
        }
        
        OMIDPrebidorgVerificationScriptResource *resource = [[OMIDPrebidorgVerificationScriptResource alloc] initWithURL:url
                                                                                                       vendorKey:vastResource.vendorKey
                                                                                                      parameters:vastResource.params];
        
        if (!resource) {
            LogError(@"Can't create OM Verification Resource. Url: %@, vendorKey: %@, params: %@", vastResource.url, vastResource.vendorKey, vastResource.params);
            continue;
        }
        
        [scripts addObject:resource];
    }
    
    return scripts;
}

- (nonnull NSArray<OMIDPrebidorgVerificationScriptResource *> *)scriptResourcesFrom:(NSString *)omidJSUrl
                                                                      vendorKey:(NSString *)vendorKey
                                                                     parameters:(NSString *)parameters {
    
    if (!omidJSUrl || !vendorKey || !parameters) {
        LogError(@"Invalid Verification Resource. All properties should be provided. Url: %@, vendorKey: %@, params: %@",
                    omidJSUrl, vendorKey, parameters);
        return @[];
    }
    
    NSURL *url = [[NSURL alloc] initWithString:omidJSUrl];
    if (!url) {
        LogError(@"The URL for OM Verification Resource is invalid. Url: %@", omidJSUrl);
        return @[];
    }
         
    OMIDPrebidorgVerificationScriptResource *resource = [[OMIDPrebidorgVerificationScriptResource alloc] initWithURL:url
                                                                                                   vendorKey:vendorKey
                                                                                                  parameters:parameters];
    
    if (!resource) {
        LogError(@"Can't create OM Verification Resource. Url: %@, vendorKey: %@, params: %@",
                    omidJSUrl, vendorKey, parameters);
        return @[];
    }
    
    return  @[resource];
}

@end
