//
//  MPViewabilityContext.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPViewabilityContext.h"
#import "MPLogging.h"
#import "MPVASTMacroProcessor.h"
#import "MPVASTVerificationErrorReason.h"

// Viewability Resource JSON keys
NSString * const kViewabilityResourceVendorKey        = @"vendorKey";
NSString * const kViewabilityResourceApiFrameworkKey  = @"apiFramework";
NSString * const kViewabilityResourceJavascriptUrlKey = @"javascriptResourceUrl";
NSString * const kViewabilityResourceParametersKey    = @"verificationParameters";
NSString * const kViewabilityResourceTrackersKey      = @"trackers";

// API Framework value for Open Measurement resources
NSString * const kViewabilityResourceOMSDKValue       = @"omid";

// Verification not executed tracking event
NSString * const kViewabilityResourceNotExecutedTrackingEvent = @"verificationNotExecuted";

@interface MPViewabilityContext()
@property (nonatomic, strong) NSMutableArray<NSURL *> *notExecutedTrackers;
@property (nonatomic, strong) NSMutableArray<OMIDMopubVerificationScriptResource *> *resources;
@end

@implementation MPViewabilityContext

#pragma mark - MPParseResult

typedef struct MPParseResult {
    NSArray<OMIDMopubVerificationScriptResource *> *resources;
    NSArray<NSURL *> *notExecutedTrackers;
} MPParseResult;

// Represents no parse result
static const struct MPParseResult MPParseResultNone = {
    .resources = nil,
    .notExecutedTrackers = nil
};

#pragma mark - Initializers

- (instancetype)initWithAdVerificationsXML:(MPVASTAdVerifications * _Nullable)verificationNode {
    if (self = [super init]) {
        _notExecutedTrackers = [NSMutableArray array];
        _resources = [NSMutableArray array];
        
        // Parsing
        struct MPParseResult parseResult = [self parseAdVerifications:verificationNode];
        if (parseResult.resources != nil) {
            [_resources addObjectsFromArray:parseResult.resources];
        }
        
        if (parseResult.notExecutedTrackers != nil) {
            [_notExecutedTrackers addObjectsFromArray:parseResult.notExecutedTrackers];
        }
    }
    
    return self;
}

- (instancetype)initWithVerificationResourcesJSON:(NSArray<NSDictionary *> * _Nullable)json {
    if (self = [super init]) {
        _notExecutedTrackers = [NSMutableArray array];
        _resources = [NSMutableArray array];
        
        // Parsing
        struct MPParseResult parseResult = [self parseVerificationResourcesJSON:json];
        if (parseResult.resources != nil) {
            [_resources addObjectsFromArray:parseResult.resources];
        }
        
        if (parseResult.notExecutedTrackers != nil) {
            [_notExecutedTrackers addObjectsFromArray:parseResult.notExecutedTrackers];
        }
    }
    
    return self;
}

#pragma mark - Properties

- (NSArray<OMIDMopubVerificationScriptResource *> *)omidResources {
    return self.resources;
}

- (NSArray<NSURL *> *)omidNotExecutedTrackers {
    return self.notExecutedTrackers;
}

