//
//  OXMDeepLinkPlusHelper.m
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

@import UIKit;

#import "OXAExternalLinkHandler.h"
#import "OXAExternalURLOpeners.h"
#import "OXATrackingURLVisitors.h"
#import "OXAURLOpenAttempterBlock.h"
#import "OXMDeepLinkPlusHelper+OXAExternalLinkHandler.h"

#import "OXMDeepLinkPlusHelper.h"
#import "OXMDeepLinkPlusHelper+Testing.h"
#import "OXMServerConnection.h"
#import "OXMDeepLinkPlus.h"
#import "OXMFunctions.h"
#import "OXMFunctions+Private.h"
#import "OXMMacros.h"

@implementation OXMDeepLinkPlusHelper

// MARK: - Public API

+ (BOOL)isDeepLinkPlusURL:(NSURL *)url {
    return [[url.scheme lowercaseString] isEqualToString:@"deeplink+"];
}

+ (void)tryHandleDeepLinkPlus:(NSURL *)url
                   completion:(void (^)(BOOL visited, NSURL *fallbackURL, NSArray<NSURL *> *trackingURLs))completion
{
    id<OXMUIApplicationProtocol> const application = self.application ?: [UIApplication sharedApplication];
    OXAExternalURLOpenerBlock const urlOpener = [OXAExternalURLOpeners applicationAsExternalUrlOpener:application];
    
    id<OXMServerConnectionProtocol> connection = self.connection ?: [OXMServerConnection singleton];
    OXATrackingURLVisitorBlock const trackingUrlVisitor = [OXATrackingURLVisitors connectionAsTrackingURLVisitor:connection];
    
    OXAExternalLinkHandler * const externalLinkHandler = [[OXAExternalLinkHandler alloc] initWithPrimaryUrlOpener:urlOpener
                                                                                                deepLinkUrlOpener:urlOpener
                                                                                               trackingUrlVisitor:trackingUrlVisitor];
    
    [self tryHandleDeepLinkPlus:url
            externalLinkHandler:externalLinkHandler
                     completion:completion
        onClickthroughExitBlock:nil];
}

+ (void)visitTrackingURLs:(NSArray<NSURL *> *)trackingURLs {
    [self visitTrackingUrlStrings:[self urlArrayToUrlStringArray:trackingURLs]];
}

+ (void)visitTrackingUrlStrings:(NSArray<NSString *> *)trackingUrlStrings {
    id<OXMServerConnectionProtocol> connection = self.connection ?: [OXMServerConnection singleton];
    OXATrackingURLVisitorBlock const visitorBlock = [OXATrackingURLVisitors connectionAsTrackingURLVisitor:connection];
    visitorBlock(trackingUrlStrings);
}

+ (OXAExternalLinkHandler *)deepLinkPlusHandlerWithExternalLinkHandler:(OXAExternalLinkHandler *)externalLinkHandler {
    OXAURLOpenAttempterBlock const urlOpenAttempter = ^(NSURL *url,
                                                        OXACanOpenURLResultHandlerBlock compatibilityCheckHandler) {
        if (![self isDeepLinkPlusURL:url]) {
            compatibilityCheckHandler(NO);
            return;
        }
        
        OXAExternalURLOpenCallbacks * const callbacks = compatibilityCheckHandler(YES);
        OXAURLOpenResultHandlerBlock const completion = callbacks.urlOpenedCallback;
        OXMVoidBlock const onClickthroughExitBlock = callbacks.onClickthroughExitBlock;
        
        [self tryHandleDeepLinkPlus:url
                externalLinkHandler:externalLinkHandler
                         completion:^(BOOL visited, NSURL *fallbackURL, NSArray<NSURL *> *trackingURLs)
        {
            if (visited) {
                // DeepLink+ opened succesfully
                completion(YES);
                if (onClickthroughExitBlock != nil) {
                    onClickthroughExitBlock();
                };
                return;
            }
            
            if (fallbackURL != nil) {
                // handle fallback URL and fallback trackingURLs
                [externalLinkHandler openExternalUrl:fallbackURL
                                        trackingUrls:[self urlArrayToUrlStringArray:trackingURLs]
                                          completion:completion
                             onClickthroughExitBlock:onClickthroughExitBlock];
                return;
            }
            
            completion(NO);
        } onClickthroughExitBlock:onClickthroughExitBlock];
    };
    
    return [externalLinkHandler handlerByAddingUrlOpenAttempter:urlOpenAttempter];
}

// MARK: - Private Helpers

+ (void)tryHandleDeepLinkPlus:(NSURL *)url
          externalLinkHandler:(OXAExternalLinkHandler *)externalLinkHandler
                   completion:(void (^)(BOOL visited, NSURL *fallbackURL, NSArray<NSURL *> *trackingURLs))completion
      onClickthroughExitBlock:(nullable OXMVoidBlock)onClickthroughExitBlock
{
    OXMDeepLinkPlus *deepLinkPlus = [OXMDeepLinkPlus deepLinkPlusWithURL:url];
    if (deepLinkPlus == nil) {
        completion(NO, nil, nil);
        return;
    }
    
    OXAExternalLinkHandler * const deepLinkHandler = externalLinkHandler.asDeepLinkHandler;
    
    @weakify(self);
    [deepLinkHandler openExternalUrl:deepLinkPlus.primaryURL
                        trackingUrls:[self urlArrayToUrlStringArray:deepLinkPlus.primaryTrackingURLs]
                          completion:^(BOOL primaryLinkHandled)
     {
        @strongify(self);
        if (primaryLinkHandled) {
            completion(YES, nil, nil);
        } else if (deepLinkPlus.fallbackURL == nil) {
            completion(NO, nil, nil);
        } else if ([self isDeepLinkURL:deepLinkPlus.fallbackURL]) {
            [deepLinkHandler openExternalUrl:deepLinkPlus.fallbackURL
                                trackingUrls:[self urlArrayToUrlStringArray:deepLinkPlus.fallbackTrackingURLs]
                                  completion:^(BOOL fallbackLinkHandled)
             {
                if (fallbackLinkHandled) {
                    completion(YES, nil, nil);
                } else {
                    completion(NO, nil, nil);
                }
            } onClickthroughExitBlock:onClickthroughExitBlock];
        } else {
            completion(NO, deepLinkPlus.fallbackURL, deepLinkPlus.fallbackTrackingURLs);
        }
    } onClickthroughExitBlock:onClickthroughExitBlock];
}

+ (nullable NSArray<NSString *> *)urlArrayToUrlStringArray:(nullable NSArray<NSURL *> *)urlArray {
    if (urlArray == nil) {
        return nil;
    }
    NSMutableArray<NSString *> * const result = [[NSMutableArray alloc] initWithCapacity:urlArray.count];
    for (NSURL *nextUrl in urlArray) {
        [result addObject:nextUrl.absoluteString];
    }
    return result;
}

+ (BOOL)isDeepLinkURL:(NSURL *)url {
    NSArray<NSString *> *allowedSchemes = @[@"http", @"https", @"file"];
    if ([allowedSchemes containsObject:[url.scheme lowercaseString]]) {
        return NO;
    }
    return YES;
}

@end
