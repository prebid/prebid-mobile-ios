//
//  OXMOpenMeasurementWrapper.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMError.h"
#import "OXMFunctions.h"
#import "OXMFunctions+Private.h"
#import "OXMMacros.h"
#import "OXMOpenMeasurementWrapper.h"
#import "OXMServerConnectionProtocol.h"
#import "OXMServerResponse.h"
#import "OXMJSLibraryManager.h"

@import OMSDK_Openx;

#pragma mark - Constants

static NSString * const OXMOpenMeasurementPartnerName   = @"Openx";
static NSString * const OXMOpenMeasurementJSLibURL      = @"https://my.server.com/omsdk.js";
static NSString * const OXMOpenMeasurementCustomRefId   = @"";

#pragma mark - Private Interface

@interface OXMOpenMeasurementWrapper ()

@property (nonatomic, readonly) NSString *partnerName;
@property (nonatomic, readonly) NSString *jsLibURL;
@property (nonatomic, readonly) NSString *customRefId;

@property (nonatomic, copy, nullable) NSString *jsLib;
@property (nonatomic, strong, nonnull) OMIDOpenxPartner *partner;

@end

#pragma mark - Implementation

@implementation OXMOpenMeasurementWrapper

#pragma mark - Initialization

+ (instancetype)singleton {
    static OXMOpenMeasurementWrapper *singleton;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [OXMOpenMeasurementWrapper new];
    });
    
    return singleton;
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
    return OXMOpenMeasurementPartnerName;
}

- (NSString *)jsLibURL {
    return OXMOpenMeasurementJSLibURL;
}

- (NSString *)customRefId {
    return OXMOpenMeasurementCustomRefId;
}

#pragma mark - OXMMeasurementProtocol

- (void)initializeJSLibWithBundle:(NSBundle *)bundle completion:(nullable OXMVoidBlock)completion {
    [self loadLocalJSLibWithBundle:bundle];
    if (completion) {
        completion();
    }
}

- (nullable NSString *)injectJSLib:(NSString *)html error:(NSError **)error {
    if (!html) {
        [OXMError createError:error description:@"Empty ad's html"];
        return nil;
    }
    
    if (!self.jsLib) {
        [OXMError createError:error description:@"The js lib for Open Measurement is not loaded."];
        return nil;
    }
    
    NSString *res = [OMIDOpenxScriptInjector injectScriptContent:self.jsLib
                                                        intoHTML:html
                                                           error:error];
    
    return res;
}

- (nullable OXMOpenMeasurementSession *)initializeWebViewSession:(WKWebView *)webView contentUrl:(NSString *)contentUrl {

    NSError *contextError;
    OMIDOpenxAdSessionContext *context = [[OMIDOpenxAdSessionContext alloc] initWithPartner:self.partner
                                                                                    webView:webView
                                                                                 contentUrl:contentUrl
                                                                  customReferenceIdentifier:self.customRefId
                                                                                      error:&contextError];
    
    if (contextError) {
        OXMLogError(@"Unable to create Open Measurement session context with error: %@", [contextError localizedDescription]);
        return nil;
    }
    
    NSError *configurationError;
    
    OMIDOpenxAdSessionConfiguration *config = [[OMIDOpenxAdSessionConfiguration alloc] initWithCreativeType:OMIDCreativeTypeHtmlDisplay
                                                                                             impressionType:OMIDImpressionTypeOnePixel
                                                                                            impressionOwner:OMIDNativeOwner
                                                                                           mediaEventsOwner:OMIDNoneOwner
                                                                                 isolateVerificationScripts:NO
                                                                                                      error:&configurationError];
    
    if (configurationError) {
        OXMLogError(@"Unable to create Open Measurement session configuration with error: %@", [configurationError localizedDescription]);
        return nil;
    }
    
    NSError *sessionError;
    OXMOpenMeasurementSession *session = [[OXMOpenMeasurementSession alloc] initWithContext:context configuration:config];
    if (!session) {
        OXMLogError(@"Unable to create Open Measurement session with error: %@", [sessionError localizedDescription]);
        return nil;
    }
    
    [session setupMainView:webView];
  
    return session;
}