- (NSArray<WKUserScript *> *)resourcesAsScripts {
    // No resources available.
    if (self.resources.count == 0) {
        return nil;
    }
    
    NSMutableArray<WKUserScript *> *scripts = [NSMutableArray array];
    [self.resources enumerateObjectsUsingBlock:^(OMIDMopubVerificationScriptResource * _Nonnull resource, NSUInteger idx, BOOL * _Nonnull stop) {
        // Retrieve the OMID JavaScript resource URL as a string.
        NSString *resourceUrlString = resource.URL.absoluteString;
        if (resourceUrlString.length == 0) {
            return;
        }
        
        // `WKUserScript` is not able to take a JavaScript source URL as an option, so the following
        // script will create a <script src=/> element and append it to the <head> of the HTML document.
        NSString *scriptSource = [NSString stringWithFormat:@"var script = document.createElement('script');\nscript.src = '%@';\nscript.type = 'text/javascript';\ndocument.getElementsByTagName('head')[0].appendChild(script);", resourceUrlString];
        
        // Generate the script.
        // The script must be run at Document end to allow the OM SDK JS to load first and then this OM resource
        // script can execute.
        WKUserScript *script = [[WKUserScript alloc] initWithSource:scriptSource injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        if (script != nil) {
            [scripts addObject:script];
        }
    }];
    
    return (scripts.count > 0 ? scripts : nil);
}

#pragma mark - AdVerifications

- (void)addAdVerificationsXML:(MPVASTAdVerifications * _Nullable)verificationNode {
    struct MPParseResult parseResult = [self parseAdVerifications:verificationNode];
    if (parseResult.resources != nil) {
        [_resources addObjectsFromArray:parseResult.resources];
    }
    
    if (parseResult.notExecutedTrackers != nil) {
        [_notExecutedTrackers addObjectsFromArray:parseResult.notExecutedTrackers];
    }
}

#pragma mark - Parsing

- (MPParseResult)parseAdVerifications:(MPVASTAdVerifications * _Nullable)adVerifications {
    // Result
    struct MPParseResult result = MPParseResultNone;
    
    // Nothing to parse
    if (adVerifications == nil) {
        return result;
    }
    
    // Parse results
    NSMutableArray<OMIDMopubVerificationScriptResource *> *parsedResources = [NSMutableArray array];
    NSMutableArray<NSURL *> *parsedTrackers = [NSMutableArray array];
    
    // Parse each Verification item in the node
    // The Javascript resource and the verification not executed trackers are parsed simultaneously, but only
    // one will be added to their final parsed results. For example, if we successfully parse an OMID resource,
    // it is added to the `parsedResources` result and no trackers are added. Conversely, if there was some
    // error parsing, the trackers will be added to the `parsedTrackers` result, and nothing added to `parsedResources`.
    [adVerifications.verifications enumerateObjectsUsingBlock:^(MPVASTVerification * _Nonnull verification, NSUInteger idx, BOOL * _Nonnull stop) {
        // Extract the `verificationNotExecuted` tracking events (if any).
        NSArray<MPVASTTrackingEvent *> *trackers = verification.trackingEvents[kViewabilityResourceNotExecutedTrackingEvent];
        
        // REQUIRED: Javascript resource
        MPVASTJavaScriptResource *jsResource = verification.javascriptResource;
        if (jsResource == nil) {
            MPLogWarn(@"No JavaScript resource exists");
            [parsedTrackers addObjectsFromArray:[self expandTrackers:trackers errorReason:MPVASTVerificationErrorReasonResourceLoadError]];
            return;
        }
        
        // Only handle Open Measurement resources
        if (![jsResource.apiFramework isEqualToString:kViewabilityResourceOMSDKValue]) {
            MPLogWarn(@"%@ viewability framework is not supported by the MoPub SDK", jsResource.apiFramework);
            [parsedTrackers addObjectsFromArray:[self expandTrackers:trackers errorReason:MPVASTVerificationErrorReasonVerificationNotSupported]];
            return;
        }
        
        // Validate javascript resource has a valid URL
        NSURL *javascriptUrl = jsResource.resourceUrl;
        if (javascriptUrl == nil) {
            MPLogWarn(@"Verification resource does not contain a valid Javascript URL: %@", jsResource.resourceUrl);
            [parsedTrackers addObjectsFromArray:[self expandTrackers:trackers errorReason:MPVASTVerificationErrorReasonResourceLoadError]];
            return;
        }
        
        // OPTIONAL: parameters
        // Verification parameters are optional and have different initializers depending
        // on whether there are parameters or not.
        NSString *parameters = verification.verificationParameters;
        
        // CONDITIONALLY REQUIRED: vendor
        // Vendor is only required when there are parameters.
        NSString *vendor = verification.vendor;
        if (parameters.length > 0 && vendor.length == 0) {
            MPLogWarn(@"Verification node does not contain a vendor");
            [parsedTrackers addObjectsFromArray:[self expandTrackers:trackers errorReason:MPVASTVerificationErrorReasonResourceLoadError]];
            return;
        }
        
        // Generate the Open Measurement resource script
        OMIDMopubVerificationScriptResource *omidResource = nil;
        if (parameters.length > 0) {
            omidResource = [[OMIDMopubVerificationScriptResource alloc] initWithURL:javascriptUrl
                                                                          vendorKey:vendor
                                                                         parameters:parameters];
        }
        else {
            omidResource = [[OMIDMopubVerificationScriptResource alloc] initWithURL:javascriptUrl];
        }
        
        if (omidResource == nil) {
            MPLogWarn(@"Failed to generate OMIDMopubVerificationScriptResource using:\nJavascript URL: %@\nVendor: %@\nParameters: %@", javascriptUrl, vendor, parameters);
            [parsedTrackers addObjectsFromArray:[self expandTrackers:trackers errorReason:MPVASTVerificationErrorReasonResourceLoadError]];
            return;
        }
        
        [parsedResources addObject:omidResource];
    }];
    
    // Set the results
    if (parsedResources.count > 0) {
        result.resources = parsedResources;
    }
    
    if (parsedTrackers.count > 0) {
        result.notExecutedTrackers = parsedTrackers;
    }
    
    return result;
}

- (MPParseResult)parseVerificationResourcesJSON:(NSArray<NSDictionary *> * _Nullable)json {
    // Result
    struct MPParseResult result = MPParseResultNone;
    
    // No resources to parse
    if (json.count == 0) {
        return result;
    }
    
    // Results
    NSMutableArray<OMIDMopubVerificationScriptResource *> *parsedResources = [NSMutableArray array];
    NSMutableArray<NSURL *> *parsedTrackers = [NSMutableArray array];
    
    // Parse each resource entry
    // The Javascript resource and the verification not executed trackers are parsed simultaneously, but only
    // one will be added to their final parsed results. For example, if we successfully parse an OMID resource,
    // it is added to the `parsedResources` result and no trackers are added. Conversely, if there was some
    // error parsing, the trackers will be added to the `parsedTrackers` result, and nothing added to `parsedResources`.
    [json enumerateObjectsUsingBlock:^(id _Nonnull viewabilityResourceJson, NSUInteger idx, BOOL * _Nonnull stop) {
        // Validate that the viewability resource JSON object is the expected
        // dictionary type. If it is not, ignore this item. This is necessary in the
        // rare cases that the array may contain JSON null objects
        if (![viewabilityResourceJson isKindOfClass:[NSDictionary class]]) {
            MPLogWarn(@"Encountered unexpected viewability resource class type %@", NSStringFromClass([viewabilityResourceJson class]));
            return;
        }
        
        // Down cast for safety.
        NSDictionary *viewabilityResource = (NSDictionary *)viewabilityResourceJson;
        
        // Extract the `verificationNotExecuted` tracking events (if any).
        NSArray<NSURL *> *trackers = ({
            NSArray<NSString *> *trackerUrlStrings = viewabilityResource[kViewabilityResourceTrackersKey][kViewabilityResourceNotExecutedTrackingEvent];
            NSMutableArray<NSURL *> *trackerUrls = [NSMutableArray array];
            [trackerUrlStrings enumerateObjectsUsingBlock:^(NSString * _Nonnull urlString, NSUInteger idx, BOOL * _Nonnull stop) {
                NSURL *url = [NSURL URLWithString:urlString];
                if (url != nil) {
                    [trackerUrls addObject:url];
                }
            }];
            
            trackerUrls;
        });
        
        // Only handle Open Measurement resources
        NSString * apiFramework = viewabilityResource[kViewabilityResourceApiFrameworkKey];
        if (![apiFramework isEqualToString:kViewabilityResourceOMSDKValue]) {
            MPLogWarn(@"%@ viewability framework is not supported by the MoPub SDK", apiFramework);
            [parsedTrackers addObjectsFromArray:[self expandTrackingUrls:trackers errorReason:MPVASTVerificationErrorReasonVerificationNotSupported]];
            return;
        }
        
        // REQUIRED: Javascript resource
        NSString *javascriptUrlString = viewabilityResource[kViewabilityResourceJavascriptUrlKey];
        if (javascriptUrlString == nil) {
            MPLogWarn(@"No JavaScript resource exists");
            [parsedTrackers addObjectsFromArray:[self expandTrackingUrls:trackers errorReason:MPVASTVerificationErrorReasonResourceLoadError]];
            return;
        }
                
        // Validate javascript resource has a valid URL
        NSURL *javascriptUrl = [NSURL URLWithString:javascriptUrlString];
        if (javascriptUrl == nil) {
            MPLogWarn(@"Verification resource does not contain a valid Javascript URL: %@", javascriptUrlString);
            [parsedTrackers addObjectsFromArray:[self expandTrackingUrls:trackers errorReason:MPVASTVerificationErrorReasonResourceLoadError]];
            return;
        }
        
        // OPTIONAL: parameters
        // Verification parameters are optional and have different initializers depending
        // on whether there are parameters or not.
        NSString *parameters = viewabilityResource[kViewabilityResourceParametersKey];
        
        // CONDITIONALLY REQUIRED: vendor
        // Vendor is only required when there are parameters.
        NSString *vendor = viewabilityResource[kViewabilityResourceVendorKey];
        if (parameters.length > 0 && vendor.length == 0) {
            MPLogWarn(@"Verification resource does not contain a vendor");
            [parsedTrackers addObjectsFromArray:[self expandTrackingUrls:trackers errorReason:MPVASTVerificationErrorReasonResourceLoadError]];
            return;
        }
        
        // Generate the Open Measurement resource script
        OMIDMopubVerificationScriptResource *omidResource = nil;
        if (parameters.length > 0) {
            omidResource = [[OMIDMopubVerificationScriptResource alloc] initWithURL:javascriptUrl
                                                                          vendorKey:vendor
                                                                         parameters:parameters];
        }
        else {
            omidResource = [[OMIDMopubVerificationScriptResource alloc] initWithURL:javascriptUrl];
        }
        
        if (omidResource == nil) {
            MPLogWarn(@"Failed to generate OMIDMopubVerificationScriptResource using:\nJavascript URL: %@\nVendor: %@\nParameters: %@", javascriptUrlString, vendor, parameters);
            [parsedTrackers addObjectsFromArray:[self expandTrackingUrls:trackers errorReason:MPVASTVerificationErrorReasonResourceLoadError]];
            return;
        }
        
        [parsedResources addObject:omidResource];
    }];
    
    // Set the results
    if (parsedResources.count > 0) {
        result.resources = parsedResources;
    }
    
    if (parsedTrackers.count > 0) {
        result.notExecutedTrackers = parsedTrackers;
    }
    
    return result;
}

#pragma mark - Trackers

// Macro expands the trackers with the error reason.
- (NSArray<NSURL *> *)expandTrackers:(NSArray<MPVASTTrackingEvent *> * _Nullable)trackers
                         errorReason:(MPVASTVerificationErrorReason)reason {
    // Transform into array of array of URLs
    NSArray<NSURL *> *trackerUrls = [trackers valueForKey:@"URL"];
    
    return [self expandTrackingUrls:trackerUrls errorReason:reason];
}

// Macro expands the trackers with the error reason.
- (NSArray<NSURL *> *)expandTrackingUrls:(NSArray<NSURL *> * _Nullable)trackers
                             errorReason:(MPVASTVerificationErrorReason)reason {
    // No trackers
    // Intentionally return empty array to faciliate array appending without a nil check.
    if (trackers.count == 0) {
        return @[];
    }
    
    NSMutableSet<NSURL *> *processedURLs = [NSMutableSet new];
    for (NSURL *url in trackers) {
        [processedURLs addObject:[MPVASTMacroProcessor macroExpandedURLForURL:url verificationErrorReason:reason]];
    }
    
    return processedURLs.allObjects;
}

#pragma mark - Merging

- (void)addObjectsFromContext:(MPViewabilityContext *)context {
    // Nothing to add.
    if (context == nil) {
        return;
    }
    
    [self.notExecutedTrackers addObjectsFromArray:context.notExecutedTrackers];
    [self.resources addObjectsFromArray:context.resources];
}

@end
