//
//  MPViewabilityContext.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "MPVASTAdVerifications.h"
#import "OMIDVerificationScriptResource.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Provides parsing for viewability resources.
 */
@interface MPViewabilityContext : NSObject
/**
 An array of Open Measurement SDK JS resources used to initialize the tracking session.
 */
@property (nonatomic, strong, readonly) NSArray<OMIDMopubVerificationScriptResource *> *omidResources;

/**
 An array of tracker URLs to fire at the start of the Viewability tracking session.
 */
@property (nonatomic, strong, readonly) NSArray<NSURL *> *omidNotExecutedTrackers;

/**
 The @c omidResources array represented as @c WKUserScript objects instead of @c OMIDMopubVerificationScriptResource objects.
 The scripts will be injected at Document end and only for the main frame. If there are no @c omidResources, this will return @c nil.
 @note Only the JavaScript URL is extracted into the @c WKUserScript.
 */
@property (nonatomic, strong, readonly, nullable) NSArray<WKUserScript *> *resourcesAsScripts;

#pragma mark - Initializers

/**
 Parses the inputted VAST `AdVerifications` XML node.
 @param verificationNode The `AdVerifications` to parse.
 */
- (instancetype)initWithAdVerificationsXML:(MPVASTAdVerifications * _Nullable)verificationNode;

/**
 Parses the inputted verification resources JSON that may be included in an ad response, extracting an array of JS resources to load.
 @param json Verification resources JSON.
 */
- (instancetype)initWithVerificationResourcesJSON:(NSArray<NSDictionary *> * _Nullable)json;

#pragma mark - AdVerifications

/**
 VAST wrappers and inline ads may have their own verification resources that must be aggregated together.
 @param verificationNode The `AdVerifications` node to parse and include with the context.
 */
- (void)addAdVerificationsXML:(MPVASTAdVerifications * _Nullable)verificationNode;

#pragma mark - Merging

/**
 Adds the contents of the specified context into this one.
 @param context Context to merge into this context.
 */
- (void)addObjectsFromContext:(MPViewabilityContext *)context;

#pragma mark - Unavailable

/**
 `init` is not available. Use `sharedManager` instead.
 */
- (instancetype)init __attribute__((unavailable("init not available")));

/**
 `new` is not available. Use `sharedManager` instead.
 */
+ (instancetype)new __attribute__((unavailable("new not available")));

@end

NS_ASSUME_NONNULL_END