- (OXMOpenMeasurementSession *)initializeNativeVideoSession:(UIView *)videoView
                                     verificationParameters:(OXMVideoVerificationParameters *)verificationParameters {
    
    if (!self.jsLib) {
        OXMLogError(@"Open Measurement SDK can't work without valid js script");
        return nil;
    }
    
    NSError *contextError;
    OMIDOpenxAdSessionContext *context = [[OMIDOpenxAdSessionContext alloc] initWithPartner:self.partner
                                                                                     script:self.jsLib
                                                                                  resources:[self getScriptResources:verificationParameters]
                                                                                 contentUrl:nil
                                                                  customReferenceIdentifier:nil
                                                                                      error:&contextError];
    if (contextError) {
        OXMLogError(@"Unable to create Open Measurement session context with error: %@", [contextError localizedDescription]);
        return nil;
    }
    
    NSError *configurationError;
    
    OMIDOpenxAdSessionConfiguration *config = [[OMIDOpenxAdSessionConfiguration alloc] initWithCreativeType:OMIDCreativeTypeVideo
                                                                                             impressionType:OMIDImpressionTypeOnePixel
                                                                                            impressionOwner:OMIDNativeOwner
                                                                                           mediaEventsOwner:OMIDNativeOwner
                                                                                 isolateVerificationScripts:NO
                                                                                                      error:&configurationError];
    if (configurationError) {
        OXMLogError(@"Unable to create Open Measurement session configuration with error: %@", [configurationError localizedDescription]);
        return nil;
    }
    
    NSError *sessionError;
    OXMOpenMeasurementSession *session = [[OXMOpenMeasurementSession alloc] initWithContext:context configuration:config];
    if (!session) {
        OXMLogError(@"Unable to create Open Measurement session with error: %@", [sessionError localizedDescription]);
        return nil;
    }
    
    [session setupMainView:videoView];
    
    return session;
}

- (OXMOpenMeasurementSession *)initializeNativeDisplaySession:(UIView *)view
                                                    omidJSUrl:(NSString *)omidJSUrl
                                                    vendorKey:(NSString *)vendorKey
                                                   parameters:(NSString *)verificationParameters {
    
    if (!self.jsLib) {
        OXMLogError(@"Open Measurement SDK can't work without valid js script");
        return nil;
    }
    
    NSArray<OMIDOpenxVerificationScriptResource *> *resources = [self scriptResourcesFrom:omidJSUrl
                                                                                vendorKey:vendorKey
                                                                               parameters:verificationParameters];
    NSError *contextError;
    OMIDOpenxAdSessionContext *context = [[OMIDOpenxAdSessionContext alloc] initWithPartner:self.partner
                                                                                     script:self.jsLib
                                                                                  resources:resources
                                                                                 contentUrl:nil
                                                                  customReferenceIdentifier:nil
                                                                                      error:&contextError];
    if (contextError) {
        OXMLogError(@"Unable to create Open Measurement session context with error: %@",
                    [contextError localizedDescription]);
        return nil;
    }
    
    NSError *configurationError;
    
    OMIDOpenxAdSessionConfiguration *config = [[OMIDOpenxAdSessionConfiguration alloc]      initWithCreativeType:OMIDCreativeTypeNativeDisplay
              impressionType:OMIDImpressionTypeOnePixel
             impressionOwner:OMIDNativeOwner
            mediaEventsOwner:OMIDNoneOwner
  isolateVerificationScripts:NO
                       error:&configurationError];
    if (configurationError) {
        OXMLogError(@"Unable to create Open Measurement session configuration with error: %@",
                    [configurationError localizedDescription]);
        return nil;
    }
    
    NSError *sessionError;
    OXMOpenMeasurementSession *session = [[OXMOpenMeasurementSession alloc] initWithContext:context configuration:config];
    if (!session) {
        OXMLogError(@"Unable to create Open Measurement session with error: %@", [sessionError localizedDescription]);
        return nil;
    }
    
    [session setupMainView:view];
    
    return session;
}


#pragma mark - Internal Methods

