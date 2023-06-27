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

@import UIKit;

#import "PBMExternalLinkHandler.h"
#import "PBMExternalURLOpeners.h"
#import "PBMTrackingURLVisitors.h"
#import "PBMURLOpenAttempterBlock.h"
#import "PBMDeepLinkPlusHelper+PBMExternalLinkHandler.h"

#import "PBMDeepLinkPlusHelper.h"
#import "PBMDeepLinkPlusHelper+Testing.h"
#import "PBMDeepLinkPlus.h"
#import "PBMFunctions.h"
#import "PBMFunctions+Private.h"
#import "PBMMacros.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

@implementation PBMDeepLinkPlusHelper

// MARK: - Public API

+ (BOOL)isDeepLinkPlusURL:(NSURL *)url {
    return [[url.scheme lowercaseString] isEqualToString:@"deeplink+"];
}

+ (void)tryHandleDeepLinkPlus:(NSURL *)url
                   completion:(void (^)(BOOL visited, NSURL *fallbackURL, NSArray<NSURL *> *trackingURLs))completion
{
    id<PBMUIApplicationProtocol> const application = self.application ?: [UIApplication sharedApplication];
    PBMExternalURLOpenerBlock const urlOpener = [PBMExternalURLOpeners applicationAsExternalUrlOpener:application];
    
    id<PrebidServerConnectionProtocol> connection = self.connection ?: [PrebidServerConnection shared];
    PBMTrackingURLVisitorBlock const trackingUrlVisitor = [PBMTrackingURLVisitors connectionAsTrackingURLVisitor:connection];
    
    PBMExternalLinkHandler * const externalLinkHandler = [[PBMExternalLinkHandler alloc] initWithPrimaryUrlOpener:urlOpener
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
    id<PrebidServerConnectionProtocol> connection = self.connection ?: [PrebidServerConnection shared];
    PBMTrackingURLVisitorBlock const visitorBlock = [PBMTrackingURLVisitors connectionAsTrackingURLVisitor:connection];
    visitorBlock(trackingUrlStrings);
}

+ (PBMExternalLinkHandler *)deepLinkPlusHandlerWithExternalLinkHandler:(PBMExternalLinkHandler *)externalLinkHandler {
    PBMURLOpenAttempterBlock const urlOpenAttempter = ^(NSURL *url,
                                                        PBMCanOpenURLResultHandlerBlock compatibilityCheckHandler) {
        if (![self isDeepLinkPlusURL:url]) {
            compatibilityCheckHandler(NO);
            return;
        }
        
        PBMExternalURLOpenCallbacks * const callbacks = compatibilityCheckHandler(YES);
        PBMURLOpenResultHandlerBlock const completion = callbacks.urlOpenedCallback;
        PBMVoidBlock const onClickthroughExitBlock = callbacks.onClickthroughExitBlock;
        
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
          externalLinkHandler:(PBMExternalLinkHandler *)externalLinkHandler
                   completion:(void (^)(BOOL visited, NSURL *fallbackURL, NSArray<NSURL *> *trackingURLs))completion
      onClickthroughExitBlock:(nullable PBMVoidBlock)onClickthroughExitBlock
{
    PBMDeepLinkPlus *deepLinkPlus = [PBMDeepLinkPlus deepLinkPlusWithURL:url];
    if (deepLinkPlus == nil) {
        completion(NO, nil, nil);
        return;
    }
    
    PBMExternalLinkHandler * const deepLinkHandler = externalLinkHandler.asDeepLinkHandler;
    
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