- (void)initializeOMSDK {
    NSError *error;
    BOOL sdkStarted = [[OMIDOpenxSDK sharedInstance] activate];
    
    if (!sdkStarted) {
        OXMLogError(@"OpenXSDK can't initialize Open Measurement SDK with error: %@", [error localizedDescription]);
    }
    
    self.partner = [[OMIDOpenxPartner alloc] initWithName:self.partnerName
                                            versionString:[OXMFunctions omidVersion]];
}

- (void)downloadJSLibWithConnection:(id<OXMServerConnectionProtocol>)connection completion:(nullable OXMVoidBlock)completion {
    if (!connection) {
        OXMLogError(@"Connection is nil");
        if (completion) {
            completion();
        }
        
        return;
    }
    
    @weakify(self);
    [connection download:self.jsLibURL callback:^(OXMServerResponse * _Nonnull response) {
        @strongify(self);
        // Delayed call to not process all error cases.
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
        
        if (!response) {
            OXMLogError(@"Unable to load Open Measurement js library.");
            return;
        }
        
        if (response.error) {
            OXMLogError(@"Unable to load Open Measurement js library with error: %@", [response.error localizedDescription]);
            return;
        }
        
        self.jsLib = [[NSString alloc] initWithData:response.rawData encoding:NSUTF8StringEncoding];
    }];
}

- (void)loadLocalJSLibWithBundle:(NSBundle *)bundle {
    [OXMJSLibraryManager sharedManager].bundle = bundle;
    NSString *omScript = [[OXMJSLibraryManager sharedManager] getOMSDKLibrary];
    if (!omScript) {
        OXMLogError(@"Could not load omsdk.js from file");
        return;
    }
    
    self.jsLib = omScript;
}


- (nonnull NSArray<OMIDOpenxVerificationScriptResource *> *)getScriptResources:(OXMVideoVerificationParameters *)vastVerificationParamaters {
    NSMutableArray *scripts = [NSMutableArray new];
    
    for (OXMVideoVerificationResource *vastResource in vastVerificationParamaters.verificationResources) {
        if (!(vastResource.url && vastResource.vendorKey && vastResource.params)) {
            OXMLogError(@"Invalid Verification Resource. All properties should be provided. Url: %@, vendorKey: %@, params: %@", vastResource.url, vastResource.vendorKey, vastResource.params);
            continue;
        }
        
        NSURL *url = [[NSURL alloc] initWithString:vastResource.url];
        if (!url) {
            OXMLogError(@"The URL for OM Verification Resource is invalid. Url: %@", vastResource.url);
            continue;
        }
        
        OMIDOpenxVerificationScriptResource *resource = [[OMIDOpenxVerificationScriptResource alloc] initWithURL:url
                                                                                                       vendorKey:vastResource.vendorKey
                                                                                                      parameters:vastResource.params];
        
        if (!resource) {
            OXMLogError(@"Can't create OM Verification Resource. Url: %@, vendorKey: %@, params: %@", vastResource.url, vastResource.vendorKey, vastResource.params);
            continue;
        }
        
        [scripts addObject:resource];
    }
    
    return scripts;
}

- (nonnull NSArray<OMIDOpenxVerificationScriptResource *> *)scriptResourcesFrom:(NSString *)omidJSUrl
                                                                      vendorKey:(NSString *)vendorKey
                                                                     parameters:(NSString *)parameters {
    
    if (!omidJSUrl || !vendorKey || !parameters) {
        OXMLogError(@"Invalid Verification Resource. All properties should be provided. Url: %@, vendorKey: %@, params: %@",
                    omidJSUrl, vendorKey, parameters);
        return @[];
    }
    
    NSURL *url = [[NSURL alloc] initWithString:omidJSUrl];
    if (!url) {
        OXMLogError(@"The URL for OM Verification Resource is invalid. Url: %@", omidJSUrl);
        return @[];
    }
         
    OMIDOpenxVerificationScriptResource *resource = [[OMIDOpenxVerificationScriptResource alloc] initWithURL:url
                                                                                                   vendorKey:vendorKey
                                                                                                  parameters:parameters];
    
    if (!resource) {
        OXMLogError(@"Can't create OM Verification Resource. Url: %@, vendorKey: %@, params: %@",
                    omidJSUrl, vendorKey, parameters);
        return @[];
    }
    
    return  @[resource];
}

@end
